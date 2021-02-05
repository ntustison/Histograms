library( ANTsR )

baseDirectory <- './'
dataDirectory <- paste0( baseDirectory, "../Data/Nifti/" )

maskFiles <- list.files( path = dataDirectory, pattern = "LungMask.nii.gz",
  recursive = TRUE, full.names = TRUE )

for( i in seq.int( length( maskFiles ) ) )
  {
  imageFile <- gsub( "LungMask", "", maskFiles[i] )

  cat( "Processing ", imageFile, "(", i, " out of ", length( maskFiles ), ")\n", sep = "" )

  image <- antsImageRead( imageFile )
  imageN4File <- gsub( "LungMask", "N4", maskFiles[i] )

  if( ! file.exists( imageN4File ) )
    {
    imageN4 <- n4BiasFieldCorrection( image, shrinkFactor = 2, verbose = TRUE )
    antsImageWrite( imageN4, imageN4File )
    }

  }

