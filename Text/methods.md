
# Materials and methods

## Image cohort

A retrospective data selection was made

## Algorithmic implementations

All algorithms and evaluation scripts are implemented within the ANTsR/ANTsRNet
framework---a component of the ANTsX ecosystem [@Tustison:2020aa] for R users.
For the interested reader, ANTsPy/ANTsPyNet make potential evaluation possible
with the Python language.

## Introduction of "El Bicho"

We extended the deep learning functionality first described in
[@Tustison:2019ac] to improve performance and provide a more clinically granular
labeling.  In addition, further modifications incorporated additional data
during training, added attention gating [@Schlemper:2019aa]to the U-net network
[@Falk:2019aa], and novel data augmentation strategies. More details are given
below.

### Network training

A 2-D per-image-slice U-net model [@Falk:2019aa] was trained with several
parameters recommended by recent U-net exploratory work [@Isensee:2020aa].  Four
total network layers were employed with 32 filters at the base layer which is
doubled at each subsequent layer.  Multiple training runs were executed where
initial runs employed categorical cross entropy as the loss function.  Upon
convergence, training continued with a multi-label Dice [@Crum:2006aa] loss
function.

\begin{figure}[htb]
  \centering
  \begin{subfigure}{0.33\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/sample_ventilation_9.png}
    \caption{Original.}
  \end{subfigure}%
  \begin{subfigure}{0.33\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/sample_ventilation_intensity_warped_9.png}
    \caption{Nonlinear intensity warping.}
  \end{subfigure}
  \begin{subfigure}{0.33\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/sample_ventilation_noise_9.png}
    \caption{Noise.}
  \end{subfigure}
\caption{Custom data augmentation strategies for training.  (b)  }
\label{fig:sample_ventilation}
\end{figure}

Training data (using an 80/20---training/testing split) was composed of the
ventilation image along with a lung mask and corresponding ventilation-based
parcellation. The ventilation-based parcellation comprised four labels based on
previous experience and the similar choices of other research groups. A total of
five random slices per image were selected in the acquisition direction (both
axial and coronal) for inclusion within a given batch (batch size = 128 slices).
Prior to slice extraction, both random noise and randomly-generated, nonlinear
intensity warping was added to the 3-D image (see Figure
\ref{fig:sample_ventilation}) using the respective ANTsR/ANTsRNet functions:

* ``addNoiseToImage`` [^2] and
* ``histogramWarpImageIntensities`` [^3]

[^2]: https://github.com/ANTsX/ANTsR/blob/master/R/addNoiseToImage.R

[^3]:
https://github.com/ANTsX/ANTsRNet/blob/master/R/histogramWarpImageIntensities.R

with analogs in ANTsPy/ANTsPyNet.  3-D images were intensity normalized to have
0 mean and unit standard deviation.  The noise model was additive Gaussian with
0 mean and a randomly chosen standard deviation value between [0, 0.3].
Histogram-based intensity warping used the default parameters.  These data
augmentation parameters were chosen to provide realistic but potentially
difficult cases for training. In terms of hardware, all training was done on a
DGX (GPUs: 4X Tesla V100, system memory: 256 GB LRDIMM DDR4).

### Pipeline processing


The proposed deep learning extension was

\vspace{10mm}

\setstretch{1.0}

\lstset{frame = htb,
        framerule = 0.25pt,
        float,
        fontadjust,
        backgroundcolor={\color{listlightgray}},
        basicstyle = {\ttfamily\scriptsize},
        keywordstyle = {\ttfamily\color{listkeyword}\textbf},
        identifierstyle = {\ttfamily},
        commentstyle = {\ttfamily\color{listcomment}\textit},
        stringstyle = {\ttfamily},
        showstringspaces = false,
        showtabs = false,
        numbers = none,
        numbersep = 6pt,
        numberstyle={\ttfamily\color{listnumbers}},
        tabsize = 2,
        language=python,
        floatplacement=!h,
        caption={\small ANTsR/ANTsRNet command calls for processing
        a single ventilation image.
        },
        captionpos=b,
        label=listing:antspyCorticalThickness
        }
\begin{lstlisting}
library( ANTsR )
library( ANTsRNet )

# Read in proton and ventilation images.
protonImage <- antsImageRead( "proton.nii.gz" )
ventilationImage <- antsImageRead( "ventilation.nii.gz" )

# Use deep learning lung extraction to get lung mask from proton image.
lungMask <- lungExtraction( protonImage, modality = "proton", verbose = TRUE )

# Run deep learning ventilation-based segmentation.
seg <- elBicho( ventilationImage, lungMask, verbose = TRUE )

# Write segmentation and probability images to disk.
antsImageWrite( seg$segmentationImage, "segmentation.nii.gz" )
antsImageWrite( seg$probabilityImages[[1]], "probability1.nii.gz" )
antsImageWrite( seg$probabilityImages[[2]], "probability2.nii.gz" )
antsImageWrite( seg$probabilityImages[[3]], "probability3.nii.gz" )
antsImageWrite( seg$probabilityImages[[4]], "probability4.nii.gz" )
\end{lstlisting}
\setstretch{1.5}

## Multi-prong exploratory evaluation

* Brain analogy
    * Show labeled histograms of manually traced images to demonstrate that hard threshold values are inadequate.
* Show how the mean and standard deviation values for linear binning
parameters vary based on selection of "normal" cohort.
* Measurement variance based on noise + intensity nonlinearities

### Measurement variance based on "normal" cohort selection {-}

Using the ten normals
