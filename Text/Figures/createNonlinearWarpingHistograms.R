library( ANTsR )
library( ANTsRNet )
library( ggplot2 )

histogramWarpImageIntensities2 <- function( image,
  breakPoints = c( 0.25, 0.5, 0.75 ),
  displacements = NULL, clampEndPoints = c( FALSE, FALSE ),
  sdDisplacements = 0.05, transformDomainSize = 20 )
  {

  if( ! is.vector( clampEndPoints ) || length( clampEndPoints ) != 2 )
    {
    stop( "clampEndPoints must be a boolean vector of length 2." )
    }

  if( length( breakPoints ) > 1 )
    {
    if( any( breakPoints < 0.0 ) || any( breakPoints > 1.0 ) )
      {
      stop( "If specifying breakPoints as a vector, values must be in the range [0, 1]." )
      }
    }

  parametricPoints <- NULL
  numberOfNonZeroDisplacements <- 1
  if( length( breakPoints ) > 1 )
    {
    parametricPoints <- breakPoints
    numberOfNonZeroDisplacements <- length( breakPoints )
    if( clampEndPoints[1] == TRUE )
      {
      parametricPoints <- c( 0, parametricPoints )
      }
    if( clampEndPoints[2] == TRUE )
      {
      parametricPoints <- c( parametricPoints, 1 )
      }
    } else {
    parametricPoints <- seq( 0, 1, length.out = breakPoints + length( which( clampEndPoints == TRUE ) ) )
    numberOfNonZeroDisplacements <- breakPoints
    }

  weights <- NULL
  if( is.null( displacements ) )
    {
    displacements <- rnorm( numberOfNonZeroDisplacements, 0, sdDisplacements )
    weights <- rep( 1, length( displacements ) )
    if( clampEndPoints[1] == TRUE )
      {
      displacements <- c( 0, displacements )
      weights <- c( 1000, weights )
      }
    if( clampEndPoints[2] == TRUE )
      {
      displacements <- c( displacements, 0 )
      weights <- c( weights, 1000 )
      }
    }

  if( length( displacements ) != length( parametricPoints ) )
    {
    cat( "displacements = ", displacements, "\n" )
    cat( "break points = ", parametricPoints, "\n" )
    stop( "Length of displacements does not match the length of the break points." )
    }

  scatteredData <- matrix( displacements )
  parametricData <- matrix( parametricPoints )

  transformDomainOrigin <- 0
  transformDomainSpacing <- ( 1.0 - transformDomainOrigin ) / ( transformDomainSize - 1 )

  bsplineHistogramTransform <- fitBsplineObjectToScatteredData( scatteredData, parametricData,
    c( transformDomainOrigin ), c( transformDomainSpacing ), c( transformDomainSize ),
    dataWeights = weights )

  transformDomain <- seq( 0, 1, length.out = transformDomainSize )

  normalizedImage <- antsImageClone( image ) %>% iMath( "Normalize" )
  transformedArray <- as.array( normalizedImage )
  normalizedArray <- as.array( normalizedImage )

  for( i in seq.int( length( transformDomain ) - 1 ) )
    {
    indices <- which( normalizedArray >= transformDomain[i] & normalizedArray < transformDomain[i+1] )
    intensities <- normalizedArray[indices]

    alpha <- ( intensities - transformDomain[i] ) / ( transformDomain[i+1] - transformDomain[i] )
    xfrm <- alpha * ( bsplineHistogramTransform[i+1, 1] - bsplineHistogramTransform[i, 1] ) + bsplineHistogramTransform[i, 1]
    transformedArray[indices] <- intensities + xfrm
    }
  transformedImage <- as.antsImage( transformedArray, reference = image ) *
    ( max( image ) - min( image ) ) + min( image )

  bsplineMapping <- cbind( matrix( transformDomain )[,1], bsplineHistogramTransform[,1] )

  return( list( transformedImage = transformedImage,
                bsplineMapping = bsplineMapping ) )
  }

makeSegmentationHistogram <- function( image, segmentation, filename, plotSegmentationLabels = FALSE )
  {
  mask <- thresholdImage( segmentation, 0, 0, 0, 1 )

  histPlot <- NULL
  if( plotSegmentationLabels == TRUE )
    {
    histDataFrame <- data.frame( NormalizedIntensity = image[mask == 1],
                                TissueClass = as.factor( segmentation[mask == 1] ) )
    histPlot <-
      ggplot( histDataFrame, aes( x = NormalizedIntensity, fill = TissueClass ) ) +
      geom_histogram( aes( fill = TissueClass ), bins = 200 ) +
      scale_fill_manual( values = c( "red", "green", "blue", "yellow", "cyan", "magenta" ) )

    } else {
    histDataFrame <- data.frame( NormalizedIntensity = image[mask == 1] )
    histPlot <-
      ggplot( histDataFrame, aes( x = NormalizedIntensity ) ) +
      geom_histogram( bins = 200 ) +
      xlim( c( 0, 1750 ) )

    }
  ggsave( filename = filename, plot = histPlot, width = 8, height = 4, units = 'in' )
  }

#######################################################################
#
#
#
#
#######################################################################

# User parameters

sdDisplacements <- c( 0.01, 0.025, 0.05, 0.075, 0.1 )

gasFile <- "/Users/ntustison/Documents/Academic/InProgress/Histograms/Text/Figures/sample_ventilation.nii.gz"
segFile <- "/Users/ntustison/Documents/Academic/InProgress/Histograms/Text/Figures/sample_ventilation_segmentation.nii.gz"
outputPrefix <- "/Users/ntustison/Documents/Academic/InProgress/Histograms/Text/Figures/nonlinearIntensityWarping"

image <- antsImageRead( gasFile )
segmentation <- antsImageRead( segFile )
mask <- thresholdImage( segmentation, 0, 0, 0, 1 )

histogramFile <- paste0( outputPrefix, "OriginalHistogram.pdf" )
makeSegmentationHistogram( image, mask, histogramFile, FALSE )

########################################
#
# do simulations
#
########################################

for( i in seq.int( length( sdDisplacements ) ) )
  {
  cat( "   Doing simulation ", sdDisplacements[i], "\n" )

  outputPrefixSimulation <- paste0( outputPrefix, "_SD-", sdDisplacements[i], "_" )

  bspliner <- histogramWarpImageIntensities2( image,
    breakPoints = c( 0.2, 0.4, 0.6, 0.8 ),
    clampEndPoints = c( TRUE, TRUE ),
    sdDisplacements = sdDisplacements[i], transformDomainSize = 20 )

  transformedImage <- bspliner$transformedImage

  antsImageWrite( transformedImage, paste0( outputPrefixSimulation, "TransformedImage.nii.gz" ) )

  histogramFile <- paste0( outputPrefixSimulation, "TransformedImageHistogram.pdf" )
  makeSegmentationHistogram( transformedImage, mask, histogramFile, FALSE )

  mapping <- bspliner$bsplineMapping
  mappingDataFrame <- data.frame( Input = mapping[, 1], Output = mapping[, 1] + mapping[, 2] )
  mappingPlot <- ggplot( data = mappingDataFrame ) +
                  geom_line( aes( x = Input, y = Output ), color = "blue" ) +
                  geom_abline( slope = 1, intercept = 0, linetype = 2, color = "black" ) +
                  xlim( 0, 1 ) +
                  ylim( 0, 1 )
  mappingFile <- paste0( outputPrefixSimulation, "Mapping.pdf" )
  ggsave( filename = mappingFile, plot = mappingPlot, width = 4, height = 4, units = 'in' )
  }

