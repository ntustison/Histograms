library( ANTsR )
library( stapler )

###############
#
#  THe problem with this analysis is that it's not clear that the cluster
#  definitions across algorithms are even close to the same.
#


source( "./lungSegmentationUtilities.R" )

baseDirectory <- './'
dataDirectory <- paste0( baseDirectory, "../Data/Nifti/")
figuresDirectory <- paste0( baseDirectory, "../../Text/Figures/" )

gasFiles <- list.files( path = dataDirectory, pattern = "N4.nii.gz",
  recursive = TRUE, full.names = TRUE )

segmentationTypes <- c( "LinearBinning", "KMeans", "Atropos", "ElBicho" )

segmentationTypeNames <- t( rbind( segmentationTypes, segmentationTypes, segmentationTypes, segmentationTypes ) )

stapleColnames <- c( "Cluster0", "Cluster1", "Cluster2", "Cluster3" )
stapleColnames <- rep( stapleColnames, 4 )

for( i in seq.int( length( gasFiles ) ) )
  {
  tokens <- strsplit( gasFiles[i], "/" )
  subjectDiagnosis <- tokens[[1]][6]
  subjectId <- tokens[[1]][7]

  cat( "Subject:  ", subjectId, "(", i, "out of", length( gasFiles ), ")\n" )

  inputDirectory <- dirname( sub( "Nifti", "SimulationExperiments_Noise", dirname( gasFiles[i] ) ) )
  filePrefix <- paste0( inputDirectory, "/", sub( ".nii.gz", "", basename( gasFiles[i] ) ) )

  outputDirectory <- dirname( sub( "Nifti", "STAPLE", dirname( gasFiles[i] ) ) )
  if( ! dir.exists( outputDirectory ) )
    {
    dir.create( outputDirectory, recursive = TRUE )
    }
  stapleFile <- paste0( outputDirectory, "/", basename( paste0( filePrefix, "_STAPLE.Robj" ) ) )
  if( file.exists( stapleFile ) )
    {
    load( stapleFile )

    if( i == 1 )
      {
      stapleSpecificity <- cbind( as.vector( t( segmentationTypeNames ) ),
                                  as.vector( t( stapleColnames ) ),
                                  as.vector( t( stapleVentilation$specificity ) ) )

      stapleSensitivity <- cbind( as.vector( t( segmentationTypeNames ) ),
                                  as.vector( t( stapleColnames ) ),
                                  as.vector( t( stapleVentilation$sensitivity ) ) )

      } else {
      stapleSpecificity <- rbind( stapleSpecificity,
                           cbind( as.vector( t( segmentationTypeNames ) ),
                                  as.vector( t( stapleColnames ) ),
                                  as.vector( t( stapleVentilation$specificity ) ) ) )

      stapleSensitivity <- rbind( stapleSensitivity,
                           cbind( as.vector( t( segmentationTypeNames ) ),
                                  as.vector( t( stapleColnames ) ),
                                  as.vector( t( stapleVentilation$sensitivity ) ) ) )
      }
    next
    }

  niftiFiles <- c()
  for( j in seq.int( length( segmentationTypes ) ) )
    {
    imageFile <- paste0( filePrefix, "_", segmentationTypes[j], ".nii.gz" )
    tmpImage <- groupClusters( antsImageRead( imageFile ) )
    tmpFilename <- tempfile( pattern = segmentationTypes[j], fileext = ".nii.gz" )
    antsImageWrite( tmpImage, tmpFilename )
    niftiFiles[j] <- tmpFilename
    }

  stapleVentilation <- staple( niftiFiles )
  save( stapleVentilation, file = stapleFile )

  if( i == 1 )
    {
    stapleSpecificity <- cbind( as.vector( t( segmentationTypeNames ) ),
                                as.vector( t( stapleColnames ) ),
                                as.vector( t( stapleVentilation$specificity ) ) )

    stapleSensitivity <- cbind( as.vector( t( segmentationTypeNames ) ),
                                as.vector( t( stapleColnames ) ),
                                as.vector( t( stapleVentilation$sensitivity ) ) )

    } else {
    stapleSpecificity <- rbind( stapleSpecificity,
                          cbind( as.vector( t( segmentationTypeNames ) ),
                                as.vector( t( stapleColnames ) ),
                                as.vector( t( stapleVentilation$specificity ) ) ) )

    stapleSensitivity <- rbind( stapleSensitivity,
                          cbind( as.vector( t( segmentationTypeNames ) ),
                                as.vector( t( stapleColnames ) ),
                                as.vector( t( stapleVentilation$sensitivity ) ) ) )
    }
  }

colnames( stapleSensitivity ) <- c( "Segmentation", "Cluster", "Sensitivity" )
colnames( stapleSpecificity ) <- c( "Segmentation", "Cluster", "Specificity" )

stapleSensitivity <- as.data.frame( stapleSensitivity )
stapleSpecificity <- as.data.frame( stapleSpecificity )

stapleSensitivity$Segmentation <- factor( stapleSensitivity$Segmentation, levels = segmentationTypes )
stapleSensitivity$Cluster <- factor( stapleSensitivity$Cluster, levels = c( "Cluster0", "Cluster1", "Cluster2", "Cluster3" ) )
stapleSensitivity$Sensitivity <- as.numeric( stapleSensitivity$Sensitivity )

stapleSpecificity$Segmentation <- factor( stapleSpecificity$Segmentation, levels = segmentationTypes )
stapleSpecificity$Cluster <- factor( stapleSpecificity$Cluster, levels = c( "Cluster0", "Cluster1", "Cluster2", "Cluster3" ) )
stapleSpecificity$Specificity <- as.numeric( stapleSpecificity$Specificity )


staplePlot <- ggplot( data = stapleSensitivity ) +
                    geom_boxplot( aes( x = Cluster, y = Sensitivity, fill = Segmentation ) ) +
                    ylim( c( 0.0, 1.0 ) ) +
                    xlab( "" ) +
                    ylab( "Sensitivity" ) +
                    theme( legend.position = "bottom" )
ggsave( filename = paste0( figuresDirectory, "stapleStudySensitivity.pdf" ),
    plot = staplePlot, width = 7, height = 4, units = 'in' )


staplePlot <- ggplot( data = stapleSpecificity ) +
                    geom_boxplot( aes( x = Cluster, y = Specificity, fill = Segmentation ) ) +
                    ylim( c( 0.0, 1.0 ) ) +
                    xlab( "" ) +
                    ylab( "Specificity" ) +
                    theme( legend.position = "bottom" )
ggsave( filename = paste0( figuresDirectory, "stapleStudySpecificity.pdf" ),
    plot = staplePlot, width = 7, height = 4, units = 'in' )
