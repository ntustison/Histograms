library( ANTsR )
library( ANTsRNet )
library( raster )


baseDirectory <- './'
dataDirectory <- paste0( baseDirectory, "../Data/Nifti/")
figuresDirectory <- paste0( baseDirectory, "../../Text/Figures/" )

types <- c( "CF", "YoungHealthy" )
subjectPrefix <- c()
subjectPrefix[1] <- "CF/510/XE129_2D_SPIRAL_7MS_4X4X15_12_INTL_0003/XE129_2D_SPIRAL_7MS_4X4X15_12_INTL_0003_Xe129_2D_spiral_7ms_4x4x15_12_intl_20150526135524_3"
subjectPrefix[2] <- "YoungHealthy/Xe358/CORONAL_VENT_4_0X4_0X15_0003/CORONAL_VENT_4_0X4_0X15_0003_Coronal_vent_4.0x4.0x15_20140210134534_3"

for( i in seq.int( length( types ) ) )
  {
  ################################
  #
  # Preliminaries
  #
  ################################

  ventilationImage <- antsImageRead( paste0( dataDirectory, subjectPrefix[i], "N4.nii.gz" ) )
  mask <- antsImageRead( paste0( dataDirectory, subjectPrefix[i], "LungMask.nii.gz" ) )

  antsxnetCacheDirectory <- "ANTsXNet"
  useCoarseSlicesOnly <- TRUE
  verbose <- TRUE

  ################################
  #
  # Preprocess image
  #
  ################################

  templateSize <- c( 256L, 256L )
  classes <- c( 0, 1, 2, 3, 4 )
  numberOfClassificationLabels <- length( classes )

  imageModalities <- c( "Ventilation", "Mask" )
  channelSize <- length( imageModalities )

  preprocessedImage <- ( ventilationImage - mean( ventilationImage ) ) /
    sd( ventilationImage )

  ################################
  #
  # Build models and load weights
  #
  ################################

  unetModel <- createUnetModel2D( c( templateSize, channelSize ),
    numberOfOutputs = numberOfClassificationLabels, mode = 'classification',
    numberOfLayers = 4, numberOfFiltersAtBaseLayer = 32, dropoutRate = 0.0,
    convolutionKernelSize = c( 3, 3 ), deconvolutionKernelSize = c( 2, 2 ),
    weightDecay = 1e-5, addAttentionGating = TRUE )

  if( verbose == TRUE )
    {
    cat( "El Bicho:  retrieving model weights.\n" )
    }
  weightsFileName <- getPretrainedNetwork( "elbicho", antsxnetCacheDirectory = antsxnetCacheDirectory )
  unetModel$load_weights( weightsFileName )

  ################################
  #
  # Extract slices
  #
  ################################

  dimensionsToPredict <- c( which.max( antsGetSpacing( preprocessedImage ) )[1] )

  batchX <- array( data = 0, c( 1, templateSize, channelSize ) )

  whichSlice <- floor( 0.5 * dim( preprocessedImage )[dimensionsToPredict[1]] )
  imageSlice <- extractSlice( preprocessedImage, whichSlice, dimensionsToPredict[1] )
  ventilationSlice <- padOrCropImageToSize( imageSlice, templateSize )
  batchX[1,,,1] <- as.array( ventilationSlice )

  maskSlice <- padOrCropImageToSize( extractSlice( mask, whichSlice, dimensionsToPredict[1] ), templateSize )
  batchX[1,,,2] <- as.array( maskSlice )

  ################################
  #
  # Do prediction
  #
  ################################

  if( verbose == TRUE )
    {
    cat( "Prediction.\n" )
    }

  prediction <- predict( unetModel, batchX, verbose = verbose )

  probabilityImages <- list()
  for( l in seq.int( numberOfClassificationLabels ) )
    {
    predictionArray <- drop( prediction[1,,,l] )
    predictionImage <- antsCopyImageInfo( imageSlice,
        padOrCropImageToSize( as.antsImage( predictionArray ), dim( imageSlice ) ) )
    probabilityImages[[l]] <- predictionImage
    }

  ################################
  #
  # Convert probability images to segmentation
  #
  ################################

  imageMatrix <- imageListToMatrix( probabilityImages[2:length( probabilityImages )], imageSlice * 0 + 1 )
  backgroundForegroundMatrix <- rbind( imageListToMatrix( list( probabilityImages[[1]] ), imageSlice * 0 + 1 ),
                                      colSums( imageMatrix ) )
  foregroundMatrix <- matrix( apply( backgroundForegroundMatrix, 2, which.max ), nrow = 1 ) - 1
  segmentationMatrix <- ( matrix( apply( imageMatrix, 2, which.max ), nrow = 1 ) ) * foregroundMatrix
  segmentationImage <- matrixToImages( segmentationMatrix, imageSlice * 0 + 1 )[[1]]

  ################################
  #
  # Deep features
  #
  ################################

  outputDirectory <- paste0( figuresDirectory, "FeatureMaps/", types[i], "/" )
  if( ! dir.exists( outputDirectory ) )
    {
    dir.create( outputDirectory, showWarnings = FALSE, recursive = TRUE )
    }
  antsImageWrite( imageSlice, paste0( outputDirectory, "imageSlice.nii.gz" ) )
  antsImageWrite( extractSlice( mask, whichSlice, dimensionsToPredict[1] ), paste0( outputDirectory, "maskSlice.nii.gz" ) )


  convolutionLayerIndices <- c( 14, 63 )
  shrinkFactor <- c( 4, 1 )

  for( c in seq.int( length( convolutionLayerIndices ) ) )
    {
    inputImage <- unetModel$input
    featureLayer <- unetModel$layers[[convolutionLayerIndices[c]]]
    featureFunction <- keras::backend()$`function`( list( inputImage ), list( featureLayer$output ) )
    featureBatch <- featureFunction( list( batchX[1,,,,drop = FALSE] ) )

    featureImages <- decodeUnet( featureBatch[[1]], imageSlice )[[1]]
    for( f in seq.int( length( featureImages ) ) )
      {
      featureImages[[f]] <- padOrCropImageToSize( featureImages[[f]], dim( imageSlice ) / shrinkFactor[c] )
      antsImageWrite( featureImages[[f]], paste0( outputDirectory, "featureLayer", convolutionLayerIndices[c], "Image", f, ".nii.gz" ) )
      }
    }
  }
