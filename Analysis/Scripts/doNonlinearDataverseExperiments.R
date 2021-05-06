library( ANTsR )
library( ANTsRNet )
library( ggplot2 )
library( HistogramTools )

# User parameters

numberOfSimulationsPerImage <- 10
sdDisplacements <- 0.175

outputDirectoryNames <- c( "SimulationExperiments_Dataverse_Noise",
                           "SimulationExperiments_Dataverse_Nonlinearities",
                           "SimulationExperiments_Dataverse_NoiseAndNonlinearities" )
artefacts <- list()
artefacts[[1]] <- c( TRUE, FALSE )
artefacts[[2]] <- c( FALSE, TRUE )
artefacts[[3]] <- c( TRUE, TRUE )

#######################################################################
#
#
#
#######################################################################

source( "./lungSegmentationAlgorithms.R" )
source( "./lungSegmentationUtilities.R" )

baseDirectory <- './'
dataDirectory <- paste0( baseDirectory, "../Data/He2019_Dataverse/Nifti")
figuresDirectory <- paste0( baseDirectory, "../../Text/FiguresX/" )

gasFiles <- list.files( path = dataDirectory, pattern = "Noise_1.nii.gz",
  recursive = TRUE, full.names = TRUE )
maskFiles <- gsub( "XeVent_Noise_1", "GRE1L_lungsmask", gasFiles )

for( s in seq.int( length( artefacts ) ) )
  {
  doNoise <- artefacts[[s]][1]
  doNonlinearities <- artefacts[[s]][2]

  outputDirectoryName <- outputDirectoryNames[s]

  #################
  #
  # Calculate reference distribution for linear binning
  #

  # referenceYoungMaskFiles <- list.files( path = paste0( dataDirectory, "YoungHealthy" ), pattern = "LungMask.nii.gz",
  #   recursive = TRUE, full.names = TRUE )
  # referenceOldMaskFiles <- list.files( path = paste0( dataDirectory, "OldHealthy" ), pattern = "LungMask.nii.gz",
  #   recursive = TRUE, full.names = TRUE )

  # referenceMaskFiles <- c( referenceYoungMaskFiles )
  # if( useOldHealthy )
  #   {
  #   referenceMaskFiles <- append( referenceMaskFiles, referenceOldMaskFiles )
  #   }

  # referenceImageFiles <- ""
  # if( useN4Images == TRUE )
  #   {
  #   referenceImageFiles <- gsub( "LungMask", "N4", referenceMaskFiles )
  #   } else {
  #   referenceImageFiles <- gsub( "LungMask", "", referenceMaskFiles )
  #   }

  # imageList <- imageFileNames2ImageList( referenceImageFiles )
  # maskList <- imageFileNames2ImageList( referenceMaskFiles )
  # referenceDistribution <- calculateReferenceDistributionForLinearBinning( imageList, maskList )

  # These values are from He, 2016 (Figure 2 caption).
  referenceDistribution <- list()
  referenceDistribution$mean <- 0.52
  referenceDistribution$standardDeviation <- 0.18

  #################
  #
  # Perform simulations
  #

  subject <- c()
  simulationNumber <- c()
  segmentation <- c()
  vdp <- c()
  diceAll <- c()
  dice1 <- c()
  dice2 <- c()
  dice3 <- c()

  simSubject <- c()
  simSimulationNumber <- c()
  ssim <- c()
  minkowskiDist1 <- c()
  minkowskiDist2 <- c()
  intersectDist <- c()
  pearson <- c()
  chi <- c()

  for( i in seq.int( length( gasFiles ) ) )
    {
    tokens <- strsplit( gasFiles[i], "/" )
    subjectId <- tokens[[1]][7]

    cat( "Subject:  ", subjectId, "(", i, "out of", length( gasFiles ), ")\n" )


    image <- antsImageRead( gasFiles[i] )
    mask <- antsImageRead( maskFiles[i] )
    imageVector <- image[mask != 0]

    thresholdValue <- quantile( imageVector, 0.99 )[[1]]
    imageVector[imageVector > thresholdValue] <- thresholdValue
    image[image > thresholdValue] <- thresholdValue

    image <- image %>% iMath( "Normalize" )
    imageVector <- image[mask != 0]

    outputDirectory <- sub( "Nifti", outputDirectoryName, dirname( gasFiles[i] ) )
    if( ! dir.exists( outputDirectory ) )
      {
      dir.create( outputDirectory, recursive = TRUE )
      }
    outputPrefix <- paste0( outputDirectory, "/", sub( ".nii.gz", "", basename( gasFiles[i] ) ) )
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

    histogramOriginal <- hist( imageVector, breaks = seq.int( from = 0, to = 1.0, length.out = 200 ), plot = FALSE )

    # Do linear binning
    cat( "       (original) linear binning...\n" )

    imageFile <- paste0( outputPrefix, "_LinearBinning.nii.gz" )
    if( ! file.exists( imageFile ) )
      {
      linearBinningSegmentationOriginal <- linearBinningLungSegmentation(
        image, mask, referenceDistribution$mean, referenceDistribution$standardDeviation )
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
      atroposSegmentationOriginal <- atroposLungSegmentation( image, mask )
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
      elBichoSegmentationOriginal <- elBichoLungSegmentation( image, mask )
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
      kmeansSegmentationOriginal <- kirbyKmeansLungSegmentation( image, mask )
      antsImageWrite( kmeansSegmentationOriginal, imageFile )
      } else {
      kmeansSegmentationOriginal <- antsImageRead( imageFile )
      }
    histogramFile <- paste0( outputPrefix, "_KmeansHistogram.pdf" )
    if( ! file.exists( histogramFile ) )
      {
      makeSegmentationHistogram( image, kmeansSegmentationOriginal, histogramFile, TRUE )
      }

    # Do fuzzy
    cat( "       (original) fuzzy spatial c-means...\n" )
    imageFile <- paste0( outputPrefix, "_Fuzzy.nii.gz" )
    if( ! file.exists( imageFile ) )
      {
      fuzzySegmentationOriginal <- fuzzySpatialCMeansLungSegmentation( image, mask )
      antsImageWrite( fuzzySegmentationOriginal, imageFile )
      } else {
      fuzzySegmentationOriginal <- antsImageRead( imageFile )
      }
    histogramFile <- paste0( outputPrefix, "_FuzzyHistogram.pdf" )
    if( ! file.exists( histogramFile ) )
      {
      makeSegmentationHistogram( image, fuzzySegmentationOriginal, histogramFile, TRUE )
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

      imageFile <- paste0( outputPrefixSimulation, "LinearBinning.nii.gz" )
      if( ! file.exists( imageFile ) )
        {
        linearBinningSegmentation <- linearBinningLungSegmentation(
          transformedImage, mask, referenceDistribution$mean, referenceDistribution$standardDeviation )
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
      subject <- append( subject, subjectId )
      segmentation <- append( segmentation, "LinearBinning" )

      vdp <-  append( vdp,
        length( linearBinningSegmentation[linearBinningSegmentation == 1] ) / length( mask[mask == 1] ) )
      overlap <- labelOverlapMeasures( groupClusters( linearBinningSegmentationOriginal ),
                                       groupClusters( linearBinningSegmentation ) )
      diceAll <- append( diceAll, overlap$MeanOverlap[1] )
      dice1 <- append( dice1, overlap$MeanOverlap[2] )
      dice2 <- append( dice2, overlap$MeanOverlap[3] )
      dice3 <- append( dice3, overlap$MeanOverlap[4] )

      ## Do Atropos

      cat( "       atropos...\n" )

      imageFile <- paste0( outputPrefixSimulation, "Atropos.nii.gz" )
      if( ! file.exists( imageFile ) )
        {
        atroposSegmentation <- atroposLungSegmentation( transformedImage, mask )
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
      subject <- append( subject, subjectId )
      segmentation <- append( segmentation, "Atropos" )

      vdp <-  append( vdp,
        length( atroposSegmentation[atroposSegmentation == 1] ) / length( mask[mask == 1] ) )
      overlap <- labelOverlapMeasures( groupClusters( atroposSegmentationOriginal ),
                                      groupClusters( atroposSegmentation ) )
      diceAll <- append( diceAll, overlap$MeanOverlap[1] )
      dice1 <- append( dice1, overlap$MeanOverlap[2] )
      dice2 <- append( dice2, overlap$MeanOverlap[3] )
      dice3 <- append( dice3, overlap$MeanOverlap[4] )

      ## Do El Bicho

      cat( "       el bicho...\n" )

      imageFile <- paste0( outputPrefixSimulation, "ElBicho.nii.gz" )
      if( ! file.exists( imageFile ) )
        {
        elBichoSegmentation <- elBichoLungSegmentation( transformedImage, mask )
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
      subject <- append( subject, subjectId )
      segmentation <- append( segmentation, "ElBicho" )

      vdp <-  append( vdp,
        length( elBichoSegmentation[elBichoSegmentation == 1] ) / length( mask[mask == 1] ) )
      overlap <- labelOverlapMeasures( groupClusters( elBichoSegmentationOriginal ),
                                      groupClusters( elBichoSegmentation ) )
      diceAll <- append( diceAll, overlap$MeanOverlap[1] )
      dice1 <- append( dice1, overlap$MeanOverlap[2] )
      dice2 <- append( dice2, overlap$MeanOverlap[3] )
      dice3 <- append( dice3, overlap$MeanOverlap[4] )

      # Do kmeans

      cat( "       hierarchical kmeans...\n" )

      imageFile <- paste0( outputPrefixSimulation, "KMeans.nii.gz" )
      if( ! file.exists( imageFile ) )
        {
        kmeansSegmentation <- kirbyKmeansLungSegmentation( transformedImage, mask )
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
      subject <- append( subject, subjectId )
      segmentation <- append( segmentation, "Kmeans" )

      vdp <-  append( vdp,
        length( kmeansSegmentation[kmeansSegmentation == 1] ) / length( mask[mask == 1] ) )
      overlap <- labelOverlapMeasures( groupClusters( kmeansSegmentationOriginal ),
                                      groupClusters( kmeansSegmentation ) )
      diceAll <- append( diceAll, overlap$MeanOverlap[1] )
      dice1 <- append( dice1, overlap$MeanOverlap[2] )
      dice2 <- append( dice2, overlap$MeanOverlap[3] )
      dice3 <- append( dice3, overlap$MeanOverlap[4] )

      # Do fuzzy
      cat( "       fuzzy spatial c-means...\n" )

      imageFile <- paste0( outputPrefixSimulation, "Fuzzy.nii.gz" )
      if( ! file.exists( imageFile ) )
        {
        fuzzySegmentation <- fuzzySpatialCMeansLungSegmentation( transformedImage, mask )
        antsImageWrite( fuzzySegmentation, imageFile )
        } else {
        fuzzySegmentation <- antsImageRead( imageFile )
        }
      histogramFile <- paste0( outputPrefix, "FuzzyHistogram.pdf" )
      if( ! file.exists( histogramFile ) )
        {
        makeSegmentationHistogram( transformedImage, fuzzySegmentation, histogramFile, TRUE )
        }

      simulationNumber <- append( simulationNumber, j )
      subject <- append( subject, subjectId )
      segmentation <- append( segmentation, "Fuzzy" )

      vdp <-  append( vdp,
        length( fuzzySegmentation[fuzzySegmentation == 1] ) / length( mask[mask == 1] ) )
      overlap <- labelOverlapMeasures( groupClusters( fuzzySegmentationOriginal ),
                                      groupClusters( fuzzySegmentation ) )
      diceAll <- append( diceAll, overlap$MeanOverlap[1] )
      dice1 <- append( dice1, overlap$MeanOverlap[2] )
      dice2 <- append( dice2, overlap$MeanOverlap[3] )
      dice3 <- append( dice3, overlap$MeanOverlap[4] )

      }

    #
    # Visualization
    #

    if( i < 2 )
      {
      next
      }

    similarityResults <- data.frame( SubjectID = simSubject,
                                    Simulation = simSimulationNumber,
                                    SSIM = ssim,
                                    Minkowski1 = minkowskiDist1,
                                    Minkowski2 = minkowskiDist2,
                                    intersectDist = intersectDist,
                                    Correlation = pearson,
                                    ChiSq = chi
                                    )
    write.csv( similarityResults, file = paste0( outputDirectory, "/../similarityStudy.csv" ), row.names = FALSE )

    nonlinearResults <- data.frame( SubjectID = subject,
                                    Simulation = simulationNumber,
                                    Segmentation = segmentation,
                                    VDP = vdp,
                                    DiceAll = diceAll,
                                    Dice1 = dice1,
                                    Dice2 = dice2,
                                    Dice3 = dice3 )
    write.csv( nonlinearResults, file = paste0( outputDirectory, "/../varianceStudy.csv" ), row.names = FALSE )

    nonlinearResults <- read.csv( paste0( outputDirectory, "/../varianceStudy.csv" ) )

    subjects <- unique( nonlinearResults$SubjectID )
    pipelines <- unique( nonlinearResults$Segmentation )
    
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

    # plotDataFrame <- data.frame( Pipeline = pipeline,
    #                             VDP.sd = vdpSd,
    #                             Dice.Mean = diceMean )
    # vdpSdPlot <- ggplot( data = plotDataFrame ) +
    #                   geom_boxplot( aes( x = Pipeline, y = VDP.sd, fill = Pipeline ) ) +
    #                   ggtitle( paste0( "Overall" ) ) +
    #                     ylim( 0, 0.05 )
    # ggsave( filename = paste0( outputDirectory, "/../vdpSdOverall.pdf" ),
    #   plot = vdpSdPlot, width = 5, height = 4, units = 'in' )

    # diceMeanPlot <- ggplot( data = plotDataFrame ) +
    #                   geom_boxplot( aes( x = Pipeline, y = Dice.Mean, fill = Pipeline ) ) +
    #                   ggtitle( paste0( "Overall" ) )
    # ggsave( filename = paste0( outputDirectory, "/../diceMeanOverall.pdf" ),
    #   plot = diceMeanPlot, width = 5, height = 4, units = 'in' )
    }
  }
