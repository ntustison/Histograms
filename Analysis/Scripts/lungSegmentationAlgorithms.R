library( ANTsR )
library( ANTsRNet )

# Note that all image preprocessing is carried out prior to calling these routines.

calculateReferenceDistributionForLinearBinning <- function( imageList, maskList )
{
  totalImageListVector <- c()
  for( i in seq.int( length( imageList ) ) )
    {
    image <- imageList[[i]]
    mask <- maskList[[i]]

    imageVector <- image[mask != 0]
    thresholdValue <- quantile( imageVector, 0.99 )[[1]]
    # imageVector <- imageVector[imageVector <= thresholdValue]
    # From histogram figures in the 2016 paper, it looks like they
    # keep the truncated values in the histogram.
    imageVector[imageVector > thresholdValue] <- thresholdValue

    # Rescale each image to [0,1]
    imageVector <- ( imageVector - min( imageVector ) ) / ( max( imageVector ) - min( imageVector ) )

    totalImageListVector <- append( totalImageListVector, imageVector )
    }
  meanImageList <- mean( totalImageListVector )
  sdImageList <- sd( totalImageListVector )

  return( list( mean = meanImageList, standardDeviation = sdImageList, samples = totalImageListVector ) )
}

linearBinningLungSegmentation <- function( image, mask, mean, standardDeviation )
  {
  segmentation <- antsImageClone( image )

  segmentation[image <  mean - 2 * standardDeviation] <- 1
  segmentation[image >= mean - 2 * standardDeviation &
               image <  mean - 1 * standardDeviation] <- 2
  segmentation[image >= mean - 1 * standardDeviation &
               image <  mean] <- 3
  segmentation[image >= mean &
               image <  mean + 1 * standardDeviation] <- 4
  segmentation[image >= mean + 1 * standardDeviation &
               image <  mean + 2 * standardDeviation] <- 5
  segmentation[image >= mean + 2 * standardDeviation] <- 6

  segmentation[mask == 0] <- 0

  return( segmentation )
  }

kirbyKmeansLungSegmentation <- function( image, mask )
  {

  #
  # From Kirby, Academic Radiology, 2012.  Page 144.
  #
  # "This was accomplished in three steps as follows: 1) K-means with four
  #  clusters was initially applied to the 3He image, 2) K-means with four
  #  clusters was then reapplied to C1, and 3) the first two clusters from
  #  step 2 were merged to represent the background and ventilation defects
  #  and the last two clusters from step 2 were merged to represent the
  #  hypointense signal regions. For both steps 1 and 2, a standard
  #  initialization method was performed to produce the initial centroids
  #  by dividing the full pixel range of 0–255 into four equal regions:
  #  0–63, 64–127, 128–191, 192–255, and selecting the interval center as
  #  the centroid for each cluster."
  #

  allMask <- antsImageClone( image ) * 0 + 1

  # Round 1
  imageVector1 <- image[allMask == 1]
  clusterCenters1 <- c( 0.2, 0.4, 0.6, 0.8 ) *
    ( max( imageVector1 ) - min( imageVector1 ) ) + min( imageVector1 )

  kmeansRound1 <- try( expr = { kmeans( imageVector1, centers = clusterCenters1 ) }, silent = TRUE )
  if( class( kmeansRound1 ) == "try-error" )
    {
    stop( "KirbyKmeans: Round 1 failed." )
    } else {
    imageVector2 <- imageVector1[which( kmeansRound1$cluster == 1 )]
    clusterCenters2 <- c( 0.2, 0.4, 0.6, 0.8 ) *
      ( max( imageVector2 ) - min( imageVector2 ) ) + min( imageVector2 )
    kmeansRound2 <- try( expr = { kmeans( imageVector2, centers = clusterCenters2 ) }, silent = TRUE )
    if( class( kmeansRound2 ) == "try-error" )
      {
      stop( "KirbyKmeans: Round 2 failed." )
      } else {
      kmeansRound2$cluster[which( kmeansRound2$cluster == 2 )] <- 1
      kmeansRound2$cluster[which( kmeansRound2$cluster == 3 )] <- 2
      kmeansRound2$cluster[which( kmeansRound2$cluster == 4 )] <- 2

      kmeansRound1$cluster <- kmeansRound1$cluster + 1
      kmeansRound1$cluster[kmeansRound1$cluster == 2] <- kmeansRound2$cluster

      segmentation <- antsImageClone( image ) * 0
      segmentation[allMask == 1] <- kmeansRound1$cluster
      segmentation <- segmentation * mask
      return( segmentation )
      }
    }
  }

atroposLungSegmentation <- function( image, mask )
  {
  segmentation <- functionalLungSegmentation( image, mask, numberOfIterations = 2,
    numberOfAtroposIterations = 5, mrfParameters = "[1.25,2x2x2]", biasCorrection = "none",
    numberOfClusters = 6, clusterCenters = NA, verbose = FALSE )

  return( segmentation$segmentationImage )
  }

elBichoLungSegmentation <- function( image, mask )
  {
  elBichoSeg <- elBicho( image, mask, useCoarseSlicesOnly = TRUE, verbose = FALSE )
  return( elBichoSeg$segmentationImage )
  }



