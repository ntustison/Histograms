library( ggplot2 )
library( ggthemes )


baseDirectory <- './'
figuresDirectory <- paste0( baseDirectory, "../../Text/Figures/" )

simulationTypes <- c( "Noise", "Nonlinearities", "NoiseAndNonlinearities" )

variance <- list()
for( i in seq.int( length( simulationTypes ) ) )
  {
  variance[[i]] <- read.csv( paste0( "../Data/SimulationExperiments_", simulationTypes[i], "/varianceStudy.csv" ) )
  variance[[i]]$SimulationType <- simulationTypes[i]

  variance[[i]]$Segmentation <- factor( variance[[i]]$Segmentation, levels = c( "LinearBinning", "Kmeans", "Fuzzy", "Atropos", "ElBicho" ) )
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

###
#
# Summary box plot
#
#

diceYLabels <- c( "Dice (Cluster 1)", "Dice (Cluster 2)", "Dice (Cluster 3)", "Dice (all clusters)" )
columnIndices <- c( 7, 8, 9, 6 )

varianceAll <- rbind( variance[[1]], variance[[2]], variance[[3]] )
varianceAll$SimulationType <- factor( varianceAll$SimulationType, levels = c( "Noise", "Nonlinearities", "NoiseAndNonlinearities" ) )

for( j in seq.int( columnIndices ) )
  {
  diceVariancePlot <- ggplot( data = varianceAll ) +
                      geom_boxplot( aes( x = SimulationType, y = varianceAll[,columnIndices[j]], fill = Segmentation ) ) +
                      ylim( c( 0.0, 1.0 ) ) +
                      xlab( "" ) +
                      ylab( diceYLabels[j] ) +
                      theme( legend.position = "bottom" ) +
                      theme( axis.text.x = element_text( size = 12, face = "bold" ) )
  ggsave( filename = paste0( figuresDirectory, "diceVarianceStudy", colnames( varianceAll )[columnIndices[j]], ".pdf" ),
      plot = diceVariancePlot, width = 7, height = 4, units = 'in' )
  }

###
#
# Perform one-way anova
#
#

diceYLabels <- c( "Dice difference (Cluster 1)", "Dice difference (Cluster 2)", "Dice difference (Cluster 3)", "Dice difference (all clusters)" )
columnIndices <- c( 7, 8, 9, 6 )

simulationTypes <- c( "Noise", "NoiseAndNonlinearities", "Nonlinearities" )

for( j in seq.int( length( columnIndices ) ) )
  {
  allDataFrame <- data.frame()
  for( i in seq.int( length( variance ) ) )
    {
    diceData <- data.frame( Dice = variance[[i]][,columnIndices[j]],
                            Segmentation = variance[[i]]$Segmentation )

    cat( "*******************************************\n" )
    cat( "* Var", i, ", Dice = ", colnames( variance[[i]] )[columnIndices[j]], "\n" )
    cat( "*******************************************\n" )

    dice.aov <- aov( Dice ~ Segmentation, data = diceData )
    dice.aov.p <- summary( dice.aov )[[1]][1, 5]
    cat( "P-value = ", dice.aov.p, "\n" )

    dice.tukey <- TukeyHSD( dice.aov, "Segmentation", ordered = FALSE )
    dice.tukey.df <- as.data.frame( dice.tukey$Segmentation )
    dice.tukey.df$pair <- rownames( dice.tukey.df )
    dice.tukey.df$SimulationType <- factor( rep( variance[[i]]$SimulationType[1], nrow( dice.tukey.df ) ), levels = simulationTypes )

    if( i == 1 )
      {
      allDataFrame <- dice.tukey.df
      } else {
      allDataFrame <- rbind( allDataFrame, dice.tukey.df )
      }
    }
  dice.tukey.plot <- ggplot( data = allDataFrame, aes( linetype = cut(`p adj`, c( -0.001, 0.01, 0.05, 1 ),
                          label = c( " p<0.01", "p<0.05", "nonsignificant" ) ), fill = SimulationType ) ) +
                      geom_vline( xintercept = 0, lty = "11", colour = "black" ) +
                      geom_errorbarh( aes( y = pair, xmin = lwr, xmax = upr, colour = SimulationType ), position = position_dodge( 0.5 ), height = 0.0, size = 1. ) +
                      geom_point( aes( diff, pair, shape = SimulationType ), size = 3, position = position_dodge( 0.5 ) ) +
                      ylab( "" ) +
                      xlim( c( -0.35, 0.55 ) ) +
                      xlab( diceYLabels[j] ) +
                      scale_color_manual( values = c( "blue", "red", "green" ) ) +
                      scale_linetype_manual( values = c( "solid", "solid", "dotted" ), guide = FALSE ) +
                      scale_fill_manual( values = c( "blue", "red", "green" ), guide = FALSE ) +
                      scale_shape_manual( values= c( 21, 22, 23 ), guide = FALSE ) +
                      theme( legend.title = element_blank() ) +
                      theme( legend.position = "bottom" ) +
                      theme( axis.text.y = element_text( size = 10, face = "bold" ) ) + 
                      theme( panel.background = element_blank() ) +
                      theme( panel.grid.major.x = element_blank() ) +
                      theme( panel.grid.minor.x = element_blank() ) +
                      theme( panel.grid.major.y = element_line( size = 15, colour = "gray90" ) ) +
                      theme( panel.grid.minor.y = element_blank() )

  ggsave( filename = paste0( figuresDirectory, "diceVarianceStudyTukey", colnames( varianceAll )[columnIndices[j]], ".pdf" ),
      plot = dice.tukey.plot, width = 7, height = 6, units = 'in' )
  }
