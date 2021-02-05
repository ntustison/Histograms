library( ggplot2 )


baseDirectory <- './'
figuresDirectory <- paste0( baseDirectory, "../../Text/Figures/" )

simulationTypes <- c( "Noise", "Nonlinearities", "NoiseAndNonlinearities" )

variance <- list()
for( i in seq.int( length( simulationTypes ) ) )
  {
  variance[[i]] <- read.csv( paste0( "../Data/SimulationExperiments_", simulationTypes[i], "/varianceStudy.csv" ) )
  variance[[i]]$SimulationType <- simulationTypes[i]

  variance[[i]]$Segmentation <- factor( variance[[i]]$Segmentation, levels = c( "LinearBinning", "Kmeans", "Atropos", "ElBicho" ) )
  variance[[i]]$Dx <- factor( variance[[i]]$Dx, levels = c( "YoungHealthy", "OldHealthy", "CF", "COPD", "ILD" ) )

  diceVariancePlot <- ggplot( data = variance[[i]] ) +
                      geom_boxplot( aes( x = Dx, y = Dice1, fill = Segmentation ) ) +
                      ylim( c( 0.0, 1.0 ) ) +
                      xlab( "Diagnosis" ) +
                      ylab( "Dice (Cluster 1)" ) +
                      theme( legend.position = "bottom" )
  ggsave( filename = paste0( figuresDirectory, "diceVarianceStudy", simulationTypes[i], "Dice1.pdf" ),
      plot = diceVariancePlot, width = 7, height = 4, units = 'in' )

  diceVariancePlot <- ggplot( data = variance[[i]] ) +
                      geom_boxplot( aes( x = Dx, y = Dice2, fill = Segmentation ) ) +
                      ylim( c( 0.0, 1.0 ) ) +
                      xlab( "Diagnosis" ) +
                      ylab( "Dice (Cluster 2)" ) +
                      theme( legend.position = "bottom" )
  ggsave( filename = paste0( figuresDirectory, "diceVarianceStudy", simulationTypes[i], "Dice2.pdf" ),
      plot = diceVariancePlot, width = 7, height = 4, units = 'in' )

  diceVariancePlot <- ggplot( data = variance[[i]] ) +
                      geom_boxplot( aes( x = Dx, y = Dice3, fill = Segmentation ) ) +
                      ylim( c( 0.0, 1.0 ) ) +
                      xlab( "Diagnosis" ) +
                      ylab( "Dice (Cluster 3)" ) +
                      theme( legend.position = "bottom" )
  ggsave( filename = paste0( figuresDirectory, "diceVarianceStudy", simulationTypes[i], "Dice3.pdf" ),
      plot = diceVariancePlot, width = 7, height = 4, units = 'in' )

  diceVariancePlot <- ggplot( data = variance[[i]] ) +
                      geom_boxplot( aes( x = Dx, y = DiceAll, fill = Segmentation ) ) +
                      ylim( c( 0.0, 1.0 ) ) +
                      xlab( "Diagnosis" ) +
                      ylab( "Dice (all clusters)" ) +
                      theme( legend.position = "bottom" )
  ggsave( filename = paste0( figuresDirectory, "diceVarianceStudy", simulationTypes[i], "DiceAll.pdf" ),
      plot = diceVariancePlot, width = 7, height = 4, units = 'in' )
  }

segmentationTypes <- unique( variance[[1]]$Segmentation )

clusters <- c( "Cluster All", "Cluster 1", "Cluster 2", "Cluster 3" )

cat( "Summary measures: \n" )
for( j in seq.int( length( clusters ) ) )
  {
  for( k in seq.int( length( segmentationTypes ) ) )
    {
    cat( " & ", levels( variance[[1]]$Segmentation )[segmentationTypes[k]], " & ", sep = "" )

    for( i in seq.int( length( variance ) ) )
      {
      segTypeVariance <- variance[[i]][which( variance[[i]]$Segmentation == segmentationTypes[k] ),]

      segDice <- colnames( segTypeVariance )[j+5]
      segMean <- mean( segTypeVariance[,j+5], na.rm = TRUE )
      segSd <- sd( segTypeVariance[,j+5], na.rm = TRUE )
      cat( " {$", round( segMean, digits = 2 ), " \\pm ", round( segSd, digits = 2 ), "$} ", sep = "" )
      if( i == 3 )
        {
        cat( " \\\\ \n")
        } else {
        cat( " & ")
        }
      }
    }
  cat( " \\\\ \n" )
  }
