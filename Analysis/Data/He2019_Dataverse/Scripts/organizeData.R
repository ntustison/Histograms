library( ANTsR )

baseDirectory <- "/Users/ntustison/Desktop/He2019_Dataverse/"
dataDirectory <- paste0( baseDirectory, "Nifti/" )

files <- list.files( path = dataDirectory, pattern = "7_.*Noise.*.nii.gz", full.names = TRUE )

pb <- txtProgressBar( min = 0, max = length( files ), style = 3 )
for( i in seq.int( length( files ) ) )
  {
  subjectId <- strsplit( basename( files[i] ), "_" )[[1]][1]
  subjectNoiseId <- sub( ".nii.gz", "", strsplit( basename( files[i] ), "_" )[[1]][4] )
  subjectDir <- paste0( dataDirectory, "Xe", subjectId )

  if( ! dir.exists( subjectDir ) )
    {
    dir.create( subjectDir, showWarnings = FALSE, recursive = TRUE )
    }

  file.copy( files[i], subjectDir )
  setTxtProgressBar( pb, i )

  # Create mask

  maskFile <- list.files( path = dataDirectory, pattern = paste0( subjectId, "_GRE" ), full.names = TRUE )[1]
  if( subjectNoiseId != "1" )
    {
    next
    }

  image <- antsImageRead( files[i] )
  mask <- antsCopyImageInfo( image, antsImageRead( maskFile ) )

  antsImageWrite( mask, paste0( subjectDir, "/", basename( maskFile ) ) )
  }
cat( "\n" )