library( ANTsR )
library( ANTsRNet )
library( ggplot2 )
library( HistogramTools )
library( factoextra )

source( "./lungSegmentationAlgorithms.R" )
source( "./lungSegmentationUtilities.R" )

#######################################################################
#
#
#
#
#######################################################################

# User parameters

numberOfSimulationsPerImage <- 10
sdDisplacements <- 0.05

doNoise <- TRUE
doNonlinearities <- FALSE

baseDirectory <- "/Users/ntustison/Data/HeliumLungStudies/QuantificationMethodComparison/"
outputDirectoryName <- "SimulationExperiments_Noise"
dataDirectory <- paste0( baseDirectory, "NiftiProcessed" )

gasFiles <- list.files( path = dataDirectory, pattern = "NormalizedMu.nii.gz",
  recursive = TRUE, full.names = TRUE )

subject <- c()
diagnosis <- c()
simulationNumber <- c()
segmentation <- c()
vdp <- c()
diceAll <- c()
dice1 <- c()
dice2 <- c()
dice3 <- c()
dice4 <- c()

simSubject <- c()
simDiagnosis <- c()
simSimulationNumber <- c()
ssim <- c()
minkowskiDist1 <- c()
minkowskiDist2 <- c()
intersectDist <- c()
pearson <- c()
chi <- c()

for( i in seq.int( length( gasFiles ) ) )
  {
  muSegmentationFile <- sub( "NormalizedMu", "BinningMu", gasFiles[i] )

  tokens <- strsplit( gasFiles[i], "/" )
  subjectDiagnosis <- tokens[[1]][8]
  subjectId <- tokens[[1]][9]

  cat( "Subject:  ", subjectId, "(", i, "out of", length( gasFiles ), ")\n" )

  image <- antsImageRead( gasFiles[i] )
  muSegmentation <- antsImageRead( muSegmentationFile )
  mask <- thresholdImage( muSegmentation, 0, 0, 0, 1 )
  clusterPartition <- getClusterPartition( image, muSegmentation )
  kmeansClusterCenters <- 0.5 * ( clusterPartition[1:6] + clusterPartition[2:7] )

  outputDirectory <- dirname( sub( "NiftiProcessed", outputDirectoryName, dirname( muSegmentationFile ) ) )
  if( ! dir.exists( outputDirectory ) )
    {
    dir.create( outputDirectory, recursive = TRUE )
    }
  outputPrefix <- paste0( outputDirectory, "/", sub( "NormalizedMu.nii.gz", "", basename( gasFiles[i] ) ) )
  imageFile <- paste0( outputPrefix, "_OriginalImage.nii.gz" )
  if( ! file.exists( imageFile ) )
    {
    antsImageWrite( image, imageFile  )
    }
  histogramFile <- paste0( outputPrefix, "_OriginalImageHistogram.pdf" )
  if( ! file.exists( histogramFile ) )
    {
    makeSegmentationHistogram( image, mask, histogramFile, FALSE )
    }


  ########################################
  #
  # segment original
  #
  ########################################

  imageVector <- image[mask != 0]

  histogramOriginal <- hist( imageVector, breaks = seq.int( from = 0, to = 1.0, length.out = 200 ), plot = FALSE )

  # Do linear binning
  cat( "       (original) linear binning...\n" )

  imageFile <- paste0( outputPrefix, "_LinearBinning.nii.gz" )
  if( ! file.exists( imageFile ) )
    {
    linearBinningResults <- rep( 0, length( imageVector ) )
    linearBinningSegmentationOriginal <- antsImageClone( image ) * 0
    for( k in seq.int( length( clusterPartition ) - 1 ) )
      {
      linearBinningResults[which( imageVector > clusterPartition[k] & imageVector <= clusterPartition[k+1] )] <- k
      }
    linearBinningSegmentationOriginal[mask == 1] <- linearBinningResults
    linearBinningSegmentationOriginal <- groupClusters( linearBinningSegmentationOriginal )
    antsImageWrite( linearBinningSegmentationOriginal, imageFile )
    } else {
    linearBinningSegmentationOriginal <- antsImageRead( imageFile )
    }
  histogramFile <- paste0( outputPrefix, "_LinearBinningHistogram.pdf" )
  if( ! file.exists( histogramFile ) )
    {
    makeSegmentationHistogram( image, linearBinningSegmentationOriginal, histogramFile, TRUE )
    }

  ## Do Atropos
  cat( "       (original) atropos...\n" )
  imageFile <- paste0( outputPrefix, "_Atropos.nii.gz" )
  if( ! file.exists( imageFile ) )
    {
    atroposSegmentationOriginal <- groupClusters( atroposLungSegmentation( image, mask ) )
    antsImageWrite( atroposSegmentationOriginal, imageFile )
    } else {
    atroposSegmentationOriginal <- antsImageRead( imageFile )
    }
  histogramFile <- paste0( outputPrefix, "_AtroposHistogram.pdf" )
  if( ! file.exists( histogramFile ) )
    {
    makeSegmentationHistogram( image, atroposSegmentationOriginal, histogramFile, TRUE )
    }

  ## Do El Bicho
  cat( "       (original) el bicho...\n" )
  imageFile <- paste0( outputPrefix, "_ElBicho.nii.gz" )
  if( ! file.exists( imageFile ) )
    {
    elBichoSegmentationOriginal <- groupClusters( elBichoLungSegmentation( image, mask ) )
    antsImageWrite( elBichoSegmentationOriginal, imageFile )
    } else {
    elBichoSegmentationOriginal <- antsImageRead( imageFile )
    }
  histogramFile <- paste0( outputPrefix, "_ElBichoHistogram.pdf" )
  if( ! file.exists( histogramFile ) )
    {
    makeSegmentationHistogram( image, elBichoSegmentationOriginal, histogramFile, TRUE )
    }

  # Do kmeans
  cat( "       (original) hierarchical kmeans...\n" )
  imageFile <- paste0( outputPrefix, "_KMeans.nii.gz" )
  if( ! file.exists( imageFile ) )
    {
    kmeansSegmentationOriginal <- groupClusters( kirbyKmeansLungSegmentation( image, mask ) )
    antsImageWrite( kmeansSegmentationOriginal, imageFile )
    } else {
    kmeansSegmentationOriginal <- antsImageRead( imageFile )
    }
  histogramFile <- paste0( outputPrefix, "_KmeansHistogram.pdf" )
  if( ! file.exists( histogramFile ) )
    {
    makeSegmentationHistogram( image, kmeansSegmentationOriginal, histogramFile, TRUE )
    }

  ########################################
  #
  # do simulations
  #
  ########################################

  for( j in seq.int( numberOfSimulationsPerImage ) )
    {
    cat( "   Doing simulation ", j, "\n" )

    outputPrefixSimulation <- paste0( outputPrefix, "_Simulation", j, "_" )
    transformedImageFile <- paste0( outputPrefixSimulation, "TransformedImage.nii.gz" )

    transformedImage <- antsImageClone( image )

    if( ! file.exists( transformedImageFile ) )
      {
      if( doNonlinearities == TRUE )
        {
        bspliner <- histogramWarpImageIntensities2( image,
          breakPoints = c( 0.2, 0.4, 0.6, 0.8 ),
          clampEndPoints = c( TRUE, FALSE ),
          sdDisplacements = sdDisplacements, transformDomainSize = 20 )
        transformedImage <- ( bspliner$transformedImage - min( bspliner$transformedImage ) ) /
          ( max( bspliner$transformedImage ) - min( bspliner$transformedImage ) )

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
      if( doNoise == TRUE )
        {
        transformedImage <- addNoiseToImage( transformedImage,
          noiseModel = 'additivegaussian', c( 0, runif( 1, 0, 0.05 ) ) )
        transformedImage <- ( transformedImage - min( transformedImage ) ) /
          ( max( transformedImage ) - min( transformedImage ) )
        }
      antsImageWrite( transformedImage, transformedImageFile )
      } else {
      transformedImage <- antsImageRead( transformedImageFile )
      }
    histogramFile <- paste0( outputPrefixSimulation, "TransformedImageHistogram.pdf" )
    if( ! file.exists( histogramFile ) )
      {
      makeSegmentationHistogram( transformedImage, mask, histogramFile, FALSE )
      }

    transformedImageVector <- transformedImage[mask != 0]

    ###################
    #
    # Histogram comparisons
    #
    ####################

    histogramTransformed <- hist( transformedImageVector, breaks = histogramOriginal$breaks, plot = FALSE )

    simSubject <- append( simSubject, subjectId )
    simDiagnosis <- append( simDiagnosis, subjectDiagnosis )
    simSimulationNumber <- append( simSimulationNumber, j )
    ssim <- append( ssim, SSIM( image, transformedImage ) )
    minkowskiDist1 <- append( minkowskiDist1, minkowski.dist( histogramOriginal, histogramTransformed, 1 ) )
    minkowskiDist2 <- append( minkowskiDist2, minkowski.dist( histogramOriginal, histogramTransformed, 2 ) )
    intersectDist <- append( intersectDist, intersect.dist( histogramOriginal, histogramTransformed ) )

    h1 <- histogramOriginal$density
    h2 <- histogramTransformed$density

    pearson <- append( pearson, cor( h1, h2, method = "pearson" ) )
    chi <- append( chi, sum( ( h1 - h2 )^2 / h1 ) )

    ###################

    # Do linear binning

    cat( "       linear binning...\n" )

    imageFile <- paste0( outputPrefixSimulation, "_LinearBinning.nii.gz" )
    if( ! file.exists( imageFile ) )
      {
      linearBinningResults <- rep( 0, length( transformedImageVector ) )
      linearBinningSegmentation <- antsImageClone( transformedImage ) * 0
      for( k in seq.int( length( clusterPartition ) - 1 ) )
        {
        linearBinningResults[which( transformedImageVector > clusterPartition[k] & transformedImageVector <= clusterPartition[k+1] )] <- k
        }
      linearBinningSegmentation[mask == 1] <- linearBinningResults
      linearBinningSegmentation <- groupClusters( linearBinningSegmentation )
      antsImageWrite( linearBinningSegmentation, imageFile )
      } else {
      linearBinningSegmentation <- antsImageRead( imageFile )
      }
    histogramFile <- paste0( outputPrefixSimulation, "LinearBinningHistogram.pdf" )
    if( ! file.exists( histogramFile ) )
      {
      makeSegmentationHistogram( transformedImage, linearBinningSegmentation, histogramFile, TRUE )
      }

    simulationNumber <- append( simulationNumber, j )
    diagnosis <- append( diagnosis, subjectDiagnosis )
    subject <- append( subject, subjectId )
    segmentation <- append( segmentation, "LinearBinning" )

    vdp <-  append( vdp,
      length( linearBinningSegmentation[linearBinningSegmentation == 1] ) / length( mask[mask == 1] ) )
    overlap <- labelOverlapMeasures( linearBinningSegmentationOriginal, linearBinningSegmentation )
    diceAll <- append( diceAll, overlap$MeanOverlap[1] )
    dice1 <- append( dice1, overlap$MeanOverlap[2] )
    dice2 <- append( dice2, overlap$MeanOverlap[3] )
    dice3 <- append( dice3, overlap$MeanOverlap[4] )
    dice4 <- append( dice4, overlap$MeanOverlap[5] )

    ## Do Atropos

    cat( "       atropos...\n" )

    imageFile <- paste0( outputPrefixSimulation, "Atropos.nii.gz" )
    if( ! file.exists( imageFile ) )
      {
      atroposSegmentation <- groupClusters( atroposLungSegmentation( transformedImage, mask ) )
      antsImageWrite( atroposSegmentation, imageFile )
      } else {
      atroposSegmentation <- antsImageRead( imageFile )
      }
    histogramFile <- paste0( outputPrefixSimulation, "AtroposHistogram.pdf" )
    if( ! file.exists( histogramFile ) )
      {
      makeSegmentationHistogram( transformedImage, atroposSegmentation, histogramFile, TRUE )
      }

    simulationNumber <- append( simulationNumber, j )
    diagnosis <- append( diagnosis, subjectDiagnosis )
    subject <- append( subject, subjectId )
    segmentation <- append( segmentation, "Atropos" )

    vdp <-  append( vdp,
      length( atroposSegmentation[atroposSegmentation == 1] ) / length( mask[mask == 1] ) )
    overlap <- labelOverlapMeasures( atroposSegmentationOriginal, atroposSegmentation )
    diceAll <- append( diceAll, overlap$MeanOverlap[1] )
    dice1 <- append( dice1, overlap$MeanOverlap[2] )
    dice2 <- append( dice2, overlap$MeanOverlap[3] )
    dice3 <- append( dice3, overlap$MeanOverlap[4] )
    dice4 <- append( dice4, overlap$MeanOverlap[5] )

    ## Do El Bicho

    cat( "       el bicho...\n" )

    imageFile <- paste0( outputPrefixSimulation, "ElBicho.nii.gz" )
    if( ! file.exists( imageFile ) )
      {
      elBichoSegmentation <- groupClusters( elBichoLungSegmentation( transformedImage, mask ) )
      antsImageWrite( elBichoSegmentation, imageFile )
      } else {
      elBichoSegmentation <- antsImageRead( imageFile )
      }
    histogramFile <- paste0( outputPrefixSimulation, "ElBicho.pdf" )
    if( ! file.exists( histogramFile ) )
      {
      makeSegmentationHistogram( transformedImage, elBichoSegmentation, histogramFile, TRUE )
      }

    simulationNumber <- append( simulationNumber, j )
    diagnosis <- append( diagnosis, subjectDiagnosis )
    subject <- append( subject, subjectId )
    segmentation <- append( segmentation, "ElBicho" )

    vdp <-  append( vdp,
      length( elBichoSegmentation[elBichoSegmentation == 1] ) / length( mask[mask == 1] ) )
    overlap <- labelOverlapMeasures( elBichoSegmentationOriginal, elBichoSegmentation )
    diceAll <- append( diceAll, overlap$MeanOverlap[1] )
    dice1 <- append( dice1, overlap$MeanOverlap[2] )
    dice2 <- append( dice2, overlap$MeanOverlap[3] )
    dice3 <- append( dice3, overlap$MeanOverlap[4] )
    dice4 <- append( dice4, overlap$MeanOverlap[5] )

    # Do kmeans

    cat( "       hierarchical kmeans...\n" )

    imageFile <- paste0( outputPrefixSimulation, "KMeans.nii.gz" )
    if( ! file.exists( imageFile ) )
      {
      kmeansSegmentation <- groupClusters( kirbyKmeansLungSegmentation( transformedImage, mask ) )
      antsImageWrite( kmeansSegmentation, imageFile )
      } else {
      kmeansSegmentation <- antsImageRead( imageFile )
      }
    histogramFile <- paste0( outputPrefixSimulation, "KmeansHistogram.pdf" )
    if( ! file.exists( histogramFile ) )
      {
      makeSegmentationHistogram( transformedImage, kmeansSegmentation, histogramFile, TRUE )
      }

    simulationNumber <- append( simulationNumber, j )
    diagnosis <- append( diagnosis, subjectDiagnosis )
    subject <- append( subject, subjectId )
    segmentation <- append( segmentation, "Kmeans" )

    vdp <-  append( vdp,
      length( kmeansSegmentation[kmeansSegmentation == 1] ) / length( mask[mask == 1] ) )
    overlap <- labelOverlapMeasures( kmeansSegmentationOriginal, kmeansSegmentation )
    diceAll <- append( diceAll, overlap$MeanOverlap[1] )
    dice1 <- append( dice1, overlap$MeanOverlap[2] )
    dice2 <- append( dice2, overlap$MeanOverlap[3] )
    dice3 <- append( dice3, overlap$MeanOverlap[4] )
    dice4 <- append( dice4, overlap$MeanOverlap[5] )
    }

  #
  # Visualization
  #

  if( i < 2 )
    {
    next
    }

  similarityResults <- data.frame( SubjectID = simSubject,
                                   Dx = simDiagnosis,
                                   Simulation = simSimulationNumber,
                                   SSIM = ssim,
                                   Minkowski1 = minkowskiDist1,
                                   Minkowski2 = minkowskiDist2,
                                   intersectDist = intersectDist,
                                   Correlation = pearson,
                                   ChiSq = chi
                                   )
  write.csv( similarityResults, file = paste0( baseDirectory, "similarityStudy.csv" ), row.names = FALSE )

  nonlinearResults <- data.frame( SubjectID = subject,
                                  Dx = diagnosis,
                                  Simulation = simulationNumber,
                                  Segmentation = segmentation,
                                  VDP = vdp,
                                  DiceAll = diceAll,
                                  Dice1 = dice1,
                                  Dice2 = dice2,
                                  Dice3 = dice3,
                                  Dice4 = dice4 )
  write.csv( nonlinearResults, file = paste0( baseDirectory, "varianceStudy.csv" ), row.names = FALSE )

  nonlinearResults <- read.csv( paste0( baseDirectory, "varianceStudy.csv" ) )

  dxTypes <- unique( nonlinearResults$Dx )
  for( l in seq.int( length( dxTypes ) ) )
    {
    dxResults <- nonlinearResults[which( nonlinearResults$Dx == dxTypes[l] ),]

    plotDataFrame <- data.frame( SubjectID = as.factor( dxResults$SubjectID ),
                                Pipeline = dxResults$Segmentation,
                                VDP = dxResults$Dice1,
                                Dice = dxResults$DiceAll )
    vdpVariancePlot <- ggplot( data = plotDataFrame ) +
                      geom_boxplot( aes( x = SubjectID, y = VDP, fill = Pipeline ) )  +
                      theme( axis.text.x = element_text( angle = 45 ) ) +
                      ggtitle( paste0( "Per subject:  ", dxTypes[l] ) )
    ggsave( filename = paste0( baseDirectory, "vdpVarianceStudy_", dxTypes[l], ".pdf" ),
      plot = vdpVariancePlot, width = 7, height = 4, units = 'in' )

    diceVariancePlot <- ggplot( data = plotDataFrame ) +
                      geom_boxplot( aes( x = SubjectID, y = Dice, fill = Pipeline ) )  +
                      theme( axis.text.x = element_text( angle = 45 ) ) +
                      ggtitle( paste0( "Per subject:  ", dxTypes[l] ) )
    ggsave( filename = paste0( baseDirectory, "diceVarianceStudy_", dxTypes[l], ".pdf" ),
      plot = diceVariancePlot, width = 7, height = 4, units = 'in' )
    }


  subjects <- unique( nonlinearResults$SubjectID )
  pipelines <- unique( nonlinearResults$Segmentation )

  for( l in seq.int( length( dxTypes ) ) )
    {
    dxResults <- nonlinearResults[which( nonlinearResults$Dx == dxTypes[l] ),]

    vdpSd <- c()
    diceMean <- c()
    pipeline <- c()
    for( m in seq.int( length( subjects ) ) )
      {
      for( n in seq.int( length( pipelines ) ) )
        {
        vdpSd <- append( vdpSd,
          sd( dxResults$VDP[which( dxResults$SubjectID == subjects[m] & dxResults$Segmentation == pipelines[n] )] ) )
        pipeline <- append( pipeline, pipelines[n] )
        diceMean <- append( diceMean,
          mean( dxResults$DiceAll[which( dxResults$SubjectID == subjects[m] & dxResults$Segmentation == pipelines[n] )] ) )
        }
      }

    plotDataFrame <- data.frame( Pipeline = pipeline,
                                VDP.sd = vdpSd,
                                Dice.mean = diceMean )
    vdpSdPlot <- ggplot( data = plotDataFrame ) +
                      geom_boxplot( aes( x = Pipeline, y = VDP.sd, fill = Pipeline ) ) +
                      ggtitle( paste0( "Overall:  ", dxTypes[l] ) ) +
                      ylim( 0, 0.05 )
    ggsave( filename = paste0( baseDirectory, "vdpSdOverall_", dxTypes[l], ".pdf" ),
      plot = vdpSdPlot, width = 5, height = 4, units = 'in' )
    diceMeanPlot <- ggplot( data = plotDataFrame ) +
                      geom_boxplot( aes( x = Pipeline, y = Dice.mean, fill = Pipeline ) ) +
                      ggtitle( paste0( "Overall:  ", dxTypes[l] ) )
    ggsave( filename = paste0( baseDirectory, "diceMeanOverall_", dxTypes[l], ".pdf" ),
      plot = diceMeanPlot, width = 5, height = 4, units = 'in' )
    }


  vdpSd <- c()
  diceMean <- c()
  pipeline <- c()
  dxResults <- nonlinearResults
  for( m in seq.int( length( subjects ) ) )
    {
    for( n in seq.int( length( pipelines ) ) )
      {
      vdpSd <- append( vdpSd,
        sd( dxResults$VDP[which( dxResults$SubjectID == subjects[m] & dxResults$Segmentation == pipelines[n] )] ) )
      pipeline <- append( pipeline, pipelines[n] )
      diceMean <- append( diceMean,
        mean( dxResults$DiceAll[which( dxResults$SubjectID == subjects[m] & dxResults$Segmentation == pipelines[n] )] ) )
      }
    }

  plotDataFrame <- data.frame( Pipeline = pipeline,
                              VDP.sd = vdpSd,
                              Dice.Mean = diceMean )
  vdpSdPlot <- ggplot( data = plotDataFrame ) +
                    geom_boxplot( aes( x = Pipeline, y = VDP.sd, fill = Pipeline ) ) +
                    ggtitle( paste0( "Overall" ) ) +
                      ylim( 0, 0.05 )
  ggsave( filename = paste0( baseDirectory, "vdpSdOverall.pdf" ),
    plot = vdpSdPlot, width = 5, height = 4, units = 'in' )

  diceMeanPlot <- ggplot( data = plotDataFrame ) +
                    geom_boxplot( aes( x = Pipeline, y = Dice.Mean, fill = Pipeline ) ) +
                    ggtitle( paste0( "Overall" ) )
  ggsave( filename = paste0( baseDirectory, "diceMeanOverall.pdf" ),
    plot = diceMeanPlot, width = 5, height = 4, units = 'in' )
  }

