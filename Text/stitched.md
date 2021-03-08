---
title:
author:
address:
output:
  pdf_document:
    fig_caption: true
    latex_engine: xelatex
    keep_tex: yes
    number_sections: true
    # includes:
    #   after_body: authorContributions.md
  word_document:
    fig_caption: true
bibliography:
  - references.bib
csl: journal-of-magnetic-resonance-imaging.csl
longtable: true
urlcolor: blue
header-includes:
  # - \usepackage[left]{lineno}
  # - \linenumbers
  - \usepackage{longtable}
  - \usepackage[normalem]{ulem}
  - \usepackage{graphicx}
  - \usepackage{booktabs}
  - \usepackage{listings}
  - \usepackage{textcomp}
  - \usepackage{xcolor}
  - \usepackage{multirow}
  - \usepackage{subcaption}
  - \definecolor{listcomment}{rgb}{0.0,0.5,0.0}
  - \definecolor{listkeyword}{rgb}{0.0,0.0,0.5}
  - \definecolor{listnumbers}{gray}{0.65}
  - \definecolor{listlightgray}{gray}{0.955}
  - \definecolor{listwhite}{gray}{1.0}
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

Nicholas J. Tustison,
\ldots,
Jaime F. Mata

\footnotesize

Department of Radiology and Medical Imaging, University of Virginia, Charlottesville, VA \\

\end{centering}

\vspace{7 cm}

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

Magnetic resonance imaging using hyperpolarized gases has made possible the
novel visualization of airspaces, such as the human lung, which has advanced
research into the growth, development, and pathologies of the pulmonary system.
In conjunction with the innovations associated with image acquisition, multiple
image analysis strategies have been proposed and refined for the quantification
of such lung imaging with much research effort devoted to semantic segmentation,
or voxelwise classification, into clinically oriented categories based on
ventilation levels. Given the functional nature of these images and the
consequent sophistication of the segmentation task, many of these algorithmic
approaches reduce the complex spatial image information to intensity-only
considerations, which can be contextualized in terms of the intensity histogram.
Although facilitating computational processing, this simplifying transformation
results in the loss of important spatial cues for identifying salient image
features, such as ventilation defects (a well-studied correlate of lung
pathophysiology), as spatial objects.  In this work, we discuss the
interrelatedness of the most common approaches for histogram-based optimization
of hyperpolarized gas lung imaging segmentation and demonstrate how certain
assumptions lead to suboptimal performance, particularly in terms of measurement
precision. In contrast, we illustrate how a convolutional neural network is
optimized (i.e., trained) directly within the image domain to leverage spatial
information.  This image-based optimization mitigates the problematic issues
associated with histogram-based approaches and suggests a preferred future
research direction.  Importantly, we provide the entire processing and
evaluation framework, including the newly reported deep learning functionality,
as open-source through the well-known Advanced Normalization Tools ecosystem
(ANTsX).

\newpage

<!--
\textcolor{red}{Notes to self:}

* Calling CNN "el Bicho" until we can come up a different name.
* Jaime to edit Subsections 2.1?
* Possible co-authors:  Tally Altes, Kun Qing, John Mugler, Wilson Miller, James Gee, Mu He
* \sout{Need five more young healthy subjects.}
* Need to finalize experiments

    * Nonlinear experiments: Noise, MR intensity nonlinear mapping, Noise + Nonlinear mapping
    * one issue is "should we preprocess with N4?"  --- yes, it helps segmentation, and more than
      one group uses it.
-->

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

Early attempts at quantification of ventilation images were limited to
enumerating the number of ventilation defects or estimating the proportion of
ventilated lung [@Lange:1999aa;@Altes:2001aa;@Samee:2003aa] which has
evolved to more sophisticated techniques used currently.  A brief outline of
major contributions can be roughly sketched to include:

* binary thresholding based on relative intensities
  [@Woodhouse:2005aa;@Shammi:2021aa],
* linear intensity standardization based on a global rescaling of the intensity
  histogram to a reference distribution based on healthy controls, i.e., "linear
  binning" [@He:2016aa;@He:2020aa],
* nonlinear intensity standardization based on piecewise affine transformation
  of the intensity histogram using a customized hierarchical
  [@Kirby:2012aa;@Kirby:2012ab] or adaptive [@@Zha:2016aa] k-means algorithm,
* nonlinear intensity standardization using fuzzy c-means [@Ray:2003aa] with spatial
  considerations based on local voxel neighborhoods [@Hughes:2018aa], and
* Gaussian mixture modeling (GMM) of the intensity histogram with Markov random
  field (MRF) spatial prior modeling [@Tustison:2011aa].

An early semi-automated technique used to compare smokers and never-smokers
relied on manually drawn regions to determine a threshold based on the
mean signal and noise values [@Woodhouse:2005aa].  Related approaches, which use
a simple rescaled threshold value to binarize the ventilation image into
ventilated and non-ventilated regions [@Thomen:2015aa], continue to find modern
application [@Shammi:2021aa].  Similar to the histogram-only algorithms (i.e.,
linear binning and hierarchical k-means, discussed below), these approaches do
not take into account the various MRI artefacts such as noise
[@Gudbjartsson:1995aa;@Andersen:1996aa] and the intensity inhomogeneity field
[@Sled:1998aa] which prevent hard threshold values from distinguishing tissue
types precisely consistent with that of human experts.  In addition, to provide
a more granular categorization of ventilation for greater compatibility with
clinical qualitative assessment, many current techniques have increased the
number of voxel classes (i.e., clusters) beyond the binary categories of
"ventilated" and "non-ventilated."

Linear binning is a simplified type of MR intensity standardization
[@Nyul:1999aa] in which images from healthy controls are normalized to
the range [0, 1] and then used to calculate the cluster intensity boundary values, based on an
aggregated estimate of the parameters of a single Gaussian fit. Subject images
to be segmented are then rescaled to this reference histogram (i.e., a global
affine 1-D transform). This mapping results in alignment of the cluster
boundaries such that corresponding labels are assumed to have similar clinical
interpretation. In addition to the previously mentioned limitations associated with
hard threshold values, such a global transform does not account for MR intensity
nonlinearities that have been well-studied
[@Wendt:1994aa;@Nyul:1999aa;@Nyul:2000aa;@Collewet:2004aa;@De-Nunzio:2015aa] and
are known to cause significant intensity variation even in the same region of
the same subject.  As stated in [@Collewet:2004aa]:

> Intensities of MR images can vary, even in the same protocol and the same
> sample and using the same scanner. Indeed, they may depend on the acquisition
> conditions such as room temperature and hygrometry, calibration adjustment,
> slice location, B0 intensity, and the receiver gain value. The consequences of
> intensity variation are greater when different scanners are used.

As we illustrate in subsequent sections, ignoring these nonlinearities is known
to have significant consequences in the well-studied (and somewhat analogous)
area of brain tissue segmentation in T1-weighted MRI (e.g.,
[@Zhang:2001aa;@Ashburner:2005aa;@Avants:2011aa]).  Here we demonstrate its effects
in hyperpolarized gas imaging quantification robustness in conjunction with
noise considerations.  In addition, the reference distribution required by
linear binning assumes sufficient agreement as to what constitutes a "healthy
control", whether a Gaussian fit is appropriate, and, even assuming the latter,
whether or not the parameter values can be combined in a linear fashion to
constitute a single reference standard. Of additional concern, though, is
that the requirement for a healthy cohort for determination of algorithmic
parameters introduces a non-negligible source of measurement variance, as we
will also demonstrate.

Previous attempts at histogram standardization [@Nyul:1999aa;@Nyul:2000aa] in
light of MR intensity nonlinearities have relied on 1-D piecewise affine
mappings between corresponding structural features found within the histograms
themselves (e.g., peaks and valleys).  For example, structural MRI, such as
T1-weighted neuroimaging, utilizes the well-known relative intensities of major
tissue types (i.e., cerebrospinal fluid (CSF), gray matter (GM), and white
matter(WM)), which characteristically correspond to visible histogram peaks, as
landmarks to determine the nonlinear intensity mapping between histograms.
However, in hyperpolarized gas imaging of the lung, no such characteristic
structural features exist, generally speaking, between histograms.  This is most
likely due to the primarily functional utility (vs. anatomical) nature of these
images. The approach used by some groups [@Cooley:2010aa;@Kirby:2012aa] of
employing some variant of the well-known k-means algorithm as a clustering
strategy [@Hartigan:1979aa] to minimize the within-class variance of its
intensities can be viewed as an alternative optimization strategy for
determining a nonlinear mapping between histograms for a type of  MR
intensity standardization. K-means constitutes an algorithmic approach with
additional flexibility and sophistication over linear binning as it
employs prior knowledge in the form of a generic clustering desideratum
for optimizing a type of MR intensity standardization.[^1]

[^1]: The prior knowledge for histogram mapping is the general machine learning
heuristic of clustering samples based on the minimizing within-class distance
while simultaneously maximizing the between-class distance.  In the case of
k-means, this "distance" is the intensity variance.

Similar to k-means, fuzzy c-means seeks to minimize the within-class sample
variance but includes a per-sample membership weighting [@Bezdek:1981aa]. Later
innovations included the incorporation of spatial considerations using
class membership values of the local voxel neighborhood [@Chuang:2006aa].  Both
k-means and fuzzy spatial c-means were compared for segmentation of
hyperpolarized He-3 and Xe-129 images in [@Hughes:2018aa] with the latter
evidencing improved performance over the former which is due, at least in part,
to the additional spatial considerations.  Despite relatively good performance,
however, fuzzy c-means also seeks cluster membership in the histogram (i.e.,
intensity-only) domain with only simplistic neighborhood modeling during
optimization.

Histogram-based optimization is used in conjunction with spatial considerations
in the segmentation algorithm detailed in [@Tustison:2011aa].  This algorithm is
based on a well-established iterative approach originally used for NASA
satellite image processing and subsequently appropriated for brain tissue
segmentation in [@Vannier:1985aa].  A Gaussian mixture model (GMM) is used to
model the intensity clusters of the histogram with class modulation in the form
of probabilistic voxelwise label considerations, i.e., Markov random field (MRF)
modeling,  within image neighborhoods [@Besag:1986aa] optimized with the
expectation-maximization (EM) algorithm [@Dempster:1977aa].  This has the
advantage, in contrast to histogram-only algorithms, that it softens the
intensity thresholds between class labels which demonstrates robustness to
certain imaging distortions, such as noise.  However, as we will demonstrate,
this algorithm is also flawed in the inherent assumption that meaningful
structure is found, and can be adequately characterized, within the associated
image histogram in order to optimize a multi-class labeling.  In particular,
this algorithm is susceptible to MR nonlinear intensity artefacts.

Additionally, many of these segmentation algorithms use N4 bias correction
[@Tustison:2010ac], an extension of the nonuniform intensity normalization (N3)
algorithm [@Sled:1998aa],  to mitigate MR intensity inhomogeneity artefacts.
Interestingly, N3/N4 also iteratively optimizes towards a final solution using
information from both the histogram and image domains.  Based on the intuition
that the bias field acts as a smoothing convolution operation on the original
image intensity histogram, N3/N4 optimizes a nonlinear (i.e., deformable)
intensity mapping, based on histogram deconvolution.  This nonlinear mapping is
constrained such that its effects smoothly vary across the image.  Additionally,
due to the deconvolution operation, this nonlinear mapping sharpens the
histogram peaks which presumably correspond to tissue types. While such
assumptions are appropriate for the domain in which N3/N4 was developed (i.e.,
T1-weighted brain tissue segmentation) and while it is assumed that the
enforcement of low-frequency modulation of the intensity mapping prevents new
image features from being generated, it is not clear what effects N4 parameter
choices have on the final segmentation solution, particularly for those
algorithms that are limited to intensity-only considerations and not robust to
the aforementioned MR intensity nonlinearities.

## Motivation for current study

\begin{figure}[!h] \centering
  \includegraphics[width=0.9\linewidth]{Figures/motivation.pdf}
  \caption{Illustration of the effect of MR nonlinear intensity warping on the
  histogram structure.  We simulate these mappings by perturbing specified
  points along the bins of the histograms by a Gaussian random variable of 0
  mean and specified max standard deviation (``Max SD'').  By simulating these
  types of intensity changes, we can visualize the effects on the underlying
  intensity histograms and investigate the effects on salient outcome measures.
  Here we simulate intensity mappings which, although relatively small, can have
  a significant effect on the histogram structure.}
  \label{fig:motivation}
\end{figure}

Investigating the assumptions outlined above, particularly
those associated with the nonlinear intensity mappings due to both the MR
acquisition and inhomogeneity mitigation preprocessing, we became concerned by
the susceptibility of the histogram structure to such variations and the
potential effects on current clinical measures of interest derived from these
algorithms (e.g., ventilation defect percentage).  Figure \ref{fig:motivation}
provides a sample visualization representing some of the structural changes that
we observed when simulating these nonlinear mappings.  It is important to notice
that even relatively small alterations in the image intensities can have
significant effects on the histogram even though a visual
assessment of the image can remain largely unchanged.

\begin{figure}[!htb] \centering
  \includegraphics[width=0.95\textwidth]{Figures/similarityMultisite.pdf}
  \caption{Multi-site:  (left) University of Virginia (UVa) and (right)
  He 2019 data.
  Image-based SSIM vs. histogram-based Pearson's correlation differences
  under distortions induced by the common MR artefacts of noise and intensity nonlinearities.  For the
  nonlinearity-only simulations, the images maintain their structural integrity
  as the SSIM values remain close to 1.  This is in contrast to the
  corresponding range in histogram similarity which is much larger.
  Although not as great, the range in histogram differences with simulated noise
  is much greater than the range in SSIM.  Both sets of observations are evidence of
  the lack of robustness to distortions in the histogram domain in comparison with
  the original image domain.}
  \label{fig:similarity}
\end{figure}

To briefly explore these effects further for the purposes of motivating
additional experimentation, we provide a summary illustration from a set of
image simulations in Figure \ref{fig:similarity} which are detailed later in
this work and used for algorithmic comparison.  Simulated MR artefacts were
applied to each image which included both noise and nonlinear intensity mappings
(and their combination) using two separate data sets:  one in-house data set
consisting of 51 hyperpolarized gas lung images and the publicly available data
described in [@He:2019aa] and made available at Harvard's Dataverse online
repository [@He_dataverse:2018] consisting of 29 hyperpolarized gas lung images.
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
any algorithmic considerations, these observations point to the fact that
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
these algorithms have certainly demonstrated the capacity for advancing such
research.  Furthermore, as the sample segmentations in Figure
\ref{fig:sampleSegmentations} illustrate, when considered qualitatively, each
segmentation algorithm appears to produce a reasonable segmentation even though
the voxelwise differences are significant (as are the corresponding histograms).
However, the aforementioned artefact issues influence quantitation in terms of
core scientific measurement principles such as precision (e.g., reproducibility
and repeatability [@Zha:2016aa;@Svenningsen:2020aa]) and bias which are obscured
in isolated considerations but become increasingly significant with multi-site
[@Couch:2019aa] and large-scale studies.  In addition, generally speaking,
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
[@LeCun:2015aa], particularly convolutional neural networks (CNN).[^101]
Such models have demonstrated outstanding performance in certain computational tasks,
including classification and semantic segmentation in medical imaging
[@Shen:2017aa]. Their potential for leveraging spatial information from images
surpasses the perceptual capabilities of previous approaches and even rivals
that of human raters [@Zhang:2018aa].  Importantly, CNN optimization occurs
directly in the image space to learn complex spatial features, in contrast to
the previously discussed methods where optimization (primarily) concerns image
intensity only information.  We introduced a deep learning approach in
[@Tustison:2019ac] and further expand on that work for comparison with existing
approaches below.  Although we find its performance to be quite promising, more
fundamental to this work than the network itself is simply pointing to the
general potential associated with  deep learning for analyzing hyperpolarized
gas images *as spatial samplings of real world objects*, as opposed to lossy
representations of such objects.  In the spirit of open science, we have made
the entire evaluation framework, including our novel contributions, available
within the Advanced Normalization Tools software ecosystem (ANTsX)
[@Tustison:2020aa].





# Materials and methods

## Hyperpolarized gas imaging acquisition

### University of Virginia cohort

A retrospective dataset was collected consisting of young healthy (n=10), older
healthy (n=7), cystic fibrosis (CF) (n=14), interstitial lung disease (ILD)
(n=10), and chronic obstructive pulmonary disease (n=10). MR iImaging with
hyperpolarized 129Xe gas was performed under an Institutional Review Board
(IRB) approved protocol with written informed consent obtained from each
subject. In addition, all imaging was performed under a Food and Drug
Administration (FDA) approved physician’s Investigational New Drug application
(IND 57866) for hyperpolarized 3He. MRI data were acquired on a 1.5 T whole-body
MRI scanner (Siemens Avanto, Siemens Medical Solutions, Malvern, PA) with
broadband capabilities and a flexible 129Xe 3He chest radiofrequency coil (RF;
IGC Medical Advances, Milwaukee, WI; or Clinical MR Solutions, Brookfield, WI).
During a <10–20-second breath-hold following the inhalation of $\approx 1000$ mL of
hyperpolarized 129Xe mixed with nitrogen up to a volume equal to
1/3 Forced vital capacity (FVC) of the respective subject, a set of 15-17
contiguous coronal lung slices were collected in order to cover the
entire lungs. Parameters of the Gradient echo (GRE) sequence
with a Spiral k-space sampling with 12 interleaves for 129Xe MRI were as
follows: repetition time msec / echo time msec, 7/1; flip angle, 20$^{\circ}$;
matrix, 128 $\times$ 128: in-plane voxel size, 4 $\times$ 4 mm;
section slice thickness, 15 mm; and intersection gap, none. The data were
deidentified prior to analysis.


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

### He 2019 Harvard Dataverse cohort

In addition to these data acquired at the University of Virginia, we also
processed a publicly available lung dataset [@He_dataverse:2018] available at
the Harvard Dataverse and detailed in [@He:2019aa].  These data comprised
the original 129Xe acquisitions from 29 subjects (10 healthy controls
and 19 mild intermittent asthmatic individuals) with corresponding lung masks.
In addition, seven artificially SNR-degraded images per acquisition were also
included but not used for the analyses reported below.  The image headers were
corrected for proper canonical anatomical orientation according to Nifti
standards and provided to the GitHub repository associated with this work.

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
  upon request and through a data sharing agreement.  In addition to the citation
  providing the online location of the original He 2019 Dataverse data, a
  header-modified version of these data is available in the GitHub repository
  associated with this manuscript.  Additional evaluation plots are also
  available at this location.

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


# Results

We performed several comparative evaluations to probe the previously mentioned
algorithmic issues which are broadly categorized in terms of measurement bias
and precision, with most of the focus being on the latter.  Given the lack of
ground-truth in the form of segmentation images, addressing issues of measurement
bias is difficult.  In addition to the fact that the number of ventilation clusters
is not consistent across algorithms, it is not clear that the ventilation categories
across algorithms have identical clinical definition.  This prevents application of
various frameworks accommodating the lack of ground-truth for segmentation performance
analysis (e.g., [@Warfield:2004aa]) to these data.

As we mentioned in the Introduction, all the algorithms have demonstrated
research utility and potential clinical utility based on findings using derived
measures. This is supported by our first evaluation which is based on diagnostic
prediction of given clinical categories assigned to the imaging cohort using
derived random forest models [@Breiman:2001aa].  This approach also provides an
additional check on the validity of the algorithmic implementations.  However,
it is important to recognize that this evaluation is extremely limited as the
underlying data are gross measures which do not provide accuracy estimates on
the level of the algorithmic output (i.e., voxelwise segmentation).

Having established the general validity of the gross algorithmic output, we then
switch to our primary focus which is the comparison of measurement precision
between algorithms.   We first analyze the unique requirement of a reference
distribution for the linear binning algorithm.  The latter is motivated
qualitatively through the analogous application of T1-weighted brain MR
segmentation.  This component is strictly qualitative as the visual evidence and
previous developmental history within that field should be sufficiently
compelling in motivating subsequent quantitative exploration with hyperpolarized
gas lung imaging.  These qualitative results segue to quantifying the effects of
the choice of reference cohort on the clustering parameters for the linear
binning algorithm. We then incorporate the trained El Bicho model in exploring
additional aspects of measurement variance based on simulating both MR noise and
intensity nonlinearities.

So, in summary, we perform the following evaluations/experiments:[^103]

* Global algorithmic bias (in the absence of ground truth)

    * Diagnostic prediction

* Voxelwise algorithmic precision

    * Three-tissue T1-weighted brain MRI segmentation (qualitative analog)
    * Input/output variance based on reference distribution (linear binning only)
    * Effects of simulated MR artefacts on multi-site data

[^103]: It is important to note that, although these experiments provide supporting
evidence, our principal contention stands prior to these results and are based on
the self-evidentiary observations mentioned in the Introduction.

## Diagnostic prediction

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.99\linewidth]{Figures/volumeXRocDx.pdf}
  \caption{ROC curves resulting from the diagnostic prediction evaluation
  strategy involving randomly permuted training/testing data sets and predictive
  random forest models. Summary values are provided in Table \ref{table:auc}.}
  \label{fig:DxPrediction}
\end{figure}

Due to the absence of ground-truth, we adopted
the strategy from previous work [@Tustison:2014ab;@Tustison:2020aa] where we
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
volume.  We used a training/testing split of 80/20.  Due to the small number
of subjects, we combined the young and old healthy data into a single category.
100 permutations were used where training/testing data were randomly assigned
and the corresponding random forest model was constructed at each permutation.

\input{dxPredictionAucTable}

The resulting receiver operating characteristic (ROC) curves for each algorithm
and each diagnostic scenario are provided in Figure \ref{fig:DxPrediction}.  In
addition, we provide the summary area under the ROC curve (AUC) values in Table
\ref{table:auc}. In the absence of ground truth, this type of evaluation does
provide evidence that all these algorithms produce measurements which are clinically
relevant although, it should be noted, that this is a very coarse assessment strategy
given the global measures used (i.e., cluster volume percentage) and the general
clinical categories employed.  In fact, even spirometry measures can be used to achieve
highly accurate diagnostic predictions with machine learning techniques
[@Badnjevic:2018aa].

## T1-weighted brain segmentation analogy

\begin{figure}[!h]
  \centering
  \includegraphics[width=0.95\linewidth]{Figures/BrainAnalogy.pdf}
  \caption{T1-weighted three-tissue brain segmentation analogy. Placing
  three of the five segmentation algorithms (i.e., linear binning, k-means, and GMM-MRF) in
  the context of brain tissue segmentation provides an alternative perspective
  for comparison.  In the style of linear binning, we randomly select an image
  reference set using structurally normal individuals which is then used to
  create a reference histogram.  (Bottom) For a subject to be processed, the
  resulting hard threshold values yield the linear binning segmentation solution
  as well as the initialization cluster values for both the k-means and GMM-MRF
  segmentations which are qualitatively different.}
  \label{fig:BrainAnalogy}
\end{figure}

Much of the quantitative image analysis strategies that have been used for
hyperpolarized gas imaging draw on inspiration from fields with a much greater
historical background of development, including T1-weighted brain MRI tissue
segmentation.  The depth of this development can be gauged simply by the number
of technical reviews (e.g., [@Bezdek:1993aa;@Pham:2000aa;@Despotovic:2015aa]) and
evaluation studies (e.g., [@Cuadra:2005aa;@Boer:2010aa]) that date back decades.
In addition to technical insight, this particular application provides a useful
analogy for some of the algorithmic issues discussed and provides context for
subsequent evaluations specific to hyperpolarized gas imaging.

In the style of linear binning, we randomly selected ten structurally healthy
controls from the publicly available SRPB data set [@srpb] comprising over 1600
participants from 12 sites.  After intensity truncation at the 0.99 quantile, we
normalize the intensity histogram to [0,1].  Eight of these histograms are
provided in the upper left of Figure \ref{fig:BrainAnalogy}.  As we mentioned
previously, the histograms for these structural MRI are typically characterized
by three peaks which correspond to the CSF, GM, and WM.  However, even when
normalized to [0, 1] (i.e., global affine mapping), it is obvious that these
histogram features do not line up and this is due to the intensity distortion
caused by various MR acquisition artefacts mentioned previously.  This is an
argument from analogy against one of the principal assumptions of linear binning
where it is assumed that tissue types ("structural" in the case of T1-weighted
brain MRI or "ventilated" in the case of hyperpolarized gas imaging) can be
sufficiently aligned with a global rescaling of intensity values. If we pursue
this analogy further and use the aggregated reference distribution to segment a
different subject, we can see that, in this particular case, whereas the
optimization criterion leveraged by k-means and GMM-MRF provide an adequate
segmentation, the misalignment in cluster boundaries yield a significant
overestimation of the gray matter volume.


## Effect of reference image set selection

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
\end{figure}

One of the additional input requirements for linear binning over the other
algorithms is the generation of a reference distribution.  In addition to the
output measurement variation caused by choice of the reference image cohort,
this played a role in determining whether or not to use N4 preprocessing. As
mentioned, a significant portion of N4 processing involves the deconvolution of
the image histogram to sharpen the histogram peaks which decreases the standard
deviation of the intensity distribution and can also result in a histogram
shift. Using the original set of 10 young healthy data with no N4 preprocessing,
we created a reference distribution according to [@He:2016aa], which resulted in
an approximate distribution of $\mathcal{N}(0.45, 0.24)$.  This produced 0
voxels being classified as belonging to Cluster 1 (Figure \ref{fig:referenceVariance})
because two standard deviations from the mean is less than 0 and Cluster 1
resides in the region below -2 standard deviations.  However, using N4-preprocessed
images produced something closer,  $\mathcal{N}(0.56, 0.22)$, to the published
values, $\mathcal{N}(0.52, 0.18)$, reported in [@He:2016aa], resulting in a
non-empty set for that cluster.  This is consistent, though, with linear binning
which does use N4 bias correction for preprocessing.  We also mention that the
2019 Harvard Dataverse images used were preprocessed using N4 [@He:2019aa]
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
  \includegraphics[width=0.99\linewidth]{Figures/DiceVarianceStudy.pdf}
  \caption{University of Virginia image cohort:  (Left) The deviation in
  resulting segmentation caused by distortions produced noise, histogram-based
  intensity nonlinearities, and their combination as measured by the Dice
  metric.  Each segmentation is reduced to three labels for comparison:
  ``ventilation defect'' (Cluster 1), ``hypo-ventilation'' (Cluster 2), ``other
  ventilation'' (Cluster 3). (Right) Results from the Tukey Test following
  one-way ANOVA to compare the deviations.  Higher positive values are
  indicative of increased robustness to simulated image distortions.
         }
\label{fig:simulations}
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
  \includegraphics[width=0.99\linewidth]{FiguresDataverse/DiceVarianceStudy.pdf}
  \caption{2019 Harvard Dataverse image cohort:  (Left) The deviation in
  resulting segmentation caused by distortions produced noise, histogram-based
  intensity nonlinearities, and their combination as measured by the Dice
  metric.  Each segmentation is reduced to three labels for comparison:
  ``ventilation defect'' (Cluster 1), ``hypo-ventilation'' (Cluster 2), ``other
  ventilation'' (Cluster 3). (Right) Results from the Tukey Test following
  one-way ANOVA to compare the deviations.  Higher positive values are
  indicative of increased robustness to simulated image distortions.
         }
\label{fig:simulationsDataverse}
\end{figure}

Ten simulated images for each of the subjects of both the University of Virginia
and 2019 Harvard Dataverse cohort were generated for each of the three
categories of randomly generated artefacts:  noise, nonlinearities, and combined
noise and intensity nonlinearites.  The original image as well as the simulated
images were segmented using each of the five algorithms.  Following our earlier
protocol, we maintained the original Clusters 1 and 2 per algorithm and combined
the remaining clusters into a single third cluster.  This allowed us to compare
between algorithms and maintain separate those clusters which are the most
studied and reported in the literature.  The Dice metric was used to quantify
the amount of deviation, per cluster, between the segmentation produced by the
original image and the corresponding simulated distorted image segmentation
which are plotted in Figures \ref{fig:simulations} and
\ref{fig:simulationsDataverse} (left column). These results were then compared,
on a per-cluster and per-artefact basis, using a one-way ANOVA followed by
Tukey's Honest Significant Difference (HSD) test. 95% confidence intervals are
provided in the right column of Figures \ref{fig:simulations} and
\ref{fig:simulationsDataverse}.



# Discussion

Over the past decade, multiple segmentation algorithms have been proposed for
hyperpolarized gas images which, as we have pointed out, are all highly
dependent on the image intensity histogram for optimization.  All these
algorithms use the histogram information *primarily* (with many using it
*exclusively*) for optimization  much to the detriment of algorithmic robustness
and segmentation quality.  This is due to the simple observation that these
approaches discard a vital piece of information essential for image
interpretation, i.e., the spatial relationships between voxel intensities.  A
brief summary of criticisms related to current algorithms is as follows:

* In addition to completely discarding spatial information, linear binning is
  based on overly simplistic assumptions, especially given common MR artefacts.
  The additional requirement of a reference distribution, with its questionable
  assumption of Gaussianity and known distributional parameters for healthy
  controls, is also a potential source of output variance.

* Both hierarchical and adaptive k-means also ignore spatial information and,
  although they do use a principled optimization criterion, this criterion is
  not adequately tailored for hyperpolarized gas imaging and susceptible to
  various levels of noise.

* Similar to k-means, spatial fuzzy c-means is optimized to minimize the
  within-class intensity variance but does incorporate spatial considerations
  which softens the hard threshold values and demonstrates improved robustness
  to noise.  However, it is susceptible to variations caused by MR nonlinear
  intensity variation, similar to the GMM-MRF technique.

* The GMM-MRF approach does employ spatial considerations in the form of Markov
  random fields but these are highly simplistic, based on prior modeling of local
  voxel neighborhoods which do not capture the complexity of ventilation
  defects/heterogeneity appearance in the images.  Although the simplistic
  assumptions provide some robustness to noise, the highly variable histogram
  structure in the presence of MR nonlinearities can cause significant variation in
  the resulting GMM fitting.

While simplifying the underlying complexity of the segmentation problem, all of
these algorithms are deficient in leveraging the general modelling principle of
incorporating as much available prior information to any solution method.
In fact, this is a fundamental implication of the  "No Free Lunch Theorem"
[@Wolpert:1997aa]---algorithmic performance hinges on available prior
information.

As illustrated in Figure \ref{fig:similarity}, measures based on the human
visual system seem to quantify what is understood intuitively that image domain
information is much more robust than histogram domain information in the
presence of image transformations, such as distortions.  This appears to also be
supported in our simulation experiments illustrated in Figure
\ref{fig:simulations} and \ref{fig:simulationsDataverse} where the
histogram-based algorithms, overall, performed worse than El Bicho.  As a CNN,
El Bicho optimizes the governing network weights over image features as opposed
to strictly relative intensities.  This work should motivate additional
exploration focusing on issues related to algorithmic bias on a voxelwise scale
which would require going beyond simple globally based assessment measures (such
as the diagnostic prediction evaluation detailed above using global volume
proportions).  This would enable investigating differentiating spatial patterns
within the images as evidence of disease and/or growth and correlations with
non-imaging data using sophisticated voxel-scale statistical techniques (e.g.,
symmetric multivariate linear reconstruction [@Stone:2020aa]).

It should be noted that El Bicho was developed in parallel with the writing of
this manuscript merely to showcase the incredible potential that deep learning
can have in the field of hyperpolarized gas imaging (as well as to update our
earlier work [@Tustison:2019ac]).   We certainly recognize and expect that
alternative deep learning strategies (e.g., hyperparameter choice, training data
selection, data augmentation, etc.) would provide comparable and even superior
performance to what was presented with El Bicho.  However, that is precisely our
motivation for presenting this work---deep learning, generally, presents a much
better alternative than histogram approaches as network training directly takes
place in the image (i.e., spatial) domain and not in a transformed space where
key information has been discarded.

Just as important, deep learning provides other avenues for research exploration
and development. For example, given the relatively lower resolution of the
acquisition image, exploration of the effects of deep learning-based
super-resolution might prove worthy of application-specific investigation
[@Li:2020aa] (see, for example, ``ANTsRNet::mriSuperResolution``).  Also, with
the same network software libraries, high-performing classification networks can
be constructed and trained which might yield novel insights regarding
image-based characterization of disease.  One additional modification that we
did not explore in this work, but is extremely important, is the confound caused
by multi-site data which has yet to be explored in-depth.  With neural networks,
such confounds can be handled as part of the training process or as an explicit
network modification.  Either would be important to consider for future work.




\clearpage

## Acknowledgments {-}

Support for the research reported in this work includes funding from the
National Heart, Lung, and Blood Institute  of the National Institutes of Health
(R01HL133889).


\newpage

# References {-}