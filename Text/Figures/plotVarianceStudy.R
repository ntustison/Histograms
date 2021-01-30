library( ggplot2 )

baseDirectory <- "./"

nonlinearResults <- read.csv( paste0( baseDirectory, "varianceStudy.csv" ) )

dxTypes <- unique( nonlinearResults$Dx )
for( l in seq.int( length( dxTypes ) ) )
  {
  dxResults <- nonlinearResults[which( nonlinearResults$Dx == dxTypes[l] ),]

  plotDataFrame <- data.frame( SubjectID = as.factor( dxResults$SubjectID ),
                              Pipeline = dxResults$Segmentation,
                              VDP = dxResults$VDP,
                              Dice = dxResults$Dice )
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
        mean( dxResults$Dice[which( dxResults$SubjectID == subjects[m] & dxResults$Segmentation == pipelines[n] )] ) )
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
      mean( dxResults$Dice[which( dxResults$SubjectID == subjects[m] & dxResults$Segmentation == pipelines[n] )] ) )
    }
  }

pipeline <- gsub( "Kmeans", "k-means", pipeline )
plotDataFrame <- data.frame( Pipeline = factor( pipeline, levels = c( "LinearBinning", "k-means", "Atropos", "ElBicho" ) ),
                            VDP.sd = vdpSd,
                            Dice.Mean = diceMean )
vdpSdPlot <- ggplot( data = plotDataFrame, aes( x = Pipeline, y = VDP.sd ) ) +
                  geom_boxplot( aes( fill = pipeline ) ) +
                  geom_jitter( width = 0.25, size = 1, alpha = 0.1 ) +
                  geom_boxplot( alpha = 0.2 ) +
                  ggtitle( "" ) +
                  theme( legend.position = "none" ) +
                  xlab( "" ) +
                  ylab( "VDP standard deviation" ) +
                  ylim( 0, 0.05 )
ggsave( filename = paste0( baseDirectory, "vdpSdOverall.pdf" ),
  plot = vdpSdPlot, width = 4, height = 3, units = 'in' )

diceMeanPlot <- ggplot( data = plotDataFrame, aes( x = Pipeline, y = Dice.Mean ) ) +
                  geom_boxplot( aes( fill = pipeline ) ) +
                  geom_jitter( width = 0.25, size = 1, alpha = 0.1 ) +
                  geom_boxplot( alpha = 0.2 ) +
                  ggtitle( "" ) +
                  theme( legend.position = "none" ) +
                  ylab( "Dice" ) +
                  xlab( "" )
ggsave( filename = paste0( baseDirectory, "diceMeanOverall.pdf" ),
  plot = diceMeanPlot, width = 4, height = 3, units = 'in' )

