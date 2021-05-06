library( ANTsR )
library( ANTsRNet )
library( ggplot2 )
library( HistogramTools )

useN4Images <- FALSE
numberOfSimulationsPerImage <- 10
sdDisplacements <- 0.175

source( "./lungSegmentationAlgorithms.R" )
source( "./lungSegmentationUtilities.R" )

artefacts <- list()
artefacts[[1]] <- c( TRUE, FALSE )
artefacts[[2]] <- c( FALSE, TRUE )
artefacts[[3]] <- c( TRUE, TRUE )

artefactNames <- c( "Noise", "Nonlinearities", "NoiseAndNonlinearities" )

# User parameters

baseDirectory <- './'
dataDirectory <- paste0( baseDirectory, "../Data/Nifti/")
outputDirectory <- paste0( baseDirectory, "../Data/" )

gasFiles <- list.files( path = dataDirectory, pattern = "N4.nii.gz",
  recursive = TRUE, full.names = TRUE )
maskFiles <- gsub( "N4", "LungMask", gasFiles )
if( useN4Images == FALSE )
  {
  gasFiles <- gsub( "N4", "", gasFiles )
  }

subject <- c()
simulation <- c()
artefact <- c()
psnr <- c()

for( i in seq.int( length( gasFiles ) ) )
  {
  tokens <- strsplit( gasFiles[i], "/" )
  subjectDiagnosis <- tokens[[1]][6]
  subjectId <- tokens[[1]][7]

  cat( "Subject:  ", subjectId, "(", i, "out of", length( gasFiles ), ")\n" )

  image <- antsImageRead( gasFiles[i] )
  image <- image %>% iMath( "Normalize" )

  ########################################
  #
  # do noise simulations
  #
  ########################################

  for( j in seq.int( numberOfSimulationsPerImage ) )
    {
    cat( "   Doing simulation ", j, "\n" )

    transformedImage <- antsImageClone( image )

    for( s in seq.int( length( artefacts ) ) )
      {
      doNoise <- artefacts[[s]][1]
      doNonlinearities <- artefacts[[s]][2]

      if( doNonlinearities == TRUE )
        {
        breakPoints <- c( 0.2, 0.4, 0.6, 0.8 )
        displacements <- abs( rnorm( length( breakPoints ), 0, sdDisplacements ) )
        if( sample( c( TRUE, FALSE ), 1 ) )
          {
          displacements <- displacements * -1
          }
        bspliner <- histogramWarpImageIntensities2( image,
          breakPoints = breakPoints,
          clampEndPoints = c( TRUE, TRUE ),
          displacements = displacements,
          sdDisplacements = sdDisplacements, transformDomainSize = 20 )

        transformedImage <- ( bspliner$transformedImage - min( bspliner$transformedImage ) ) /
          ( max( bspliner$transformedImage ) - min( bspliner$transformedImage ) )
        }
      if( doNoise == TRUE )
        {
        transformedImage <- addNoiseToImage( transformedImage,
          noiseModel = 'additivegaussian', c( 0, runif( 1, 0, 0.05 ) ) )
        transformedImage <- ( transformedImage - min( transformedImage ) ) /
          ( max( transformedImage ) - min( transformedImage ) )
        }
      psnr <- append( psnr, PSNR( image, transformedImage ) )
      simulation <- append( simulation, j )
      subject <- append( subject, subjectId )
      artefact <- append( artefact, artefactNames[s] )
      }
    }
  }
psnrDataFrame <- data.frame( Subject = subject, Simulation = simulation, Artefact = artefact, PSNR = psnr )  
write.csv( psnrDataFrame, paste0( outputDirectory, "psnr.csv" ) )
