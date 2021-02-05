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

    if( m >= 9 )
      {

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
                                  Cluster = as.factor( class ) )

      colorScaleValues <- c( "red", "green", "blue", "yellow", "cyan", "magenta" )
      sortedClassValues <- sort( unique( class ) )
      if( length( sortedClassValues ) == 5 && sortedClassValues[1] == 2 )
        {
        colorScaleValues <- c( "green", "blue", "yellow", "cyan", "magenta" )
        }
      histReferencePlot <-
        ggplot( histDataFrame, aes( x = NormalizedIntensity, fill = Cluster ) ) +
        geom_histogram( aes( fill = Cluster ), bins = 200 ) +
        scale_fill_manual( values = colorScaleValues )
        # ggtitle( paste0( "Mean = ", reference$mean, ", Sd = ", reference$standardDeviation ) )
      histFilename <- paste0( figuresDirectory, "referencePlot", "_", m, "_", n, ".pdf" )
      if( useN4Images )
        {
        histFilename <- paste0( figuresDirectory, "referencePlot", "_", m, "_", n, "_N4.pdf" )
        }
      ggsave( filename = histFilename,
          plot = histReferencePlot, width = 5, height = 3, units = 'in' )

      }
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
csvFilename <- paste0( baseDirectory, "../", "meanSdReference.csv" )
if( useN4Images )
  {
  csvFilename <- paste0( baseDirectory, "../", "meanSdReferenceN4.csv" )
  }
write.csv( meanSdDataFrame, file = csvFilename, row.names = FALSE )

meanPlot <- ggplot( data = meanSdDataFrame, aes( x = NumberOfImages, y = Mean ) ) +
            geom_jitter( width = 0.25, size = 1, alpha = 0.25 ) +
            geom_boxplot( fill = "orange", alpha = 0.65 ) +
            theme( legend.position = "none" ) +
            ylim( c( 0.275, 0.75 ) ) +
            xlab( "Number of images in reference set" )
plotFilename <- paste0( figuresDirectory, "meanReferencePlot.pdf" )
if( useN4Images == TRUE )
  {
  plotFilename <- paste0( figuresDirectory, "meanReferenceN4Plot.pdf" )
  }
ggsave( filename = plotFilename,
        plot = meanPlot, width = 5, height = 3.5, units = 'in' )

sdPlot <- ggplot( data = meanSdDataFrame, aes( x = NumberOfImages, y = StandardDeviation ) ) +
            geom_jitter( width = 0.25, size = 1, alpha = 0.25 ) +
            geom_boxplot( fill = "navyblue", alpha = 0.65 ) +
            theme( legend.position = "none" ) +
            ylim( c( 0.14, 0.265 ) ) +
            xlab( "Number of images in reference set" )
plotFilename <- paste0( figuresDirectory, "sdReferencePlot.pdf" )
if( useN4Images == TRUE )
  {
  plotFilename <- paste0( figuresDirectory, "sdReferenceN4Plot.pdf" )
  }
ggsave( filename = plotFilename, plot = sdPlot, width = 5, height = 3.5, units = 'in' )


