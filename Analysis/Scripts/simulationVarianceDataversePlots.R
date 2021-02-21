library( ggplot2 )


baseDirectory <- './'
figuresDirectory <- paste0( baseDirectory, "../../Text/FiguresX/" )

simulationTypes <- c( "Noise", "Nonlinearities", "NoiseAndNonlinearities" )

variance <- list()
for( i in seq.int( length( simulationTypes ) ) )
  {
  variance[[i]] <- read.csv( paste0( "../Data/He2019_Dataverse/SimulationExperiments_Dataverse_", simulationTypes[i], "/varianceStudy.csv" ) )
  variance[[i]]$SimulationType <- simulationTypes[i]

  variance[[i]]$Segmentation <- factor( variance[[i]]$Segmentation, levels = c( "LinearBinning", "Kmeans", "Fuzzy", "Atropos", "ElBicho" ) )
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

      segDice <- colnames( segTypeVariance )[j+4]
      segMean <- mean( segTypeVariance[,j+4], na.rm = TRUE )
      segSd <- sd( segTypeVariance[,j+4], na.rm = TRUE )
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
columnIndices <- c( 6, 7, 8, 5 )

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
columnIndices <- c( 6, 7, 8, 5 )

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
    dice.aov.p <- summary( dice.aov )[[1]][1, 4]
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
                      geom_errorbarh( aes( y = pair, xmin = lwr, xmax = upr, colour = SimulationType ), position = position_dodge( 0.75 ), height = 0.0, size = 1. ) +
                      geom_point( aes( diff, pair, shape = SimulationType ), size = 3, position = position_dodge( 0.75 ) ) +
                      ylab( "" ) +
                      xlim( c( -0.35, 0.55 ) ) +
                      xlab( diceYLabels[j] ) +
                      theme( legend.title = element_blank() ) +
                      theme( legend.position = "bottom" ) +
                      theme( axis.text.y = element_text( size = 12, face = "bold" ) ) +
                      scale_color_manual( values = c( "blue", "red", "green" ) ) +
                      scale_linetype_manual( values = c( "solid", "dashed", "dotted" ), guide = FALSE ) +
                      scale_fill_manual( values = c( "blue", "red", "green" ), guide = FALSE ) +
                      scale_shape_manual( values= c( 21, 22, 23 ), guide = FALSE )

  ggsave( filename = paste0( figuresDirectory, "diceVarianceStudyTukey", colnames( varianceAll )[columnIndices[j]], ".pdf" ),
      plot = dice.tukey.plot, width = 7, height = 4, units = 'in' )
  }
