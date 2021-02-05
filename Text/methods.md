
# Materials and methods

To support the discussion in the Introduction, we performed various experiments
which showcase the effects of both nonlinear intensity mapping and noise
artefacts on measurement precision and bias using the popular algorithms described
previously, specifically linear binning [@He:2016aa], hierarchical k-means
[@@Kirby:2012aa], GMM-MRF (specifically, ANTs-based Atropos tailored for
functional lung imaging) [@Tustison:2011aa], and a trained CNN
[@Tustison:2019ac].

We focus initially on some of the issues unique to linear binning, specifically
its susceptibility to MR nonlinearity artefacts as well as the additional
requirement of a reference distribution.  The latter is motivated qualitatively
through the analogous application of T1-weighted brain MR segmentation.  This
component is strictly qualitative as the visual evidence and previous
developmental history within that field should be sufficiently compelling in
motivating subsequent quantitative exploration within hyperpolarized gas lung
imaging.  We use these qualitative results as a segue to quantifying the effects
of the choice of reference cohort on the clustering parameters for the linear
binning algorithm.

We then incorporate the trained CNN model in exploring additional aspects of
measurement variance based on simulating both MR noise and intensity
nonlinearities.  Finally, we investigate algorithmic accuracy (i.e., bias) in
the absence of ground-truth segmentations, by using a clinical diagnostic
prediction approach and employing the simultaneous truth and performance level
estimation (STAPLE) [@Warfield:2004aa].

## Hyperpolarized gas image cohort

A retrospective dataset was collected consisting of young healthy ($n=10$),
older healthy ($n=7$), cystic fibrosis (CF) ($n=?$), idiopathic lung disease
(ILD) ($n=?$), and chronic obstructive pulmonary disease ($n=?$).
Imaging with hyperpolarized 3He was
performed under an Institutional Review Board (IRB)-approved protocol with
written informed consent obtained from each subject. In addition, all imaging
was performed under a Food and Drug Administration approved physician’s
Investigational New Drug application (IND 57866) for hyperpolarized 3He. MRI
data were acquired on a 1.5 T whole-body MRI scanner (Siemens Sonata, Siemens
Medical Solutions, Malvern, PA) with broadband capabilities and a flexible 3He
chest radiofrequency coil (RF; IGC Medical Advances, Milwaukee, WI; or Clinical
MR Solutions, Brookfield, WI). During a 10–20-second breath-hold following the
inhalation of $\approx 300$ mL of hyperpolarized 3He mixed with $\approx 700$ mL
of nitrogen, a set of 19–28 contiguous axial sections were collected. Parameters
of the fast low angle shot sequence for 3He MRI were as follows: repetition time
msec / echo time msec, 7/3; flip angle, 10$^{\circ}$; matrix, 80 $\times$ 128;
field of view, 26 80 $\times$ 42 cm; section thickness, 10 mm; and intersection
gap, none. The data were deidentified prior to analysis.

## Algorithmic implementations

A fair and accurate comparison between algorithms necessitates several considerations
which have been outlined previously [@Tustison:2013aa].  In designing the evaluation
study:

* All algorithms and evaluation scripts have been implemented using open-source
  tools by the first author.  The linear binning and hierarchical k-means
  algorithms were recreated using existing R functionality.  These have been made
  available as part of the GitHub repository corresponding to this work.[^2]
  Similarly, N4, Atropos-based lung segmentation, and the trained CNN approach are
  all available through ANTsR/ANTsRNet: ``ANTsR::n4BiasFieldCorrection``,
  ``ANTsR::functionalLungSegmentation``, and ``ANTsRNet::elBicho``, respectively.[^3]
  The weights for the CNN are publicly available and are automatically downloaded
  when running the program.

* The imaging data used for the evaluation is available upon request and through a data
  sharing agreement.  All other data, including additional evaluation plots are available,
  in the specified GitHub repository.

[^2]:  https://github.com/ntustison/Histograms

[^3]:  Python versions are also available through ANTsPy/ANTsPyNet.

## Introduction of "El Bicho"

We extended the deep learning functionality first described in
[@Tustison:2019ac] to improve performance and provide a more clinically granular
labeling (i.e., four clusters instead of two).  In addition, further
modifications incorporated additional data during training, added attention
gating [@Schlemper:2019aa] to the U-net network [@Falk:2019aa] along with
recommended hyperparameters [@Isensee:2020aa], and a novel data augmentation
strategy.  More details are given below.

### Network training

A 2-D U-net network was trained with several parameters recommended by recent
U-net exploratory work [@Isensee:2020aa].  The images are sufficiently small
such that 3-D training is possible.  However, given the large voxel anisotropy
for much of our data (both coronal and axial), we found a 2-D approach to be
sufficient.  Nevertheless, a 2.5-D approach is an optional way to run the code
for isotropic data where network prediction can occur in more than one direction
and the results averaged. Four total network layers were employed with 32
filters at the base layer which is doubled at each subsequent layer.  Multiple
training runs were performed where initial runs employed categorical cross
entropy as the loss function.  Upon convergence, training continued with a
multi-label Dice loss function [@Crum:2006aa].

\begin{figure}[!htb]
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
  \caption{Custom data augmentation strategies for training to force a solution
  which focuses on the underlying ventilation-based lung structure.  (b)
  Nonlinear intensity warping based on smoothly varying perturbations of the
  image histogram.  (c) Additive Gaussian noise included for increasing the
  robustness of the segmentation network.}
\label{fig:sample_ventilation}
\end{figure}

Training data (using an 80/20---training/testing split) was composed of the
ventilation image, lung mask, and corresponding ventilation-based parcellation.
The lung parcellation comprised four labels based on the Atropos-based
ventilation-based segmentation [@Tustison:2011aa]. Six clusters were used to
create the training data and combined to four for training. In using this GMM-MRF
algorithm (which is the only one to use spatial information in the form of the
MRF prior), we attempt to bootstrap a superior network-based segmentation approach
by using the encoder-decoder structure of the U-net architecture as a
dimensionality reduction technique.  None of the evaluation data used in this
work were used as training data.  Responses from two subjects at the last layer
of the network (with $n = 32$ filters) are given in Figure \ref{figure}

A total of five random slices per image were selected in the acquisition
direction (both axial and coronal) for inclusion within a given batch (batch
size = 128 slices). Prior to slice extraction, both random noise and
randomly-generated, nonlinear intensity warping was added to the 3-D image (see
Figure \ref{fig:sample_ventilation}) using ANTsR/ANTsRNet functions
(``ANTsR::addNoiseToImage``, and ``ANTsRNet::histogramWarpImageIntensities``)
with analogs in ANTsPy/ANTsPyNet .  3-D images were intensity normalized to have
0 mean and unit standard deviation.  The noise model was additive Gaussian with
0 mean and a randomly chosen standard deviation value between [0, 0.3].
Histogram-based intensity warping used the default parameters.  These data
augmentation parameters were chosen to provide realistic but potentially
difficult cases for training. In terms of hardware, all training was done on a
DGX (GPUs: 4X Tesla V100, system memory: 256 GB LRDIMM DDR4).

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.99\textwidth]{Figures/featureImages.pdf}
  \caption{Optimized feature responses from the last layer of the U-net network
  generated from a (top) young healthy subject and (bottom) CF patient.  }
\label{fig:featureImages}
\end{figure}

### Pipeline processing

An example R-based code snippet is provided in Listing \ref{listing:elBicho}
demonstrating how to process a single ventilation image using
``ANTsRNet::elBicho``. If a simultaneous proton image has been acquired,
``ANTsRNet::lungExtraction`` can be used to generate the requisite lung mask
input.  As mentioned previously, by default the prediction occurs slice-by-slice
along the direction of anisotropy. Alternatively, prediction can be performed
in all three canonical directions and averaged to produce the final solution.

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
        a single ventilation image using ElBicho.
        },
        captionpos=b,
        label=listing:elBicho
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

