library( ggplot2 )

#############
#
# UVa data
#
#####


baseDirectory <- './'
figuresDirectory <- paste0( baseDirectory, "../../Text/Figures/" )

simulationTypes <- c( "Noise", "NoiseAndNonlinearities", "Nonlinearities" )

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

similarityPlot <- ggplot( data = similarityDataFrame, aes( x = SSIM, y = HistCorr, fill = Type, shape = Type ) ) +
                  geom_point( size = 2, alpha = 0.5 ) +
                  scale_x_continuous( "Structural similarity index measure", limits = c( -0.25, 1. ) ) +
                  scale_y_continuous( "Histogram correlation", limits = c( -0.25, 1. ) ) +
                  scale_fill_manual( name = "Simulation", values=c( "blue", "red", "green" ), breaks = simulationTypes, labels = c( "Noise", "Noise and nonlinearities", "Nonlinearities" ) ) +
                  scale_shape_manual( name = "Simulation", values= c(21, 22, 23), breaks = simulationTypes, labels = c( "Noise", "Noise and nonlinearities", "Nonlinearities" ) )
ggsave( paste0( figuresDirectory, "similarity.pdf" ), similarityPlot, width = 5, height = 3, units = "in" )




#############
#
# He 2019 Dataverse data
#
#####

figuresDirectory <- paste0( baseDirectory, "../../Text/FiguresDataverse/" )

similarity <- list()
for( i in seq.int( length( simulationTypes ) ) )
  {
  similarity[[i]] <- read.csv( paste0( "../Data/He2019_Dataverse/SimulationExperiments_Dataverse_", simulationTypes[i], "/similarityStudy.csv" ) )
  }

similarityDataFrame <- data.frame(
     SSIM = c( similarity[[1]]$SSIM, similarity[[2]]$SSIM, similarity[[3]]$SSIM ),
     HistCorr = c( similarity[[1]]$Correlation, similarity[[2]]$Correlation, similarity[[3]]$Correlation ),
     Type = factor(
            c( rep( simulationTypes[1], length( similarity[[1]]$SSIM ) ),
               rep( simulationTypes[2], length( similarity[[2]]$SSIM ) ),
               rep( simulationTypes[3], length( similarity[[3]]$SSIM ) ) ), levels = simulationTypes ) )

similarityPlot <- ggplot( data = similarityDataFrame, aes( x = SSIM, y = HistCorr, fill = Type, shape = Type ) ) +
                  geom_point( size = 2, alpha = 0.5 ) +
                  scale_x_continuous( "Structural similarity index measure", limits = c( -0.25, 1. ) ) +
                  scale_y_continuous( "Histogram correlation", limits = c( -0.25, 1. ) ) +
                  scale_fill_manual( name = "Simulation", values=c( "blue", "red", "green" ), breaks = simulationTypes, labels = c( "Noise", "Noise and nonlinearities", "Nonlinearities" ) ) +
                  scale_shape_manual( name = "Simulation", values= c(21, 22, 23), breaks = simulationTypes, labels = c( "Noise", "Noise and nonlinearities", "Nonlinearities" ) )
ggsave( paste0( figuresDirectory, "similarity.pdf" ), similarityPlot, width = 5, height = 3, units = "in" )
