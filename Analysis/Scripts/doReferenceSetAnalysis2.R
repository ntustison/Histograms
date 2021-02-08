library( ANTsR )
library( ggplot2 )
library( reshape2 )


useN4Images <- TRUE
useOldHealthy <- FALSE

source( "./lungSegmentationAlgorithms.R" )
source( "./lungSegmentationUtilities.R" )

baseDirectory <- './'
dataDirectory <- paste0( baseDirectory, "../Data/Nifti/")
figuresDirectory <- paste0( baseDirectory, "../../Text/Figures/" )

csvFile <- paste0( dataDirectory, "../referenceSetOutputVariance.csv" )

if( ! file.exists( csvFile ) )
  {


  ##############################################
  #
  # Processing --- get randomized reference distributions
  #


  referenceYoungImageFiles <- list.files( path = paste0( dataDirectory, "YoungHealthy" ), pattern = "LungMask.nii.gz",
    recursive = TRUE, full.names = TRUE )
  referenceOldImageFiles <- list.files( path = paste0( dataDirectory, "OldHealthy" ), pattern = "LungMask.nii.gz",
    recursive = TRUE, full.names = TRUE )

  referenceImageFiles <- c( referenceYoungImageFiles )
  if( useOldHealthy )
    {
    referenceImageFiles <- append( referenceImageFiles, referenceOldImageFiles )
    }

  gasFiles <- list.files( path = dataDirectory, pattern = "N4.nii.gz",
    recursive = TRUE, full.names = TRUE )
  maskFiles <- gsub( "N4", "LungMask", gasFiles )
  if( useN4Images == FALSE )
    {
    gasFiles <- gsub( "N4", "", gasFiles )
    }

  combinations <- list()
  for( i in seq.int( length( referenceImageFiles ) ) )
    {
    combinations[[i]] <- combn( length( referenceImageFiles ), i )
    }

  iterationNumberOfFiles <- c()
  iterationMean <- c()
  iterationStandardDeviation <- c()

  count <- 1
  vps <- matrix()

  for( m in seq.int( length( combinations ) ) )
    {
    if( m < 8 )
      {
      next
      }
    cat( "Analyzing combination ", m, " of ", length( combinations ), "\n" )
    for( n in seq.int( ncol( combinations[[m]] ) ) )
      {
      fileIndices <- combinations[[m]][, n]
      numberOfFiles <- length( fileIndices )

      imageList <- list()
      maskList <- list()

      # compute reference distribution

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
      referenceDistribution <- calculateReferenceDistributionForLinearBinning( imageList, maskList )

      # use the current reference distribution to generate the segmentations
      pb <- txtProgressBar( min = 0, max = length( gasFiles ), style = 3 )
      for( i in seq.int( length( gasFiles ) ) )
        {
        tokens <- strsplit( gasFiles[i], "/" )
        subjectDiagnosis <- tokens[[1]][6]
        subjectId <- tokens[[1]][7]

        image <- antsImageRead( gasFiles[i] )
        mask <- antsImageRead( maskFiles[i] )

        imageVector <- image[mask != 0]

        thresholdValue <- quantile( imageVector, 0.99 )[[1]]
        image[image > thresholdValue] <- thresholdValue
        image <- image %>% iMath( "Normalize" )

        segmentation <- linearBinningLungSegmentation(
          image, mask, referenceDistribution$mean, referenceDistribution$standardDeviation )

        clusterGeoms <- rep( 0, 6 )
        geoms <- labelGeometryMeasures( segmentation )

        for( j in seq.int( nrow( geoms ) ) )
          {
          clusterGeoms[geoms$Label[j]] <- geoms$VolumeInMillimeters[j]
          }
        vp <- clusterGeoms / sum( clusterGeoms )

        if( count == 1 )
          {
          vps <- c( m, subjectId, subjectDiagnosis, vp )
          } else {
          vps <- rbind( vps, c( m, subjectId, subjectDiagnosis, vp ) )
          }
        count <- count + 1
        setTxtProgressBar( pb, i )
        }
      cat( "\n" )
      }
    }

  vpDataFrame <- as.data.frame( vps )
  colnames( vpDataFrame ) <- c( "Combination", "SubjectId", "Diagnosis", paste0( "Cluster", 1:6 ) )

  write.csv( vpDataFrame, file = paste0( dataDirectory, "../referenceSetOutputVariance.csv" ), row.names = FALSE )

  vpDataFrame$Cluster1 <- as.numeric( vpDataFrame$Cluster1 )
  vpDataFrame$Cluster2 <- as.numeric( vpDataFrame$Cluster2 )
  vpDataFrame$Cluster3 <- as.numeric( vpDataFrame$Cluster3 )
  vpDataFrame$Cluster4 <- as.numeric( vpDataFrame$Cluster4 )
  vpDataFrame$Cluster5 <- as.numeric( vpDataFrame$Cluster5 )
  vpDataFrame$Cluster6 <- as.numeric( vpDataFrame$Cluster6 )
  } else {
  vpDataFrame <- read.csv( csvFile )

  vpDataFrame$Cluster1 <- as.numeric( vpDataFrame$Cluster1 )
  vpDataFrame$Cluster2 <- as.numeric( vpDataFrame$Cluster2 )
  vpDataFrame$Cluster3 <- as.numeric( vpDataFrame$Cluster3 )
  vpDataFrame$Cluster4 <- as.numeric( vpDataFrame$Cluster4 )
  vpDataFrame$Cluster5 <- as.numeric( vpDataFrame$Cluster5 )
  vpDataFrame$Cluster6 <- as.numeric( vpDataFrame$Cluster6 )
  }



minMaxRangeData <- matrix()

subjectIds <- unique( vpDataFrame$SubjectId )
combinations <- unique( vpDataFrame$Combination )
for( i in seq.int( length( subjectIds ) ) )
  {
  subjectData <- vpDataFrame[which( vpDataFrame$SubjectId == subjectIds[i] ),]
  clusterMinMaxRange <- rep( 0, 6 )
  for( j in seq.int( 6 ) )
    {
    clusterMinMaxRange[j] <- max( subjectData[,3+j] ) - min( subjectData[,3+j] )
    }
  subjectMinMaxData <- c( subjectIds[i], subjectData$Diagnosis[1], clusterMinMaxRange )
  if( i == 1 )
    {
    minMaxRangeData <- subjectMinMaxData
    } else {
    minMaxRangeData <- rbind( minMaxRangeData, subjectMinMaxData )
    }
  }
minMaxRangeData <- as.data.frame( minMaxRangeData )
colnames( minMaxRangeData ) <- c( "SubjectId", "Dx", paste0( "Cluster", 1:6 ) )

minMaxRangeData$Dx <- factor( minMaxRangeData$Dx, levels = c( "YoungHealthy", "OldHealthy", "CF", "COPD", "ILD" ) )

minMaxRangeDataMelted <- melt( minMaxRangeData, id.vars = c( "SubjectId", "Dx" ), measured.vars = c( paste0( "Cluster", 1:6 ) ) )
colnames( minMaxRangeDataMelted ) <- c( "SubjectId", "Dx", "Cluster", "MinMaxRange" )
minMaxRangeDataMelted$MinMaxRange <- as.numeric( minMaxRangeDataMelted$MinMaxRange )

minMaxRangePlot <- ggplot( data = minMaxRangeDataMelted, aes( x = Cluster, y = 100 * MinMaxRange ) ) +
                     geom_point( aes( fill = Dx ), colour = "black", shape = 21, size = 1, alpha = 0.75, position = position_jitterdodge() ) +
                     geom_boxplot( aes( fill = Dx ), alpha = 0.65, outlier.shape = NA ) +
                     xlab( "" ) +
                     ylab( "Min/max range %" ) +
                    theme( legend.position = "right" )
ggsave( filename = paste0( figuresDirectory, "minMaxRangePlot.pdf" ),
    plot = minMaxRangePlot, width = 10, height = 4, units = 'in' )
