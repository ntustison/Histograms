library( ANTsR )
library( ggplot2 )

useN4Images <- TRUE
useOldHealthy <- FALSE

##############################################
#
# Processing --- get randomized reference distributions
#

source( "./lungSegmentationAlgorithms.R" )
source( "./lungSegmentationUtilities.R" )

baseDirectory <- './'
dataDirectory <- paste0( baseDirectory, "../Data/Nifti/")

referenceYoungImageFiles <- list.files( path = paste0( dataDirectory, "YoungHealthy" ), pattern = "LungMask.nii.gz",
  recursive = TRUE, full.names = TRUE )
referenceOldImageFiles <- list.files( path = paste0( dataDirectory, "OldHealthy" ), pattern = "LungMask.nii.gz",
  recursive = TRUE, full.names = TRUE )

referenceImageFiles <- c( referenceYoungImageFiles )
if( useOldHealthy )
  {
  referenceImageFiles <- append( referenceImageFiles, referenceOldImageFiles )
  }

combinations <- list()
for( i in seq.int( length( referenceImageFiles ) ) )
  {
  combinations[[i]] <- combn( length( referenceImageFiles ), i )
  }

iterationNumberOfFiles <- c()
iterationMean <- c()
iterationStandardDeviation <- c()

for( m in seq.int( length( combinations ) ) )
  {
  # if( m < 11 )
  #   {
  #   next
  #   }
  cat( "Analyzing combination ", m, " of ", length( combinations ), "\n" )
  for( n in seq.int( ncol( combinations[[m]] ) ) )
    {
    fileIndices <- combinations[[m]][, n]
    numberOfFiles <- length( fileIndices )

    imageList <- list()
    maskList <- list()

    for( i in seq.int( numberOfFiles ) )
      {
      maskFile <- referenceImageFiles[fileIndices[i]]
      maskList[[i]] <- antsImageRead( maskFile )

      imageFile <- sub( "LungMask", "", maskFile )
      if( useN4Images == TRUE )
        {
        imageFile <- sub( "LungMask", "N4", maskFile )
        }
      imageList[[i]] <- antsImageRead( imageFile )
      }
    reference <- calculateReferenceDistribution( imageList, maskList )

    iterationNumberOfFiles <- append( iterationNumberOfFiles, numberOfFiles )
    iterationMean <- append( iterationMean, reference$mean )
    iterationStandardDeviation <- append( iterationStandardDeviation, reference$standardDeviation )

    class <- rep( 0, length( reference$samples ) )
    class[reference$samples <  reference$mean - 2 * reference$standardDeviation] <- 1
    class[reference$samples >= reference$mean - 2 * reference$standardDeviation &
          reference$samples <  reference$mean - 1 * reference$standardDeviation] <- 2
    class[reference$samples >= reference$mean - 1 * reference$standardDeviation &
          reference$samples <  reference$mean] <- 3
    class[reference$samples >= reference$mean &
          reference$samples <  reference$mean + 1 * reference$standardDeviation] <- 4
    class[reference$samples >= reference$mean + 1 * reference$standardDeviation &
          reference$samples <  reference$mean + 2 * reference$standardDeviation] <- 5
    class[reference$samples >= reference$mean + 2 * reference$standardDeviation] <- 6

    histDataFrame <- data.frame( NormalizedIntensity = reference$samples,
                                 TissueClass = as.factor( class ) )
    histReferencePlot <-
      ggplot( histDataFrame, aes( x = NormalizedIntensity, fill = TissueClass ) ) +
      geom_histogram( aes( fill = TissueClass ), bins = 50 ) +
      ggtitle( paste0( "Mean = ", reference$mean, ", Sd = ", reference$standardDeviation ) )
    ggsave( filename = paste0( "~/Desktop/referencePlot", "_", m, "_", n, ".pdf" ),
        plot = histReferencePlot, width = 8, height = 4, units = 'in' )
    }
  }

##################################################
#
# Plot variation in mean/standard deviation
#    - Exclude the degenerate case of all the files
#

numberOfNonDegenerateCases <- length( iterationMean ) - 1

meanSdDataFrame <- data.frame( NumberOfImages = as.factor( iterationNumberOfFiles[1:numberOfNonDegenerateCases] ),
                               Mean = iterationMean[1:numberOfNonDegenerateCases],
                               StandardDeviation = iterationStandardDeviation[1:numberOfNonDegenerateCases] )

meanPlot <- ggplot( data = meanSdDataFrame, aes( x = NumberOfImages, y = Mean, fill = NumberOfImages ) ) +
            geom_boxplot()
ggsave( filename = paste0( "~/Desktop/meanVariancePlot.pdf" ),
        plot = meanPlot, width = 8, height = 6, units = 'in' )

sdPlot <- ggplot( data = meanSdDataFrame, aes( x = NumberOfImages, y = StandardDeviation, fill = NumberOfImages ) ) +
            geom_boxplot()
ggsave( filename = paste0( "~/Desktop/meanSdPlot.pdf" ),
        plot = sdPlot, width = 8, height = 6, units = 'in' )


##################################################
#
#
#
#

dataDirectory <- paste0( baseDirectory, "NiftiProcessed" )

segmentationFiles <- list.files( path = dataDirectory, pattern = "Segmentation0N4.nii.gz",
  recursive = TRUE, full.names = TRUE )

meanSdDataFrame <- data.frame( NumberOfImages = as.factor( iterationNumberOfFiles ),
                               Mean = iterationMean,
                               StandardDeviation = iterationStandardDeviation )

numberOfPermutations <- nrow( meanSdDataFrame )

classes <- c()
volumePercentageDifferences <- c()
actualDiagnosis <- c()
for( i in seq.int( numberOfPermutations ) )
  {
  if( as.numeric( meanSdDataFrame$NumberOfImages[i] ) < 10 )
    {
    next
    }

  cat( "Doing permutation", i, ": ", "mean =", meanSdDataFrame$Mean[i], ", sd =", meanSdDataFrame$StandardDeviation[i], "\n" )
  for( j in seq.int( length( segmentationFiles ) ) )
    {
    cat( "   Analyzing ", segmentationFiles[j], "\n" )
    image <- antsImageRead( segmentationFiles[j] )
    muFile <- sub( "Segmentation0N4", "BinningMu", segmentationFiles[j] )
    muSegmentationImage <- antsImageRead( muFile ) - 1
    muSegmentationImage[muSegmentationImage < 0] <- 0
    mask <- thresholdImage( muSegmentationImage, 0, 0, 0, 1 )

    iterationSegmentation <- muSegmentation( image, mask, meanSdDataFrame$Mean[i], meanSdDataFrame$StandardDeviation[i] )

    geom <- labelGeometryMeasures( mask )
    totalVolume <- sum( geom$VolumeInMillimeters )

    muGeom <- labelGeometryMeasures( muSegmentationImage )
    iterationGeom <- labelGeometryMeasures( iterationSegmentation )

    volumeDefectDifferences <- rep( 0, 6 )
    for( k in seq.int( 6 ) )
      {
      muVolume <- 0
      iterationVolume <- 0
      if( k %in% muGeom$Label )
        {
        index <- which( muGeom$Label %in% k )
        muVolume <- muGeom$VolumeInMillimeters[index]
        }
      if( k %in% iterationGeom$Label )
        {
        index <- which( iterationGeom$Label %in% k )
        iterationVolume <- iterationGeom$VolumeInMillimeters[index]
        }

      volumePercentageDifferences <- append( volumePercentageDifferences, ( muVolume - iterationVolume ) / totalVolume )
      classes <- append( classes, k )

      tokens <- strsplit( segmentationFiles[j], "/" )
      diagnosis <- gsub( "Old", "", tokens[[1]][8] )
      diagnosis <- gsub( "Young", "", diagnosis )
      actualDiagnosis <- append( actualDiagnosis, diagnosis )
      }
    }
  }

##################################################
#
# Plot variation in class percentage
#

classDataFrame <- data.frame( Class = as.factor( classes ),
                              VolumePercentageDifference = volumePercentageDifferences,
                              Diagnosis = as.factor( actualDiagnosis ) )

classPlot <- ggplot( data = classDataFrame, aes( x = Class, y = VolumePercentageDifference ) ) +
            geom_violin() +
            geom_jitter( mapping = aes( color = Diagnosis ), width = 0.4, size = 1, alpha = 0.1 )
ggsave( filename = paste0( "~/Desktop/volumeVariancePlot.pdf" ),
        plot = classPlot, width = 8, height = 6, units = 'in' )

