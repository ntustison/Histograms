library( ANTsR )
library( ggplot2 )

useN4Images <- FALSE
useOldHealthy <- FALSE

##############################################
#
# Processing --- get randomized reference distributions
#

source( "./lungSegmentationAlgorithms.R" )
source( "./lungSegmentationUtilities.R" )

baseDirectory <- './'
dataDirectory <- paste0( baseDirectory, "../Data/Nifti/")
figuresDirectory <- paste0( baseDirectory, "../../Text/Figures/" )

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
  # if( m < 2 )
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
    reference <- calculateReferenceDistributionForLinearBinning( imageList, maskList )

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
    ggsave( filename = paste0( figuresDirectory, "referencePlot", "_", m, "_", n, ".pdf" ),
        plot = histReferencePlot, width = 8, height = 4, units = 'in' )
    }
  }

##################################################
#
# Plot variation in mean/standard deviation
#

numberOfNonDegenerateCases <- length( iterationMean ) - 1

meanSdDataFrame <- data.frame( NumberOfImages = as.factor( iterationNumberOfFiles[1:numberOfNonDegenerateCases] ),
                               Mean = iterationMean[1:numberOfNonDegenerateCases],
                               StandardDeviation = iterationStandardDeviation[1:numberOfNonDegenerateCases] )

meanPlot <- ggplot( data = meanSdDataFrame, aes( x = NumberOfImages, y = Mean, fill = NumberOfImages ) ) +
            geom_boxplot()
ggsave( filename = paste0( figuresDirectory, "meanVariancePlot.pdf" ),
        plot = meanPlot, width = 8, height = 6, units = 'in' )

sdPlot <- ggplot( data = meanSdDataFrame, aes( x = NumberOfImages, y = StandardDeviation, fill = NumberOfImages ) ) +
            geom_boxplot()
ggsave( filename = paste0( figuresDirectory, "sdVariance.pdf" ),
        plot = sdPlot, width = 8, height = 6, units = 'in' )


