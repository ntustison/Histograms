library( ANTsR )
library( randomForest )
library( ggplot2 )
library( MASS )
library( popbio )
library( gdata )
library( ROCR )
library( pROC )

##############################################
#
# Options
#

numberOfRuns <- 100
trainingPortion <- 0.8
verbose <- TRUE

source( "./lungSegmentationAlgorithms.R" )
source( "./lungSegmentationUtilities.R" )

baseDirectory <- './'

# Here, we are simply using the original segmentations which don't have
# any MR artefacts applied.
dataDirectory <- paste0( baseDirectory, "../Data/SimulationExperiments_Noise")
figuresDirectory <- paste0( baseDirectory, "../../Text/Figures/" )

##############################################
#
# Processing
#


pipelineType <- c( "LinearBinning", "KMeans", "Fuzzy", "Atropos", "ElBicho" )
diagnosisType <- c( "CF", "COPD", "ILD" )

allPredictions <- list()

for( l in seq.int( length( diagnosisType ) ) )
  {
  cat( diagnosisType[l], " vs. ", "Healthy\n" )
  rfImportance <- list()
  for( p in seq.int( length( pipelineType ) ) )
    {
    allPredictions[[p]] <- NA
    cat( "Processing", pipelineType[p], "\n" )

    segmentationFiles <- list.files( path = dataDirectory,
      pattern = paste0( "*N4_", pipelineType[p], ".nii.gz" ),
      recursive = TRUE, full.names = TRUE )

    ##############################################
    #
    # Organize the data
    #

    actualDiagnosis <- c()
    volumesClass1 <- c()
    volumesClass2 <- c()
    volumesClass3 <- c()

    for( i in seq.int( length( segmentationFiles ) ) )
      {
      if( ! grepl( diagnosisType[l], segmentationFiles[i], fixed = TRUE ) &&
          ! grepl( "Healthy", segmentationFiles[i], fixed = TRUE ) )
        {
        next
        }
      image <- groupClusters( antsImageRead( segmentationFiles[i] ) )
      labels <- 1:3

      voxelResolution <- prod( antsGetSpacing( image ) )
      volumes <- rep( 0, length( labels ) )
      for( ii in seq.int( length( labels ) ) )
        {
        volumes[ii] <- voxelResolution * length( image[image == labels[ii]] )
        }
      geom <- data.frame( Label = labels, VolumeInMillimeters = volumes )
      # geom <- labelGeometryMeasures( image )

      totalVolume <- sum( geom$VolumeInMillimeters )

      if( any( geom$Label == 1 ) )
        {
        volumesClass1 <- append( volumesClass1, geom$VolumeInMillimeters[which( geom$Label == 1 )] / totalVolume )
        } else {
        volumesClass1 <- append( volumesClass1, 0 )
        }
      if( any( geom$Label == 2 ) )
        {
        volumesClass2 <- append( volumesClass2, geom$VolumeInMillimeters[which( geom$Label == 2 )] / totalVolume )
        } else {
        volumesClass2 <- append( volumesClass2, 0 )
        }
      if( any( geom$Label == 3 ) )
        {
        volumesClass3 <- append( volumesClass3, geom$VolumeInMillimeters[which( geom$Label == 3 )] / totalVolume )
        } else {
        volumesClass3 <- append( volumesClass3, 0 )
        }

      tokens <- strsplit( segmentationFiles[i], "/" )
      diagnosis <- gsub( "Old", "", tokens[[1]][5] )
      diagnosis <- gsub( "Young", "", diagnosis )
      actualDiagnosis <- append( actualDiagnosis, diagnosis )
      }
    actualDiagnosis <- factor( actualDiagnosis )

    ##############################################
    #
    # Run simulations
    #

    diagnosis <- actualDiagnosis

    if( verbose )
      {
      pb <- txtProgressBar( min = 1, max = numberOfRuns, style = 3 )
      }
    for( i in seq.int( numberOfRuns ) )
      {
      trainingIndices <- sample.int( length( diagnosis ), size = floor( trainingPortion * length( diagnosis ) ) )
      if( length( unique( diagnosis[-trainingIndices] ) ) == 1 )
        {
        next
        }

      trainingData <- data.frame( diagnosis = factor( diagnosis[trainingIndices] ),
                                  Class1 = volumesClass1[trainingIndices],
                                  Class2 = volumesClass2[trainingIndices],
                                  Class3 = volumesClass3[trainingIndices] )
      testingData <- data.frame(  Class1 = volumesClass1[-trainingIndices],
                                  Class2 = volumesClass2[-trainingIndices],
                                  Class3 = volumesClass3[-trainingIndices] )

      rf <- randomForest( diagnosis ~ ., data = trainingData, importance = TRUE )

      # if( i == 1 )
      #   {
      #   rfImportance[[p]] <- importance( rf, type = 1 )
      #   } else {
      #   rfImportance[[p]] <- rfImportance[[p]] + importance( rf, type = 1 )
      #   }

      predictions <- as.data.frame( predict( rf, newdata = testingData, type = "prob" ) )

      predictions$predict <- colnames( predictions )[1:2][apply( predictions[,1:2], 1, which.max )]
      predictions$observed <- diagnosis[-trainingIndices]
      predictions$pipeline <- rep( pipelineType[p], nrow( predictions ) )

      if( all( is.na( allPredictions[[p]] ) ) )
        {
        allPredictions[[p]] <- predictions
        } else {
        allPredictions[[p]] <- rbind( allPredictions[[p]], predictions )
        }

      # confusion <- confusionMatrix( as.factor( predictions ),
      #                               as.factor( diagnosis[-trainingIndices] ) )
      # acc <- append( acc, confusion$overall['Accuracy'] )
      # cs <- append( cs, clusterStrategies[h] )
      # dx <- append( dx, diagnosisType[l] )
      # pvalues <- append( pvalues, confusion$overall[6] )
      # pipeline <- append( pipeline, pipelineType[p] )

      # gl <- glm( diagnosis ~ ., data = trainingData, family = "binomial" )
      # predictions <- predict( gl, newdata = testingData, type = "response" )
      # glPredictionROC <- prediction( predictions, diagnosis[-trainingIndices] )
      # glPerformanceROC <- performance( glPredictionROC, "tpr", "fpr" )
      # auc <- performance( glPredictionROC, "auc" )@y.values[[1]]
      # fprRun <- glPerformanceROC@x.values[[1]]
      # tprRun <- glPerformanceROC@y.values[[1]]
      # if( i == 1 )
      #   {
      #   fpr <- fprRun
      #   tpr <- tprRun
      #   } else {
      #   myApprox <- approx( fprRun, tprRun, n = length( tpr ) )
      #   fpr <- fpr + ( myApprox$x - fpr ) / ( i + 1 )
      #   tpr <- tpr + ( myApprox$y - tpr ) / ( i + 1 )
      #   }

      if( verbose )
        {
        setTxtProgressBar( pb, i )
        }
      }
    if( verbose )
      {
      cat( "\n" )
      }

    # aucOneData <- data.frame( Pipeline = rep( pipelineType[p] ),
    #                           Diagnosis = rep( diagnosisType[l] ),
    #                           FPR = fpr, TPR = tpr )

    # aucData <- rbind( aucData, aucOneData )
    }

  roc.dx <- list()
  for( p in seq.int( length( allPredictions ) ) )
    {
    roc.dx[[p]] <- roc( allPredictions[[p]]$observed, as.numeric( allPredictions[[p]][,1] ) )
    cat( pipelineType[p], ": AUC = ", roc.dx[[p]]$auc, "\n", sep = "" )
    }
  g <- ggroc( list( LinearBinning = roc.dx[[1]], Kmeans = roc.dx[[2]], Fuzzy = roc.dx[[3]], Atropos = roc.dx[[4]], ElBicho = roc.dx[[5]] ), size = 1, legacy.axes = "TRUE" ) +
    geom_abline( intercept = 0, slope = 1, color = "darkgrey", linetype = "dashed" ) +
    labs( color = "Pipeline" ) +
    ggtitle( paste0( diagnosisType[l], " vs. Healthy" ) ) +
    theme( legend.position = "bottom" ) +
    theme( legend.title = element_blank() )

  ggsave( paste0( figuresDirectory, "/volumeXRocDx", diagnosisType[l], ".pdf" ), g, width = 5, height = 5, units = "in" )

  # Plot importance

  # for( p in seq.int( length( rfImportance ) ) )
  #   {
  #   rfImportance[[p]] <- rfImportance[[p]] / numberOfRuns
  #   rfImportance.df <- data.frame( Statistic = rownames( rfImportance[[p]] ), Importance = as.numeric( rfImportance[[p]][,1] ) )
  #   rfImportance.df <- rfImportance.df[order( rfImportance.df$Statistic, decreasing = TRUE ),]
  #   rfImportance.df$Statistic <- factor( x = rfImportance.df$Statistic, levels = rfImportance.df$Statistic )

  #   localColormap <-  rev( c( "red", "green", "blue", "yellow", "cyan", "magenta" ) )
  #   if( length( rfImportance.df$Statistic ) == 3 )
  #     {
  #     localColormap <-  rev( c( "red", "green", "magenta" ) )
  #     }

  #   importancePlot <- ggplot( data = rfImportance.df, aes( x = Importance, y = Statistic ) ) +
  #                     geom_point( aes( fill = Statistic ), shape = 21, colour = "black", stroke = 1, size = 4, alpha = 1.0 ) +
  #                     ylab( "" ) +
  #                     scale_fill_manual( values = localColormap ) +
  #                     theme( axis.text.x = element_text( size = 8 ) ) +
  #                     theme( axis.text.y = element_text( size = 8 ) ) +
  #                     theme( axis.title = element_text( size = 7 ) ) +
  #                     theme( legend.position = "none" ) +
  #                     ggtitle( pipelineType[p] )
  #   ggsave( file = paste0( figuresDirectory, "/impX", pipelineType[p], "_", diagnosisType[l], ".pdf" ),
  #           importancePlot, width = 2.5, height = 4, units = "in" )

  #   }
  }

# analysis <- data.frame( Accuracy = acc,
#                         pvalue = pvalues,
#                         DiagnosisVsHealthy = factor( dx, levels = diagnosisType ),
#                         Pipeline = factor( pipeline, levels = pipelineType ) )

# analysisPlot <- ggplot( data = analysis ) +
#   geom_violin( aes( x = DiagnosisVsHealthy, y = Accuracy, fill = Pipeline ), adjust = 2.25 ) +
#   ylab( "Accuracy" ) +
#   ggtitle( paste0( "Dx vs. healthy classification:  Accuracy" ) )
# ggsave( paste0( "~/Desktop/volumetricAnalysis.pdf" ), analysisPlot,
#   width = 6, height = 4, units = "in" )

# pvaluePlot <- ggplot( data = analysis ) +
#   geom_violin( aes( x = DiagnosisVsHealthy, y = pvalue, fill = Pipeline ), adjust = 2.25 ) +
#   ylab( "p-value" ) +
#   ggtitle( paste0( "Dx vs. healthy classification:  p-value" ) )
# ggsave( paste0( "~/Desktop/pvalueAnalysis.pdf" ), pvaluePlot,
#   width = 6, height = 4, units = "in" )


