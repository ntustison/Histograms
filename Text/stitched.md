---
title:
author:
address:
output:
  pdf_document:
    keep_tex: true
    fig_caption: true
    number_sections: true
  word_document:
    fig_caption: true
bibliography:
  - references.bib
csl:  magnetic-resonance-in-medicine.csl
longtable: true
urlcolor: blue
header-includes:
  # - \usepackage{longtable}
  # - \usepackage[normalem]{ulem}
  # - \usepackage{graphicx}
  # - \usepackage{booktabs}
  # - \usepackage{listings}
  # - \usepackage{textcomp}
  # - \usepackage{xcolor}
  # - \usepackage{multirow}
  - \usepackage{subcaption}
  - \usepackage[nomarkers,figuresonly]{endfloat}
  # - \definecolor{listcomment}{rgb}{0.0,0.5,0.0}
  # - \definecolor{listkeyword}{rgb}{0.0,0.0,0.5}
  # - \definecolor{listnumbers}{gray}{0.65}
  # - \definecolor{listlightgray}{gray}{0.955}
  # - \definecolor{listwhite}{gray}{1.0}
geometry: margin=1.0in
fontsize: 12pt
linestretch: 1.5
mainfont: Georgia
---

\pagenumbering{gobble}

\setstretch{1}

\begin{centering}

$ $

\vspace{4.cm}

\LARGE

{Image- vs. histogram-based considerations in semantic segmentation of pulmonary hyperpolarized gas images}

\vspace{1.5 cm}

\normalsize

Nicholas J. Tustison$^1$,
Talissa A. Altes$^2$,
Kun Qing$^3$,
Mu He$^1$,
G. Wilson Miller$^1$,
Brian B. Avants$^1$,
Yun M. Shim$^1$,
James C. Gee$^4$,
John P. Mugler III$^1$,
Jaime F. Mata$^1$

\footnotesize

$^1$Department of Radiology and Medical Imaging, University of Virginia, Charlottesville, VA \\
$^2$Department of Radiology, University of Missouri, Columbia, MO \\
$^3$Department of Radiation Oncology, City of Hope, Los Angeles, CA \\
$^4$Department of Radiology, University of Pennsylvania, Philadelphia, PA \\


\end{centering}

\vspace{9 cm}

\scriptsize
Corresponding author: \
Nicholas J. Tustison, DSc \
Department of Radiology and Medical Imaging \
University of Virginia \
ntustison@virginia.edu

\normalsize

\newpage

\setstretch{1.5}

# Abstract {-}

__Purpose:__  \textcolor{blue}{To characterize the differences between
histogram-based and image-based algorithms for segmentation of
hyperpolarized gas lung images.}

<!--
To evaluate the most common approaches for histogram-based
optimization of hyperpolarized gas lung imaging segmentation in comparison
with image-based optimization via a trained convolutional neural network (CNN).
-->

__Methods:__  Four previously published histogram-based segmentation algorithms
(i.e., linear binning, hierarchical k-means, fuzzy spatial c-means, and a
Gaussian Mixture Model with a Markov Random Field prior) and an
\textcolor{blue}{image-based convolutional neural network} were used to segment
two simulated data sets derived from a public ($n=29$) and a retrospective
collection ($n=51$) of hyperpolarized 129Xe gas lung images transformed by
common MRI artefacts \textcolor{blue}{
(noise and nonlinear intensity distortion). The resulting
ventilation-based segmentations were used to
assess algorithmic performance and characterize optimization
domain differences} in terms of measurement bias and precision.

__Results:__ Although facilitating computational processing and providing
discriminating clinically relevant measures of interest, histogram-based
segmentation methods  \textcolor{blue}{discard important contextual, spatial
information and are consequently less robust, in terms of measurement
precision, in the presence of common MRI
artefacts relative to the image-based convolutional neural network}.

__Conclusions:__ Direct optimization within the image domain using convolutional
neural networks leverages spatial information which mitigates problematic issues
associated with histogram-based approaches and suggests a preferred future research
direction. Further, the entire processing and evaluation framework, including the newly
reported deep learning functionality, is available as open-source through the
well-known Advanced Normalization Tools ecosystem.

\newpage


\newpage
# Introduction

<!-- ## Early acquisition and development

Early hyperpolarized gas pulmonary imaging research reported findings in
qualitative terms.

Descriptions:

* "$^{3}$He MRI depicts anatomical structures reliably" [@Bachert:1996aa]

* "hypointense areas" [@Kauczor:1996aa]

* "signal intensity inhomogeneities" [@Kauczor:1996aa]

* "wedge-shaped areas with less signal intensity" [@Kauczor:1996aa]

* "patchy or wedge-shaped defects" [@Kauczor:1997aa]

* "ventilation defects" [@Altes:2001aa]

* "defects were pleural-based, frequently wedge-shaped, and varied in size from
  tiny to segmental" [@Altes:2001aa] -->


## Historical overview of quantification

Early attempts at quantification of \textcolor{blue}{hyperpolarized gas} images were limited to
enumerating the number of ventilation defects or estimating the proportion of
ventilated lung [@Lange:1999aa;@Altes:2001aa;@Samee:2003aa] which has
evolved to more sophisticated techniques used currently.  A brief outline of
major contributions can be roughly sketched to include:

* binary thresholding based on relative intensities
  [@Woodhouse:2005aa;@Thomen:2015aa;@Shammi:2021aa],
* linear intensity standardization via rescaling of the intensity histogram to
  a reference distribution based on healthy controls, i.e., "linear binning" [@He:2016aa;@He:2020aa],
* nonlinear intensity standardization using a customized hierarchical
  [@Kirby:2012aa;@Kirby:2012ab] or adaptive [@Zha:2016aa] k-means algorithm,
* nonlinear intensity standardization using fuzzy c-means [@Ray:2003aa] with spatial
  considerations based on local voxel neighborhoods [@Hughes:2018aa], and
* Gaussian mixture modeling (GMM) of the intensity histogram with Markov random
  field (MRF) spatial prior modeling [@Tustison:2011aa].

Given the functional nature of hyperpolarized gas images and the consequent
sophistication of the segmentation task, these algorithmic approaches reduce the complex
spatial image information to primarily intensity-only optimization considerations,
contextualized in terms of the intensity histogram. Although facilitating
computational processing, this simplifying transformation results in the loss of
important spatial cues for identifying salient image features, such as
ventilation defects (a well-studied correlate of lung pathophysiology), as
spatial objects.

Each of these algorithms can be viewed as a type of MR intensity standardization
[@Nyul:1999aa] with varying degrees of flexibility and algorithmic sophistication.
Due to hard threshold values, intensity-only approaches
are unable to account for various MRI artefacts such as noise
[@Gudbjartsson:1995aa;@Andersen:1996aa] and the intensity inhomogeneity field
[@Sled:1998aa] which prevent such
threshold values from distinguishing tissue types precisely consistent with that
of human experts.   These MR intensity nonlinearities have been well-studied
[@Wendt:1994aa;@Nyul:1999aa;@Nyul:2000aa;@Collewet:2004aa;@De-Nunzio:2015aa] and
are known to cause significant intensity variation even in the same region of
the same subject.  As stated in [@Collewet:2004aa]:

> Intensities of MR images can vary, even in the same protocol and the same
> sample and using the same scanner. Indeed, they may depend on the acquisition
> conditions such as room temperature and hygrometry, calibration adjustment,
> slice location, B0 intensity, and the receiver gain value. The consequences of
> intensity variation are greater when different scanners are used.

Ignoring these nonlinearities is known to have significant consequences in the
well-studied (and somewhat analogous) area of brain tissue segmentation in
T1-weighted MRI (e.g., [@Zhang:2001aa;@Ashburner:2005aa;@Avants:2011aa]) where
the well-known relative intensities of major tissue types (i.e., cerebrospinal
fluid (CSF), gray matter (GM), and white matter (WM)), which characteristically
correspond to visible histogram peaks, as landmarks to determine the nonlinear
intensity mapping (i.e., 1-D piecewise affine mapping) between structural
features found within the histograms themselves (e.g., peaks and valleys)
[@Nyul:1999aa;@Nyul:2000aa].  However, in hyperpolarized gas imaging of the
lung, no such characteristic structural features exist, generally, between
histograms.  Additionally, because of the functional nature of these images, the
segmentation clusters that correspond to features of interest are not
necessarily guaranteed to exist (e.g., ventilation defects in the case of
healthy normal subjects with no lung pathology).

\textcolor{blue}{Linear binning is a simplified type of MR intensity
standardization in which images from healthy controls are normalized to the
range [0, 1] and then used to calculate the cluster intensity boundary values
based on an aggregated estimate of the parameters of a single Gaussian fit.
Subject images to be segmented are then rescaled to this reference histogram
(i.e., a global affine 1-D transform). This mapping results in alignment of the
cluster boundaries such that corresponding labels are assumed to have similar
clinical interpretation.  Variants of the well-known k-means algorithm constitute
an algorithmic approach with additional flexibility over linear binning
as it employs prior knowledge in the form of a generic clustering desideratum
(i.e., minimizing within-cluster intensity variance) for optimizing a type of
nonlinear MR intensity standardization.  However, as with binary thresholding,
both linear binning and k-means completely discard spatial context in optimizing
voxelwise cluster membership.}

Additional sophistication incorporating spatial considerations is found in the
fuzzy spatial c-means [@Chuang:2006aa] and Gaussian mixture-modeling (GMM) with
a Markov random field (MRF) prior algorithms.  The former, similar to k-means,
optimizes over the within-class sample variance but includes a per-sample membership
weighting [@Bezdek:1981aa], based on neighborhood voxel information,
whereas the latter is optimized via the
expectation-maximization (EM) algorithm [@Dempster:1977aa].  These algorithms
have the advantage, in contrast to histogram-only algorithms, \textcolor{blue}{that} the
intensity thresholds between class labels are softened which demonstrates some
relative robustness to certain imaging distortions, such as noise.  However,
all these algorithms are flawed in the inherent assumption
that meaningful structure is found, and can be adequately characterized, within
the associated image histogram in order to optimize a multi-class labeling.

Additionally, many of these segmentation algorithms use N4 bias correction
[@Tustison:2010ac], an extension of the nonuniform intensity normalization (N3)
algorithm [@Sled:1998aa], to mitigate MR intensity inhomogeneity artefacts.
Interestingly, N3/N4 iteratively optimizes towards a final solution using
information from both the histogram and image domains.  Based on the intuition
that the bias field acts as a smoothing convolution operation on the original
image intensity histogram, N3/N4 optimizes a nonlinear (i.e., deformable)
intensity mapping based on histogram deconvolution.  This nonlinear mapping is
constrained such that its effects smoothly vary across the image.
Due to the deconvolution operation, this mapping sharpens the
histogram peaks which are assumed to correspond to distinct tissue types. While such
assumptions are appropriate for the domain in which N3/N4 was developed (i.e.,
T1-weighted brain tissue segmentation) and while it is assumed that the
enforcement of low-frequency modulation of the intensity mapping prevents new
image features from being generated, it is not clear what effects N4 parameter
choices have on the final segmentation solution, particularly for those
algorithms that are limited to intensity-only considerations and less robust to
the specified MR artefacts.

## Motivation for current study

\begin{figure}[!h] \centering
  \includegraphics[width=0.9\linewidth]{Figures/motivation.pdf}
  \caption{\textcolor{blue}{
  Illustration of the effect of MR nonlinear intensity warping on the
  histogram structure using a representative sampling of the simulations used
  in the experiments in this work.  By simulating these types of nonlinear
  intensity changes, we can visualize both the image and the
  corresponding intensity histogram and investigate the effects on salient
  outcome measures. These simulated intensity mappings,
  although relatively small and difficult to distinguish in the image domain,
  can have an algorithmically consequential effect on the histogram structure.}}
  \label{fig:motivation}
\end{figure}

Investigating the assumptions outlined above, particularly those associated with
the intensity mappings due to both the MR acquisition and
inhomogeneity mitigation preprocessing, we became concerned by the
susceptibility of the histogram structure to such variations and the potential
effects on current clinical measures of interest derived from these algorithms
(e.g., ventilation defect percentage).  Specifically, we noticed that histogram-based intensity
perturbations can produce virtually little, if any, changes in the features of
the image despite a relatively significant change in the histogram structure.
Such effects imply that MR artefacts could profoundly impact histogram-based
algorithmic performance. Figure \ref{fig:motivation} provides a sample
visualization representing some of the structural changes that we observed when
simulating these nonlinear mappings.

<!--
It is important to notice that even
relatively small alterations in the image intensities can have significant
effects on the histogram even though a visual assessment of the image can remain
largely unchanged.
-->

\begin{figure}[!htb] \centering
  \includegraphics[width=0.95\textwidth]{Figures/similarityMultisite.pdf}
  \caption{Multi-site:  (left) University of Virginia (UVa) and (right) Harvard
  Dataverse 129Xe data. Image-based SSIM vs. histogram-based Pearson's
  correlation differences under distortions induced by the common MR artefacts
  of noise and intensity nonlinearities.  For the nonlinearity-only simulations,
  the images maintain their structural integrity as the SSIM values remain close
  to 1.  This is in contrast to the corresponding range in histogram similarity
  which is much larger. The effects with simulated Gaussian noise are similar
  where the range in histogram differences with simulated noise is much greater
  than the range in SSIM. Both sets of observations are evidence of the lack of
  robustness to distortions in the histogram domain in comparison with the
  original image domain. }
  \label{fig:similarity}
\end{figure}

To briefly explore these effects further for the purposes of motivating
additional experimentation, we provide a summary illustration from a set of
image simulations in Figure \ref{fig:similarity} which are detailed later in
this work and used for algorithmic comparison.  Simulated MR artefacts were
applied to each image which included both noise and nonlinear intensity mappings
(and their combination) using two separate data sets:  one in-house data set
consisting of 51 129Xe gas lung images and the publicly available data
described in [@He:2019aa] and made available at Harvard's Dataverse online
repository [@He_dataverse:2018] consisting of 29 hyperpolarized gas lung images
\textcolor{blue}{and corresponding lung masks}.
These two data sets resulted in a total simulated cohort of 51 + 29 = 80 images
($\times 10$ simulations per image $\times 3$ types of artefact simulations).
Prior to any algorithmic comparative analysis, we quantified the difference of
each simulated image with the corresponding original image using the structural
similarity index measurement (SSIM) [@Wang:2004aa]. SSIM is a highly cited
measure which quantifies structural differences between a reference and
distorted (i.e., transformed) image based on known properties of the human
visual system.  SSIM has a range $[-1,1]$ where 0 indicates no structural
similarity and 1 indicates perfect structural similarity. We also generated the
histograms corresponding to these images. Although several histogram similarity
measures exist, we chose Pearson's correlation primarily as it resides in the
same min/max range as SSIM with analogous significance. In addition to the fact
that the image-to-histogram transformation discards important spatial
information, from Figure \ref{fig:similarity} it should be apparent that this
transformation also results in greater variance in the resulting information
under common MR imaging artefacts, according to these measures.  Thus, prior to
any algorithmic considerations, these observations strongly suggest that
optimizing in the domain of the histogram will be generally less informative and
less robust than optimizing directly in the image domain.

<!--
[^100]: This point should be obvious even without the simulation experiments.
Imagine, dear reader, the reality of the future clinical application of
functional lung imaging beyond research activity.  In fact, imagine
yourself being a patient on the receiving end of an imaging battery which
includes hyperpolarized gas imaging.  Now imagine that, upon receiving the
images for assessment, the radiologist declares "Yes, these are nice but I'd
rather work with the corresponding histograms."  If this strikes you as absurd,
then the point that we are trying to make should be clear.
-->

Ultimately, we are not claiming that these algorithms are erroneous, per se.
Much of the relevant research has been limited to quantifying differences with
respect to ventilation versus non-ventilation in various clinical categories and
these algorithms have demonstrated the capacity for advancing such
research \textcolor{blue}{through the use of clinically useful
measures such as ventilation defect percentage}.
Furthermore, as the sample segmentations in Figure
\ref{fig:sampleSegmentations} illustrate, when considered qualitatively, each
segmentation algorithm appears to produce reasonable segmentations even though
the voxelwise differences are significant as are the corresponding histograms.
However, the artefact issues influence quantitation in terms of
core scientific measurement principles such as precision (e.g., reproducibility
and repeatability [@Zha:2016aa;@Svenningsen:2020aa]) and bias which are obscured
in isolated considerations but become increasingly significant with multi-site
[@Couch:2019aa] and large-scale studies.  In addition,
refinements in measuring capabilities correlate with scientific advancement so
as acquisition and analysis methodologies improve, so should the level of
sophistication and performance of the underlying measurement tools.

\begin{figure}[!h] \centering
  \includegraphics[width=0.9\linewidth]{Figures/sampleSegmentations.pdf}
  \caption{Illustration of sample segmentations produced by the four algorithms
  described above (i.e., linear binning, hierarchical k-means, spatial fuzzy
  c-means, and GMM-MRF) and the deep learning algorithm (``El Bicho'')
  described below on a single cystic fibrosis subject.  Also included are
  the corresponding segmentation histograms.  Although quite disparate in
  the actual labeling of the lung and resulting histogram, each algorithm
  produces a reasonable parcellation.
  }
  \label{fig:sampleSegmentations}
\end{figure}


In assessing these segmentation algorithms for hyperpolarized gas imaging, it is
important to note that human expertise leverages more than relative intensity
values to identify salient, clinically relevant features in images---something
more akin to the complex structure of deep-layered neural networks
[@LeCun:2015aa], particularly convolutional neural networks (CNN).
Such models have demonstrated outstanding performance in certain computational tasks,
including classification and semantic segmentation in medical imaging
[@Shen:2017aa]. Their potential for leveraging spatial information from images
surpasses the perceptual capabilities of previous approaches and even rivals
that of human raters [@Zhang:2018aa].  Importantly, CNN optimization occurs
directly in the image space to learn complex spatial features, in contrast to
the previously discussed methods where optimization (primarily) concerns image
intensity-only information.  We introduced a deep learning approach in
[@Tustison:2019ac] and further expand on that work for comparison with existing
approaches below.  Although we find its performance to be quite promising, more
fundamental to this work than the network itself is simply pointing to the
general potential associated with  deep learning for analyzing hyperpolarized
gas images *as spatial samplings of real-world objects*, as opposed to lossy
representations of such objects.  In the spirit of open science, we have made
the entire evaluation framework, including our novel contributions, available
within the Advanced Normalization Tools software ecosystem (ANTsX)
[@Tustison:2021aa].





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

# Results

We performed several comparative evaluations to probe the previously mentioned
issues broadly categorized in terms of measurement bias and precision, with most
of the focus being on the latter.  Given the lack of ground-truth in the form of
segmentation images, addressing issues of measurement bias is difficult.  In
addition to the fact that the number of ventilation clusters is not consistent
across algorithms, it is not clear that the ventilation categories across
algorithms have identical clinical definition. This prevents application of
various frameworks accommodating the lack of ground-truth for segmentation
performance analysis (e.g., [@Warfield:2004aa]) to these data.

As mentioned in the Introduction, the cited algorithms have all demonstrated
research utility and potential clinical utility. This is supported by our first
evaluation which is based on diagnostic prediction of given clinical categories
assigned to the imaging cohort using
derived random forest models [@Breiman:2001aa].  This approach also provides an
additional check on the validity of the algorithmic implementations.  However,
it is important to recognize that this evaluation is extremely limited as the
underlying data are gross measures which do not provide accuracy estimates on
the level of the algorithmic output (i.e., voxelwise segmentation).

Having established the general validity of the gross algorithmic output, we then
switch to our primary focus which is the comparison of measurement precision
between algorithms.   We first analyzed the unique requirement of a reference
distribution for the linear binning algorithm.  Specifically, we quantify the
effects of the choice of reference cohort on the clustering parameters for the
linear binning algorithm. We then incorporate the trained El Bicho model in
exploring additional aspects of measurement variance based on simulating both MR
noise and intensity nonlinearities.

\textcolor{blue}{To summarize}, we performed the following evaluations/experiments:

* Global algorithmic bias (in the absence of ground truth)

    * Diagnostic prediction

* Voxelwise algorithmic precision

    * Input/output variance based on reference distribution (linear binning only)
    * Effects of simulated MR artefacts on multi-site data

<!--
[^103]: It is important to note that, although these experiments provide supporting
evidence, our principal contentions stand prior to these results and are based on
the self-evidentiary observations mentioned in the Introduction.
-->

## Diagnostic prediction

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.99\linewidth]{Figures/volumeXRocDx.pdf}
  \caption{ROC curves resulting from the diagnostic prediction evaluation
  strategy involving randomly permuted training/testing data sets and predictive
  random forest models.}
  \label{fig:DxPrediction}
\end{figure}

Due to the absence of ground-truth, we adopted
the strategy from previous work [@Tustison:2014ab;@Tustison:2021aa] where we
used cross-validation to build and compare prediction models from data derived
from the set of segmentation algorithms.  Specifically, we use pathology
diagnosis (i.e., "CF", "COPD", and "ILD") as an established research-based
correlate of ventilation levels from hyperpolarized gas imaging (e.g.,
[@Myc:2020aa;@Santyr:2019aa;@Mammarappallil:2019aa]) and quantified the
predictive capabilities of corresponding binary random forest classifiers
[@Breiman:2001aa] of the form:

\begin{equation}
  Pathology\,\,vs.\,\,Healthy \sim \sum_{i=1}^3 \frac{Volume_i}{Total\,\,volume}
\end{equation}

where $Volume_i$ is the volume of the $i^{th}$ cluster and $Total\,\,volume$ is total lung
volume \textcolor{blue}{which is recognized as a multiple-cluster summation
extension of the ventilation defect percentage.}  We used a training/testing split of 80/20.  Due to the small number
of subjects, we combined the young and old healthy data into a single category.
100 permutations were used where training/testing data were randomly assigned
and the corresponding random forest model was constructed at each permutation.

<!-- \input{dxPredictionAucTable} -->

The resulting receiver operating characteristic (ROC) curves for each algorithm
and each diagnostic scenario are provided in Figure \ref{fig:DxPrediction}. All
four algorithms perform significantly better than a random classifier. In the
absence of ground truth, this type of evaluation does provide evidence that all
these algorithms produce measurements which are clinically relevant although, it
should be noted, that this is a very coarse assessment strategy given the global
measures used (i.e., cluster volume percentage) and the general clinical
categories employed.  \textcolor{blue}{This complicates attempts at additional
inferences concerning voxelwise bias performance with this type of evaluation strategy.}  In fact,
even spirometry measures can be used to achieve highly accurate diagnostic
predictions with machine learning techniques [@Badnjevic:2018aa].

## Effects of reference image set selection

\begin{figure}[!htb]
  \centering
    \includegraphics[width=0.95\linewidth]{Figures/referenceN4vsNo.pdf}
  \caption{Ten young healthy subjects were combined to create two reference
        distributions, one based on the (a) original images and the other using (b) N4
        preprocessing.  Based on the generated mean and standard deviation of the
        aggregated samples, we label the resulting clusters in the respective
        histograms.  Due to the lower mean and higher standard deviation of the
        original image set, Cluster 1 is not within the range of $[0, 1]$ for the
        resulting reference distribution which motivated the use of the
        N4 preprocessed image set.
         }
\label{fig:n4ornot}
\end{figure}

<!--
\begin{figure}[!htb]
  \centering
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/referencePlot_10_1.pdf}
    \caption{Reference distribution (original images).}
  \end{subfigure}%
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/referencePlot_10_1_N4.pdf}
    \caption{Reference distribution (N4 images).}
  \end{subfigure}
  \caption{Ten young healthy subjects were combined to create two reference
        distributions, one based on the (a) original images and the other using (b) N4
        preprocessing.  Based on the generated mean and standard deviation of the
        aggregated samples, we label the resulting clusters in the respective
        histograms.  Due to the lower mean and higher standard deviation of the
        original image set, Cluster 1 is not within the range of $[0, 1]$ for the
        resulting reference distribution which motivated the use of the
        N4 preprocessed image set.
         }
\label{fig:n4ornot}
\end{figure} -->

One of the additional input requirements for linear binning over the other
algorithms is the generation of a reference distribution.  Therefore, we
additionally investigated the influence of reference data set on the outcome of
linear binning classification, since this is an integral aspect unique to this
method.  In addition to the
output measurement variation caused by choice of the reference image cohort,
this played a role in determining whether or not to use N4 preprocessing. As
mentioned, a significant portion of N4 processing involves the deconvolution of
the image histogram to sharpen the histogram peaks which decreases the standard
deviation of the intensity distribution and can also result in a histogram
shift. Using the original set of 10 young healthy data with no N4 preprocessing,
we created a reference distribution according to [@He:2016aa], which resulted in
an approximate distribution of $\mathcal{N}(0.45, 0.24)$.  This produced 0
voxels being classified as belonging to Cluster 1 (Figure \ref{fig:n4ornot}(a))
because two standard deviations from the mean is less than 0 and Cluster 1
resides in the region below -2 standard deviations.  However, using N4-preprocessed
images produced something closer,  $\mathcal{N}(0.56, 0.22)$, to the published
values, $\mathcal{N}(0.52, 0.18)$, reported in [@He:2016aa], resulting in a
non-empty set for that cluster.  This is consistent, though, with linear binning
which does use N4 bias correction for preprocessing.  We also mention that the
Harvard Dataverse images used were preprocessed using N4 [@He:2019aa]
which provides a third reason for its use on the University of Virginia image
dataset (to maximize cross cohort consistency).  In the case of the former
image set, we did use the previously reported linear binning mean and standard
deviation algorithm parameter values (i.e., $\mathcal{N}(0.52, 0.18)$).  This
was the only parameter difference between analyzing the two image sets.

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.99\textwidth]{Figures/referenceVariation.pdf}
  \caption{(Top) Variation of the mean (left) and standard deviation (right)
  over choice of reference set based on all different combinations of young
  healthy subjects per specified number of subjects. Although these parameters
  demonstrate convergence, there is still non-zero variation for any given set.
  (Bottom) This input variance is a source of output variance in the cluster
  volume plotted as the maximum range per subject as a percentage of total lung
  volume.  We limit this exploration to reference sets with eight or nine images.
  }
  \label{fig:referenceVariance}
\end{figure}

The previous implications of the chosen image reference set also caused us to
look at this choice as a potential source of both input and output variance in
the measurements utilized and produced by linear binning. Regarding the former,
we took all possible combinations of our young healthy control subject images
and looked at the resulting mean and standard deviation values.  As expected,
there is significant variation for both mean and standard deviation values
(see top portion of Figure \ref{fig:referenceVariance}) which are used to derive
the cluster threshold values.  This directly impacts output measurements such as
ventilation defect percentage. For the reference sets comprising eight or nine
images, we compute the corresponding linear binning segmentation and
estimate the volumetric percentage for each cluster.  Then, for each subject, we
computed the min/max range for these values and plotted those results cluster-wise
on the bottom of Figure \ref{fig:referenceVariance}.  This demonstrates that
the additional requirement of a reference distribution is a source of potentially
significant measurement variation for the linear binning algorithm.


## Effects of MR-based simulated image distortions

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.75\linewidth]{Figures/DiceVarianceStudyVersion2a.pdf}
  \caption{University of Virginia image cohort.  \textcolor{blue}{Box plots
  illustrate the lack of segmentation overlap with reference segmentations
  caused by distortions produced by noise, histogram-based intensity
  nonlinearities, and their combination as measured by the Dice metric over all
  five algorithms.  We provide the results of the two pathologically-relevant
  labels for comparison: ``ventilation defect'' (Cluster 1) and
  ``hypo-ventilation'' (Cluster 2).  }
  }
\label{fig:simulations}
\end{figure}

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.85\linewidth]{Figures/DiceVarianceStudyVersion2b.pdf}
  \caption{University of Virginia image cohort.  \textcolor{blue}{(Left) Results
  from Tukey's test following one-way ANOVA to compare the resulting overlaps
  between algorithms (cf Figure \ref{fig:simulations}). Higher positive values
  indicate increased robustness to simulated image distortions. A solid line indicates
  statistical significance at the 0.05 level whereas the dashed line indicates no
  statistically significant difference.  (Right)
  To further visualize the Tukey results, a simplified alluvial diagram is used to
  provide connections illustrating relative performance between algorithms where
  the algorithms listed on the left have improved performance relative to their
  connected algorithms on the right with the width of the connection being
  proportional to difference in performance.}
  }
\label{fig:simulations2}
\end{figure}


As we mentioned in the Introduction, noise and nonlinear intensity artefacts
common to MRI can have a significant distortion effect on the image with even
greater effects seen with respect to change in  the structure of the
corresponding histogram.  This final evaluation explores the effects of these
artefacts on the algorithmic output on a voxelwise scale using the Dice
metric (Equation (\ref{eq:dice})) which has a range of [0,1] where 1 signifies
perfect agreement between the segmentations and 0 is no agreement.

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.75\linewidth]{FiguresDataverse/DiceVarianceStudyVersion2a.pdf}
  \caption{Harvard Dataverse image cohort.  \textcolor{blue}{Box plots
  illustrate the lack of segmentation overlap with reference segmentations
  caused by distortions produced by noise, histogram-based intensity
  nonlinearities, and their combination as measured by the Dice metric over all
  five algorithms.  We provide the results of the two pathologically-relevant
  labels for comparison: ``ventilation defect'' (Cluster 1) and
  ``hypo-ventilation'' (Cluster 2).}
  }
\label{fig:simulationsDataverse}
\end{figure}

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.85\linewidth]{FiguresDataverse/DiceVarianceStudyVersion2b.pdf}
  \caption{Harvard Dataverse image cohort.  \textcolor{blue}{(Left) Results
  from Tukey's test following one-way ANOVA to compare the resulting overlaps
  between algorithms (cf Figure \ref{fig:simulationsDataverse}). Higher positive values
  indicate increased robustness to simulated image distortions. A solid line indicates
  statistical significance at the 0.05 level whereas the dashed line indicates no
  statistically significant difference.  (Right)
  To further visualize the Tukey results, a simplified alluvial diagram is used to
  provide connections illustrating relative performance between algorithms where
  the algorithms listed on the left have improved performance relative to their
  connected algorithms on the right with the width of the connection being
  proportional to difference in performance.}
  }
  \label{fig:simulationsDataverse2}
\end{figure}

Ten simulated images for each of the subjects of both the University of Virginia
and Harvard Dataverse cohort were generated for each of the three categories of
randomly generated artefacts:  noise, nonlinearities, and combined noise and
intensity nonlinearities.  The original image as well as the simulated images
were segmented using each of the five algorithms.  Following our earlier
protocol, we maintained the original Clusters 1 and 2 per algorithm and combined
the remaining clusters into a single third cluster.  This allowed us to compare
between algorithms and maintain separate those clusters which are the most
studied and reported in the literature.  The Dice metric was used to quantify
the amount of deviation, per cluster, between the segmentation produced by the
original image and the corresponding simulated distorted image segmentation
which is summarized in Figures \ref{fig:simulations} and
\ref{fig:simulationsDataverse}. The algorithms were then compared, on a
per-cluster and per-artefact basis, using one-way ANOVA followed by Tukey's
Honest Significant Difference (HSD) test in Figures \ref{fig:simulations2} and
\ref{fig:simulationsDataverse2}.  \textcolor{blue}{The results of these tests
are further visualized via simplified alluvial diagrams with the superior
performing algorithms, in terms of Dice overlap,  listed on the
left connecting to their worse performing counterparts on the right where the width of the
connection is proportional to the overlap difference and colored by
artefact type.  The algorithms which exploit image-based spatial information,
most notably El Bicho, demonstrate generally superior performance as compared
with their histogram-only counterparts in both data sets.  For example, in
Cluster 1, for both datasets, the sole histogram-only algorithm that demonstrates
any elevated pairwise performance is k-means but, proportionally, this significance
is dwarfed by the performance of the algorithms which leverage spatial information.
Additionally, it is apparent from these tests that El Bicho consistently provides the
best performance across the specified clusters in the presence of MR-based image distortions.
}









# Discussion

\textcolor{blue}{
Over the past decade, multiple algorithms have been proposed for the
segmentation of hyperpolarized gas images into clinically based functional
categories.  These algorithms are optimized using the histogram information
primarily (with many using it exclusively) much to the detriment of
algorithmic robustness and segmentation quality. This is due to the simple fact
that these approaches discard, or do not optimally leverage, a vital piece of
information essential for accurate quantitative image interpretation---the
spatial relationships between voxel intensities.  While simplifying the
underlying complexity of the segmentation problem, these algorithms are
deficient in leveraging the general modelling principle of incorporating all
available prior information to any solution method. In fact, this is a
fundamental implication of the "No Free Lunch Theorem"}
[@Wolpert:1997aa]\textcolor{blue}{---algorithmic performance hinges on available prior
information.}

\textcolor{blue}{
As illustrated in Figure \ref{fig:similarity}, measures based on the human
visual system seem to quantify what is understood intuitively; that image-based
information is much more robust than its corresponding histogram-based
information in the presence of image transformations, such as common MR
artefacts.  This observation is not intended to imply that the histogram-based
approaches are useless in performing research.  In fact, ventilation defect
percentage is perhaps the most widely used clinical measurement reported in the
literature and it is easily quantified from the image histogram.  Thus, even
relatively simple histogram-only segmentation algorithms will provide some
utility which was observed in the measurement bias experiments employing a
variant of ventilation defect percentage to predict diagnostic accuracy.
However, similar to the lossy relationship between the image and its
corresponding histogram, such volumetric-based measures are lossy distillations
of the segmentation information and might obscure important algorithmic
characteristics and relative differences as well as discard potentially useful
spatial information which is why additional experimentation explored measurement
precision in the presence of MR artefacts.}

\textcolor{blue}{
Common MR artefacts of noise and intensity nonlinearities can produce
quantifiable differences in the segmentation results and the degree of deviation
(i.e., lack of measurement precision) largely corresponds to the algorithmic
choice of optimization domain, i.e., image-based vs. histogram-based, with those
algorithms leveraging the former providing improved segmentation repeatability.
Notably, El Bicho generally yields the best segmentation overlap measures over
the specified clusters and MR artefacts most likely due to optimization of the
governing network weights over hierarchical image features found in the training
set as opposed to strictly relative intensities and/or more simplistic
neighborhood intensity information.  In addition, this network demonstrates site
acquisition generalizability as these performance gains are also seen in the
Harvard Dataverse dataset.}

\textcolor{blue}{In addition to motivating a renewed assessment of current
algorithmic approaches to pulmonary hyperpolarized gas segmentation, there other
avenues for further research.   El Bicho was developed in parallel with the
writing of this manuscript merely to showcase the incredible potential that deep
learning can have in the field of hyperpolarized gas imaging (as well as to
update our earlier work }[@Tustison:2019ac]\textcolor{blue}{). We certainly
recognize and expect that alternative deep learning strategies (e.g.,
hyperparameter choice, training data selection, data augmentation, etc.) would
provide comparable and even superior performance to what was presented with El
Bicho. However, that is precisely our motivation for presenting this work—deep
learning, generally, presents a much better alternative than histogram
approaches as network training directly takes place in the image (i.e., spatial)
domain and not in a transformed space where key information has been discarded.
Just as important, deep learning provides other avenues for research exploration
and development. For example, given the relatively lower resolution of the
acquisition image, exploration of the effects of deep learning-based
super-resolution might prove worthy of application-specific investigation}
[@Li:2020aa]\textcolor{blue}{. Also, with the same network software libraries,
high-performing classification networks can be constructed and trained which
might yield novel insights regarding image-based characterization of disease.
One additional modification that we did not explore in this work, but is
extremely important, is the confound caused by multi-site data which has yet to
be explored in-depth. With neural networks, such confounds can be handled as
part of the training process or as an explicit network modification. Either
would be important to consider for future work.}

\textcolor{blue}{
Admittedly, this work was limited in its exploration of MR artefacts.  Noise
variation was limited to a zero-mean Gaussian distribution and nonlinear
intensity variation was explored strictly through smoothly varying histogram
deformation.   Inclusion of other noise models (e.g., shot, salt-and-pepper)
might further characterize algorithmic differences and provide additional
realistic data augmentation strategies.  Specific to nonlinear intensity
variation, a recent addition to the ANTsX ecosystem allows for the possible
simulation of bias fields which would also expand data augmentation and,
significantly, in the spirit of algorithmic parsimony, could potentially remove
the dependency of N4 bias correction as an unnecessary preprocessing step.}

\textcolor{blue}{
Finally, although ventilation defect percentage has proven to be a compelling quantity
for clinical studies, the results from the diagnostic prediction evaluation and
the previous discussion implies that this popular measure does not fully
leverage the spatial information of the segmentation information from any of
these algorithms.  Perhaps the results of this work, in addition to pointing to
the need for rethinking algorithm innovation direction, also point to possibly
investigating differentiating spatial patterns within the images as evidence of
disease and/or growth and correlations with non-imaging data using sophisticated
voxel-scale statistical techniques which intrinsically leverage spatial information (e.g.,
similarity-driven multivariate linear reconstruction} [@Avants:2021un;@Stone:2020aa]\textcolor{blue}{).}





\clearpage

## Acknowledgments {-}

Support for the research reported in this work includes funding from the
National Institutes of Health (R01HL133889; R01-CA172595 and S10-OD018079).


\newpage

# References {-}