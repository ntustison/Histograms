library( rmarkdown )
library( ggplot2 )

stitchedFile <- "stitched.md"

rmdFiles <- c( "format.md",
               "titlePage.md",
               "abstract2.md",
              #  "notes.md",
               "intro2.md",
               "methods2.md",
               "results2.md",
               "discussion2.md",
               "acknowledgments.md",
               "references.md"
             )

for( i in 1:length( rmdFiles ) )
  {
  cat( rmdFiles[i] )
  if( i == 1 )
    {
    cmd <- paste( "cat", rmdFiles[i], ">", stitchedFile )
    } else {
    cmd <- paste( "cat", rmdFiles[i], ">>", stitchedFile )
    }
  system( cmd )
  }

cat( '\n Pandoc rendering', stitchedFile, '\n' )
# render( stitchedFile, pdf_document( number_sections = TRUE, pandoc_args = c( "--variable=subparagraph", "--include-after-body=authorContributions.md" ) ) )
render( stitchedFile, pdf_document( number_sections = TRUE, pandoc_args = c( "--variable=subparagraph" ) ) )
render( stitchedFile, word_document() )

