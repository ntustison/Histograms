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

# fuzzySpatialCMeansSegmentation <- function( image, mask = NULL, numberOfClusters = 4,
#   m = 2, p = 1, q = 1, radius = 2, maxNumberOfIterations = 20, convergenceThreshold = 0.2,
#   verbose = FALSE )
#   {
#   if( is.na( mask ) )
#     {
#     mask <- antsImageClone( image ) * 0 + 1
#     }

#   x <- image[mask != 0]

#   v <- seq( from = 0, to = 1, length.out = numberOfClusters + 2 )[2:(numberOfClusters + 1)]
#   v <- v * ( max( x ) - min( x ) ) + min( x )
#   cc <- length( v )

#   xx <- matrix()
#   for( i in seq.int( cc ) )
#     {
#     if( i == 1 )
#       {
#       xx <- x
#       } else {
#       xx <- rbind( xx, x )
#       }
#     }

#   if( verbose == TRUE )
#     {
#     cat( "Cluster centers: ", v, "\n" )
#     }

#   if( length( radius ) == 1 )
#     {
#     radius <- rep( radius, image@dimension )
#     }

#   segmentation <- antsImageClone( image ) * 0
#   probabilityImages <- list()

#   iter <- 0
#   diceValue <- 0
#   while( iter < maxNumberOfIterations && diceValue < 1.0 - convergenceThreshold )
#     {

#     # update membership values

#     xv <- matrix()
#     for( k in seq.int( cc ) )
#       {
#       if( k == 1 )
#         {
#         xv <- abs( x - v[k] )
#         } else {
#         xv <- rbind( xv, abs( x - v[k] ) )
#         }
#       }

#     u <- matrix( data = 0, nrow = nrow( xv ), ncol = ncol( xv ) )
#     for( i in seq.int( cc ) )
#       {
#       n <- xv[i,]

#       d <- n * 0
#       for( k in seq.int( cc ) )
#         {
#         d <- d + ( n / xv[k,] ) ^ ( 2 / ( m - 1 ) )
#         }
#       u[i,] <- 1 / d
#       }
#     u[is.nan( u )] <- 1

#     # Update cluster centers

#     v <- rowSums( ( u ^ m ) * xx, na.rm = TRUE ) / rowSums( u ^ m, na.rm = TRUE )

#     # spatial function

#     h <- matrix( data = 0, nrow = nrow( u ), ncol = ncol( u ) )
#     for( i in seq.int( cc ) )
#       {
#       uimage <- antsImageClone( image ) * 0
#       uimage[mask != 0] <- u[i,]
#       probabilityImages[[i]] <- uimage
#       uneighborhoods <- getNeighborhoodInMask( uimage, mask, radius )
#       h[i,] <- colSums( uneighborhoods, na.rm = TRUE )
#       }

#     # u prime

#     d <- rep( 0, ncol( u ) )
#     for( k in seq.int( cc ) )
#       {
#       d <- ( d + u[k,] ^ p ) * ( h[k,] ^ q )
#       }

#     uprime <- matrix( data = 0, nrow = nrow( u ), ncol = ncol( u ) )
#     for( i in seq.int( cc ) )
#       {
#       uprime[i,] <- ( u[i,] ^ p * h[i,] ^ q ) / d
#       }

#     tmpSegmentation <- antsImageClone( image ) * 0
#     tmpSegmentation[mask != 0] <- max.col( t( uprime ) )

#     diceValue <- labelOverlapMeasures( segmentation, tmpSegmentation )$MeanOverlap[1]
#     iter <- iter + 1

#     if( verbose == TRUE )
#       {
#       cat( "Iteration ", iter, " (out of ", maxNumberOfIterations, "):  ",
#            "Dice overlap = ", diceValue, "\n", sep = "" )
#       }
#     segmentation <- tmpSegmentation
#     }
#   return( list( segmentationImage = segmentation,
#                 probabilityImages = probabilityImages ) )
#   }


fuzzySpatialCMeansLungSegmentation <- function( image, mask )
  {
  fspcm <- fuzzySpatialCMeansSegmentation( image, mask, numberOfClusters = 4,
    m = 2, p = 1, q = 1, radius = 2, maxNumberOfIterations = 20, convergenceThreshold = 0.01,
    verbose = FALSE )
  return( fspcm$segmentationImage )
  }


