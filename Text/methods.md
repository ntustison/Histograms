
# Materials and methods

## Hyperpolarized gas imaging acquisition

### University of Virginia cohort

A retrospective dataset was collected consisting of young healthy (n=10), older
healthy ($n=7$), cystic fibrosis (CF) (n=14), interstitial lung disease (ILD)
($n=10$), and chronic obstructive pulmonary disease ($n=10$). MR imaging with
hyperpolarized 129Xe gas was performed under an Institutional Review Board (IRB)
approved protocol with written informed consent obtained from each subject. In
addition, all imaging was performed under a Food and Drug Administration (FDA)
approved physician’s Investigational New Drug application. MRI data were
acquired on a 1.5 T whole-body MRI scanner
(Siemens Avanto, Siemens Medical Solutions, Malvern, PA) with broadband
capabilities and a flexible 129Xe chest radiofrequency coil (RF; IGC Medical
Advances, Milwaukee, WI; or Clinical MR Solutions, Brookfield, WI). During a
$\leq 10$ breath-hold following the inhalation of $\approx 1000$ mL of
hyperpolarized 129Xe mixed with nitrogen up to a volume equal to 1/3 forced
vital capacity (FVC) of the respective subject, a set of 15-17 contiguous
coronal lung slices were collected in order to cover the entire lungs.
Parameters of the gradient echo (GRE) sequence with a spiral k-space sampling
with 12 interleaves for 129Xe MRI were as follows: repetition time msec / echo
time msec, 7/1; flip angle, 20$^{\circ}$; matrix, 128 $\times$ 128: in-plane
voxel size, 4 $\times$ 4 mm; section slice thickness, 15 mm; and intersection
gap, none. The data were deidentified prior to analysis.


<!-- A retrospective dataset was collected consisting of young healthy ($n=10$),
older healthy ($n=7$), cystic fibrosis (CF) ($n=14$), interstitial lung disease
(ILD) ($n=10$), and chronic obstructive pulmonary disease ($n=10$). Imaging with
hyperpolarized 3He was performed under an Institutional Review Board
(IRB)-approved protocol with written informed consent obtained from each
subject. In addition, all imaging was performed under a Food and Drug
Administration approved physician’s Investigational New Drug application (IND
57866) for hyperpolarized 3He. MRI data were acquired on a 1.5 T whole-body MRI
scanner (Siemens Sonata, Siemens Medical Solutions, Malvern, PA) with broadband
capabilities and a flexible 3He chest radiofrequency coil (RF; IGC Medical
Advances, Milwaukee, WI; or Clinical MR Solutions, Brookfield, WI). During a
10–20-second breath-hold following the inhalation of $\approx 300$ mL of
hyperpolarized 3He mixed with $\approx 700$ mL of nitrogen, a set of 19–28
contiguous axial sections were collected. Parameters of the fast low angle shot
sequence for 3He MRI were as follows: repetition time msec / echo time msec,
7/3; flip angle, 10$^{\circ}$; matrix, 80 $\times$ 128; field of view, 26 80
$\times$ 42 cm; section thickness, 10 mm; and intersection gap, none. The data
were deidentified prior to analysis. -->

### Harvard Dataverse cohort

In addition to these data acquired at the University of Virginia, we also
processed a publicly available lung dataset [@He_dataverse:2018] available at
the Harvard Dataverse and detailed in [@He:2019aa].  These data comprised
the original 129Xe acquisitions from 29 subjects (10 healthy controls
and 19 mild intermittent asthmatic individuals) with corresponding lung masks.
In addition, seven artificially SNR-degraded images per acquisition were also
included but not used for the analyses reported below.  The image headers were
corrected for proper canonical anatomical orientation according to Nifti
standards and uploaded to the GitHub repository associated with this work.

## Algorithmic implementations

In support of the discussion in the Introduction, we performed various
experiments to compare the algorithms described
previously, viz. linear binning [@He:2016aa], hierarchical k-means
[@Kirby:2012aa], fuzzy spatial c-means [@Hughes:2018aa], GMM-MRF (specifically,
ANTs-based Atropos tailored for functional lung imaging) [@Tustison:2011aa], and
a trained CNN with roots in our earlier work [@Tustison:2019ac], which we have
dubbed "El Bicho".[^3]  A fair and accurate comparison between algorithms
necessitates several considerations which have been outlined previously
[@Tustison:2013aa].  In designing the evaluation study:

* All algorithms and evaluation scripts have been implemented using open-source
  tools by the first author.  The linear binning and hierarchical k-means
  algorithms were recreated using existing R functionality.  These have been
  made available as part of the GitHub repository corresponding to this
  work.[^2] Similarly, N4, fuzzy spatial c-means, Atropos-based lung
  segmentation, and the trained CNN approach are all available through
  ANTsR/ANTsRNet: ``ANTsR::n4BiasFieldCorrection``,
  ``ANTsR::fuzzySpatialCMeansSegmentation``,
  ``ANTsR::functionalLungSegmentation``, and ``ANTsRNet::elBicho``,
  respectively. Python versions are also available through ANTsPy/ANTsPyNet. The
  trained weights for the CNN are publicly available and are automatically
  downloaded when running the program.

* The University of Virginia imaging data used for the evaluation is available
  upon request and through a data sharing agreement.  In addition to the
  citation providing the online location of the original Harvard Dataverse data,
  a header-modified version of these data is available in the GitHub repository
  associated with this manuscript.  Additional evaluation plots have also been
  made available.

* An extremely important algorithmic hyperparameter is the number of ventilation
  clusters.  In order to minimize differences in our set of evaluations, we
  merged the number of resulting clusters, post-optimization, to only three
  clusters: "ventilation defect," "hypo-ventilation," and "other ventilation"
  where the first two clusters for each output are the same as the original
  implementations and the remaining clusters are merged into a third category.
  It is important to note that none of the evaluations use these categorical
  definitions in a cross-algorithmic fashion.  They are only used to assess
  within-algorithm consistency.

* A significant issue was whether or not to use the N4 bias correction algorithm
  as a preprocessing step.  We ultimately decided to include it for two reasons.[^5]
  First, it is explicitly used in multiple algorithms (e.g.,
  [@Tustison:2011aa;@He:2016aa;@Santyr:2019aa;@Zha:2016aa;@Shammi:2021aa])
  despite the issues raised previously due to the fact that it qualitatively
  improves image appearance.[^4]  Another practical consideration for N4
  preprocessing was due to the parameters of the reference distribution required
  by the linear binning algorithm.  Additional details are provided in the
  Results section.

[^5]: For completeness, we did run the same experiments detailed below using the uncorrected UVa images (and the previously reported parameters
for linear binning) and the results were similar.  These results can be
found in the GitHub repository associated with this work.

[^3]:  A software codename designating a work-in-progress simply based on a shared
admiration between the first and last authors of Portuguese futebol.

[^4]:  This assessment is based on multiple conversations between the first
author (as the co-developer of N4 and Atropos) and co-author \ldots .


[^2]:  https://github.com/ntustison/Histograms

## Introduction of the image-based "El Bicho" network

We extended the deep learning functionality first described in
[@Tustison:2019ac] to improve performance and provide a more clinically granular
labeling (i.e., four clusters instead of two).  In addition, further
modifications incorporated additional data during training, added attention
gating [@Schlemper:2019aa] to the U-net network [@Falk:2019aa] along with
recommended hyperparameters [@Isensee:2020aa], and a novel data augmentation
strategy.

### Network training

"El Bicho" is a 2-D U-net network which was trained with several parameters
recommended by recent exploratory work [@Isensee:2020aa].  The images are
sufficiently small such that 3-D training is possible.  However, given the large
voxel anisotropy for much of our data (both coronal and axial), we found a 2-D
approach to be sufficient.  Nevertheless, a 2.5-D approach is an optional way to
run the code for isotropic data where network prediction can occur in more than
one slice direction and the results subsequently averaged. Four total network
layers were employed with 32 filters at the base layer which was doubled at each
subsequent layer.  Multiple training runs were performed where initial runs
employed categorical cross entropy as the loss function.  Upon convergence,
training continued with the multi-label Dice function [@Crum:2006aa]

\begin{equation}
   Dice = 2 \frac{\sum_r| S_r \cap T_r|}{\sum_r |S_r| + |T_r|}
   \label{eq:dice}
\end{equation}

where $S_r$ and $T_r$ refer to the source and target regions, respectively.

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
The lung parcellation comprised four labels based on the Atropos
ventilation-based segmentation [@Tustison:2011aa]. Six clusters were used to
create the training data and combined to four for training the CNN. In using
this GMM-MRF algorithm (which is the only one to use spatial information in the
form of the MRF prior), we attempt to bootstrap a superior network-based
segmentation approach by using the encoder-decoder structure of the U-net
architecture as a dimensionality reduction technique.  None of the evaluation
data used in this work were used as training data.  Responses from two subjects
at the last layer of the network (with $n = 32$ filters) are illustrated in Figure
\ref{fig:featureImages}.

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
  \caption{Optimized feature responses from both the encoding and decoding branches
  of the U-net network generated from a (top) young healthy subject and (bottom) CF patient. Note
  that these are optimized responses which take advantage of both the intensities and
  their spatial relationships. }
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
        a single ventilation image using El Bicho.
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

