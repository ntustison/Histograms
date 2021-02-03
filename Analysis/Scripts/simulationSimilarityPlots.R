library( ggplot2 )



simulationTypes <- c( "Noise", "Nonlinearities", "NoiseAndNonlinearities" )

similarity <- list()
for( i in seq.int( length( simulationTypes ) ) )
  {
  similarity[[i]] <- read.csv( paste0( "../Data/SimulationExperiments_", simulationTypes[i], "/similarityStudy.csv" ) )
  }

similarityDataFrame <- data.frame(
     SSIM = c( similarity[[1]]$SSIM, similarity[[2]]$SSIM, similarity[[3]]$SSIM ),
     HistCorr = c( similarity[[1]]$Correlation, similarity[[2]]$Correlation, similarity[[3]]$Correlation ),
     Type = factor(
            c( rep( simulationTypes[1], length( similarity[[1]]$SSIM ) ),
               rep( simulationTypes[2], length( similarity[[2]]$SSIM ) ),
               rep( simulationTypes[3], length( similarity[[3]]$SSIM ) ) ), levels = simulationTypes ) )

similarityPlot <- ggplot( data = similarityDataFrame ) +
                  geom_point( aes( x = SSIM, y = HistCorr, colour = Type, shape = Type ), size = 1, alpha = 0.85 ) +
                  scale_x_continuous( "Structural Similarity Index Measure", limits = c( -0.25, 1. ) ) +
                  scale_y_continuous( "Histogram Correlation", limits = c( -0.25, 1. ) ) +
                  scale_colour_discrete( name = "Simulation", breaks = simulationTypes, labels = c( "Noise", "Nonlinearities", "Noise and nonlinearities" ) ) +
                  scale_shape_discrete( name = "Simulation", breaks = simulationTypes, labels = c( "Noise", "Nonlinearities", "Noise and nonlinearities" ) ) +
ggsave( "./similarity.pdf", similarityPlot, width = 5, height = 3, units = "in" )
