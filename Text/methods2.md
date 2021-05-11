
# Methods

## Hyperpolarized gas imaging acquisition

### University of Virginia cohort

A retrospective dataset was collected consisting of young healthy ($n=10$),
older healthy ($n=7$), cystic fibrosis (CF) ($n=14$), interstitial lung disease
(ILD) ($n=10$), and chronic obstructive pulmonary disease ($n=10$). MR imaging
with hyperpolarized 129Xe gas was performed under an Institutional Review Board
(IRB) approved protocol with written informed consent obtained from each
subject. In addition, all imaging was performed under a Food and Drug
Administration (FDA) approved physician’s Investigational New Drug application.
MRI data were acquired on a 1.5 T whole-body MRI scanner (Siemens Avanto,
Siemens Medical Solutions, Malvern, PA) with broadband capabilities and a
flexible 129Xe chest radiofrequency coil (RF; IGC Medical Advances, Milwaukee,
WI; or Clinical MR Solutions, Brookfield, WI). During a $\leq 10$
\textcolor{blue}{second} breath-hold following the inhalation of $\approx 1000$
mL of hyperpolarized 129Xe mixed with nitrogen up to a volume equal to 1/3
forced vital capacity (FVC) of the respective subject, a set of 15-17 contiguous
coronal lung slices were collected to cover the entire lungs.
Parameters of the gradient echo (GRE) sequence with a spiral k-space sampling
with 12 interleaves for 129Xe MRI were as follows: repetition time msec / echo
time msec, 7/1; flip angle, 20$^{\circ}$; matrix, 128 $\times$ 128: in-plane
voxel size, 4 $\times$ 4 mm; section slice thickness, 15 mm; and intersection
gap, none. The data were deidentified prior to analysis.  These data are
available upon request and through a data sharing agreement.

### Harvard Dataverse cohort

In addition to the data acquired at the University of Virginia, we also
processed a publicly available lung dataset [@He_dataverse:2018] available at
the Harvard Dataverse and detailed in [@He:2019aa].  These data comprised
the original 129Xe acquisitions from 29 subjects (10 healthy controls
and 19 mild intermittent asthmatic individuals) with corresponding lung masks.
In addition, seven artificially SNR-degraded images per acquisition were also
part of this data set but not used for the analyses reported below.  The image headers were
corrected for proper canonical anatomical orientation according to Nifti
standards and uploaded to the GitHub repository associated with this work.

### Data simulations

\textcolor{blue}{Both datasets were transformed by adding Gaussian
noise, nonlinear histogram-based intensity warping, and their combination. The
peak signal-to-noise ratio (PSNR) is defined as}

\begin{equation}
PSNR = 20 \cdot \log_{10}(\max{(I_{original})}) - 10 \cdot \log_{10}(\mathrm{mse}(I_{original},I_{simulated})),
\end{equation}

\textcolor{blue}{where $\mathrm{mse}$ denotes
the mean-squared error between the simulated image and the corresponding
original image. The median PSNR values for the simulated UVa dataset
are noise:  20.7dB, nonlinearities: 29.9dB, and noise and nonlinearities:
19.6dB.  Analogous values for the Dataverse dataset are noise:  19.8dB,
nonlinearities: 26.6dB, and noise and nonlinearities: 19.4dB.}

## Algorithmic implementations

In support of the discussion in the Introduction, we performed various
experiments to compare the algorithms \textcolor{blue}{mentioned} previously,
viz. linear binning [@He:2016aa], hierarchical k-means [@Kirby:2012aa], fuzzy
spatial c-means [@Hughes:2018aa], GMM-MRF (specifically, ANTs-based _Atropos_
tailored for functional lung imaging) [@Tustison:2011aa], and a trained CNN with
roots in our earlier work [@Tustison:2019ac], which we have dubbed "El Bicho".
\textcolor{blue}{Note that we consider the binary thresholding variants to be
simplified versions of linear binning and, therefore, omit them from explicit
consideration in this work.}  A fair and accurate comparison between algorithms
necessitates several considerations which have been outlined previously
[@Tustison:2013aa].  In designing the evaluation study:

* All algorithms and evaluation scripts have been implemented using open-source
  tools by the first author and have been made available as part of the GitHub
  repository corresponding to this work (https://github.com/ntustison/Histograms).
  \textcolor{blue}{Lung masks for the UVa data were created using segmentation
  functionality described in} [@Tustison:2019ac] \textcolor{blue}{and
  inspected/edited by one of the co-authors (M. H.).  The lung masks for the
  Harvard Dataverse 129Xe data are publicly available with the online image
  repository} [@He_dataverse:2018].

* An important algorithmic hyperparameter is the number of ventilation
  clusters.  In order to minimize differences in our set of evaluations, we
  merged the number of resulting clusters, post-optimization, to only three
  clusters: "ventilation defect," "hypo-ventilation," and "other ventilation"
  where the first two clusters for each output are the same as the original
  implementations and the remaining clusters are merged into the third category.

* Another significant issue was whether to apply N4 bias correction
  as a preprocessing step.  We ultimately decided to include it for
  two reasons. First, it is explicitly used in multiple algorithms (e.g.,
  [@Tustison:2011aa;@He:2016aa;@Santyr:2019aa;@Zha:2016aa;@Shammi:2021aa])
  despite the issues raised previously since it qualitatively
  improves image appearance.  Another practical consideration for N4
  preprocessing was due to the parameters of the reference distribution required
  by the linear binning algorithm (discussed in greater detail below).  \textcolor{blue}{However, for completeness,
  we did run the same experiments detailed below using the uncorrected UVa
  images and the previously reported parameters for linear binning, and the
  results were similar.  These results can also be found in the GitHub repository
  associated with this work.}

*  We extended the deep learning functionality first described in
   [@Tustison:2019ac] to improve performance and provide a more clinically
   granular labeling (i.e., four clusters here instead of two in the previous
   work). This network is a 2-D U-net [@Falk:2019aa] with enhancements including
   additional training data with augmentation, attention gating
   [@Schlemper:2019aa], and recommended hyperparameters [@Isensee:2020aa]. These
   include four encoding/decoding layers with 32 filters at the base layer (and
   doubled at each subsequent layer).  Training incorporated an 80/20 data split
   using categorical cross entropy and a multi-label Dice function [@Crum:2006aa]
    \begin{equation}
      Dice = 2 \frac{\sum_r| S_r \cap T_r|}{\sum_r |S_r| + |T_r|}
      \label{eq:dice}
    \end{equation}
   where $S_r$ and $T_r$ refer to the source and target regions, respectively,
   as loss functions.


<!-- ## Introduction of the image-based "El Bicho" network

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

where $S_r$ and $T_r$ refer to the source and target regions, respectively. -->

<!--
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
-->

<!-- Training data (using an 80/20---training/testing split) was composed of the
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
randomly-generated, nonlinear intensity warping was added to the 3-D image
 using ANTsR/ANTsRNet functions
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
 -->
