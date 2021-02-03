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

{\bf Histograms should not be used to segment hyperpolarized gas images of the lung}

\vspace{1.5 cm}

\normalsize

Nicholas J. Tustison,
\ldots,
Jaime F. Mata

\footnotesize

Department of Radiology and Medical Imaging, University of Virginia, Charlottesville, VA \\

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

Magnetic resonance imaging using hyperpolarized gases has made possible the
novel visualization of airspaces, such as the human lung, which has advanced
research into the growth, development, and pathologies of the pulmonary system.
In conjunction with the innovations associated with image acquisition, multiple
image analysis strategies have been proposed and refined for the quantification
of hyperpolarized gas images with much research effort devoted to semantic
segmentation, or voxelwise classification, into clinically-oriented categories
based on ventilation levels. Given the functional nature of these images and the
consequent sophistication of the segmentation task, many of these algorithmic
approaches reduce the complex spatial image intensity information to
intensity-only considerations, which can be contextualized in terms of the
intensity histogram. Although facilitating computational processing, this
simplifying transformation results in the loss of important spatial cues for
identifying salient image features, such as ventilation defects---a well-studied
correlate of lung pathophysiology.  In this work, we discuss the
interrelatedness of the most common approaches for histogram-based segmentation
of hyperpolarized gas lung imaging and evaluate the underlying assumptions
associated with each approach demonstrating how these assumptions lead to
suboptimal performance, particularly in terms of precision.  We then
illustrate how a convolutional neural network can be trained to leverage
multi-scale spatial information which circumvents the problematic issues
associated with these approaches.  Importantly, we provide the entire processing
and evaluation framework, including the newly reported deep learning
functionality, as open-source through the well-known Advanced Normalization
Tools ecosystem (ANTsX).

\newpage

\textcolor{red}{Notes to self:}

* Calling CNN "el Bicho" until we can come up a different name.
* Jaime to edit Subsections 2.1?
* Possible co-authors:  Tally Altes, Kun Qing, John Mugler, Wilson Miller, James Gee, Mu He
* Need five more young healthy subjects.
* Need to finalize experiments

    * Nonlinear experiments: Noise, MR intensity nonlinear mapping, Noise + Nonlinear mapping
    * one issue is "should we preprocess with N4?"  --- yes, it helps segmentation, and more than
      one group uses it.

* Should we retrain with shot/salt and pepper?  No let's wait until after the first round of experiments.

\newpage
# Introduction

## Early acquisition and development

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
  tiny to segmental" [@Altes:2001aa]


## Historical overview of quantification

Early attempts at quantification of ventilation images were limited to
enumerating the number of ventilation defects or estimating the proportion of
ventilated lung [@Lange:1999aa;@Altes:2001aa;@Samee:2003aa].  This early work
has evolved to current techniques which can be generally categorized in order of
increasing algorithmic sophistication as follows:

* binary thresholding based on relative intensities
  [@Woodhouse:2005aa;@Shammi:2021aa],
* linear intensity standardization based on global rescaling of the intensity
  histogram to a reference distribution based on healthy controls, i.e., "linear
  binning" [@He:2016aa;@He:2020aa],
* nonlinear intensity standardization based on piecewise affine transformation
  of the intensity histogram using a customized hierarchical k-means algorithm
  [@Kirby:2012aa;@Kirby:2012ab], and
* Gaussian mixture modeling (GMM) of the intensity histogram with Markov random
  field (MRF) spatial prior modeling [@Tustison:2011aa].

We purposely couch these algorithms within the context of the intensity
histogram for facilitating comparison.

An early semi-automated technique used to compare smokers and never-smokers
relied on manually drawn regions to determine a threshold value based on the
mean signal and noise values [@Woodhouse:2005aa].  Related approaches, which use
a simple rescaled threshold value to binarize the ventilation image into
ventilated/non-ventilated regions [@Thomen:2015aa], continue to find modern
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
[@Nyul:1999aa] in which a set of healthy controls, all intensity normalized to
[0, 1], is used to calculate the cluster threshold values, based on a single
Gaussian model. A subject image to be segmented is then rescaled to this
reference histogram (i.e., a global affine 1-D transform). This mapping aligns
the cluster boundaries such that corresponding labels have the same clinical
interpretation. In addition to the previously mentioned issues associated with
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

As we demonstrate in subsequent sections, ignoring these nonlinearities can have
significant consequences in the well-studied (and somewhat analogous) area of
brain tissue segmentation in T1-weighted MRI (e.g.,
[@Zhang:2001aa;@Ashburner:2005aa;@Avants:2011aa]) and we demonstrate its effect
in hyperpolarized gas imaging quantification robustness in conjunction with
noise considerations.  In addition, it is not a given that we have a sufficient
understanding of what constitutes a "normal" in the context of mean and standard
deviation MR intensity values and whether or not those values can be combined in
a linear fashion to constitute a reference standard. Of more concrete concern,
though, is that the requirement for a healthy cohort for determination of
algorithmic parameters introduces a non-negligible source of measurement
variance, as we will also demonstrate.

Previous attempts at histogram standardization [@Nyul:1999aa;@Nyul:2000aa] in
light of these MR intensity nonlinearities have relied on 1-D piecewise affine
mappings between corresponding structural features found within the histograms
(i.e., peaks and valleys).  For example, structural MRI, such as T1-weighted
neuroimaging, utilizes the well-known relative intensities of major tissues
types (i.e., cerebrospinal fluid, gray matter, and white matter), which
characteristically correspond to visible histogram peaks, as landmarks to
determine the nonlinear intensity mapping between images. However, in
hyperpolarized gas imaging of the lung, no such characteristic structural
features exist, generally speaking, between histograms.  The approach used by
some groups [@Cooley:2010aa;@Kirby:2012aa] of employing k-means as a clustering strategy
[@Hartigan:1979aa] to minimize the within-class variance of its intensities can
be viewed as an alternative optimization strategy for determining a nonlinear
mapping between histograms for a clinically-based MR intensity standardization.
K-means does constitute an algorithmic approach with additional degrees of
flexibility and sophistication over linear binning as it employs basic prior
knowledge in the form of a generic clustering desideratum for optimizing a type
of MR intensity standardization.[^1]

[^1]: The prior knowledge for histogram mapping is the general machine learning
heuristic of clustering samples based on the minimizing within-class distance
while simultaneously maximizing the between-class distance.  In the case of
k-means, this "distance" is the intensity variance as optimizing based on the
Euclidean distance is NP-hard.

Histogram-based optimization is used in conjunction with spatial considerations
in the approach detailed in [@Tustison:2011aa].  Based on a well-established
iterative approach originally used for NASA satellite image processing and
subsequently appropriated for brain tissue segmentation in T1-weighted MRI
[@Vannier:1985aa], a GMM is used to model the intensity clusters of the
histogram with class modulation in the form of probabilistic voxelwise label
considerations, i.e. Markov Random Field (MRF) modeling,  within image
neighborhoods [@Besag:1986aa] using the expectation-maximization (EM) algorithm
[@Dempster:1977aa].  Initialization for this particular application is in the
form of k-means clustering which, itself, is initialized automatically using
evenly spaced cluster centers---similar to linear binning.  This has a number of
advantages in that it accommodates MR intensity nonlinearities, like k-means,
but in contrast to hierarchical k-means and the other algorithms outlined, does
not use hard intensity thresholds for distinguishing class labels.  However, as
we will demonstrate, this algorithm is also flawed in that it implicitly
assumes, incorrectly, that meaningful structure is found, and can be adequately
characterized, within the associated image histogram in order to optimize a
multi-class labeling.

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

It should be clear that all these methods can be described in terms of the
intensity histogram. Investigating the assumptions outlined above, particularly
those associated with the nonlinear intensity mappings due to both the MR
acquisition and inhomogeneity mitigation preprocessing, we became concerned by
the susceptibility of the histogram structure to such variations and the
potential effects on current clinical measures of interest derived from these
algorithms (e.g., ventilation defect percentage).  Figure \ref{fig:motivation}
provides a sample visualization representing some of the structural changes that
we observed when simulating these nonlinear mappings.  It is important to notice
that even relatively small alterations in the image intensities can have
significant effects on the histogram even though a visual, clinically-based
assessment of the image can remain largely unchanged.  In further support,
we provide a summary measure from a set of experiments detailed later in this
work.  Figure \ref{fig:similarity} is not derived from the algorithmic comparisons
but simply demonstrates the importance of the considerations of the issues just
raised.  The structural similarity index measurement (SSIM) is a highly cited
quantity within the computer vision literature used for assessing image
quality, often under transformation processes, e.g., image compression.

*In addition to the simple fact that it discards important spatial information,
 although the image-to-histogram transformation simplifies computation, this transformation
results in greater outcome variance in the resulting information under common
MR imaging artefacts, according to these measures.*

\begin{figure}[!h] \centering
  \includegraphics[width=0.95\textwidth]{Figures/similarity.pdf}
  \caption{}
  \label{fig:similarity}
\end{figure}

Ultimately, we are not claiming that these algorithms are erroneous, per se.
Much of the relevant research has been limited to quantifying differences with
respect to ventilation versus non-ventilation in various clinical categories and
these algorithms have certainly demonstrated the capacity for advancing such
research.  However, these issues influence quantitation in terms of core
scientific measurement principles such as precision (e.g., reproducibility and
repeatability [@Svenningsen:2020aa]) and bias which will become more acute as
multi-site and large-scale studies are performed.  In addition, generally
speaking, refinements in measuring capabilities correlates with scientific
advancement so as acquisition and analysis methodologies improve, so should the
level of sophistication and performance of the measurement tools.

The recent emergence of deep-layered neural networks [@LeCun:2015aa],
particularly convolutional neural networks (CNN), is due to their outstanding
performance in certain computational tasks, including classification and
semantic segmentation in medical imaging [@Shen:2017aa].  Their potential for
leveraging spatial information from images surpasses the perceptual capabilities
of previous approaches and even rivals that of human raters [@Zhang:2018aa]. In
assessing these segmentation algorithms for hyperpolarized gas imaging, it is
important to note that human expertise leverages more than relative intensity
values to identify salient, clinically relevant features in images---something
more akin to the complex neural network structure versus the 1-D intensity
histogram. We introduced a deep learning approach in [@Tustison:2019ac] and
further expand on that work for comparison with existing approaches in this
work.  In the spirit of open science, we have made the entire evaluation
framework, including our novel contributions, available within our Advanced
Normalization Tools software ecosystem (ANTsX).








# Materials and methods

To support the discussion in the Introduction, we perform various experiments to
showcase the effects of both MR nonlinear intensity mapping and noise on
measurement bias and precision using the popular algorithms described
previously, specifically:

* linear binning,
* hierarchical k-means,
* GMM-MRF, and
* a trained U-net.

We first demonstrate the effects of MR intensity nonlinearities on the
analogical application of T1-weighted brain MR segmentation.  This evaluation is
strictly qualitative as the visual evidence and previous developmental history
is overwhelmingly indicative of the need for adequate algorithmic optimization
capabilities.  We use these qualitative results as a segue to quantifying the
effects of the choice of reference cohort on the clustering parameters for the
three histogram-based algorithms.  We then incorporate the CNN model in
exploring additional aspects of measurement variance based on simulating both MR
noise and intensity nonlinearities.  Finally, we investigate algorithmic
accuracy (i.e., bias) in the absence of ground-truth segmentations, by using a
clinical diagnostic prediction approach and a study for simultaneous truth and
performance level estimation (STAPLE) [@Warfield:2004aa].

A fair and accurate comparison between algorithms necessitates several considerations
which have been outlined previously [@Tustison:2013aa].  In designing the evaluation
study:

* All algorithms and evaluation scripts have been implemented using open-source tools
by the first author who is also responsible for the GMM-MRF ("Atropos" in ANTs) and
N4 algorithms.  The linear binning and k-means algorithms were easily recreated
using existing R tools.  Similarly, N4, GMM-MRF, and the trained CNN approach are
all available through ANTsR/ANTsRNet, ``ANTsR::n4BiasFieldCorrection``,
``ANTsRNet::functionalLungSegmentation``, and ``ANTsRNet::elBicho``, respectively.[^2]
* Default parameters vary slightly from the original implementations.  For example,
in [@Kirby:2012aa], five clusters


[^2]:  Python versions are also available through ANTsPy/ANTsPyNet.

## Image cohorts

A retrospective dataset was collected consisting of young healthy ($n=5$),
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

* ``addNoiseToImage`` [^3] and
* ``histogramWarpImageIntensities`` [^4]

[^3]: https://github.com/ANTsX/ANTsR/blob/master/R/addNoiseToImage.R

[^4]:
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


# Results

## T1-weighed brain segmentation analogy

As a preview of the


In Figure \ref{fig:BrainAnalogy}

Although the reference image set has been intensity normalized to $[0, 1]$ with
truncated image intensities (quantiles = $[0, 0.99]$), it is apparent that
the major features of the respective image histograms (specifically, the three
peaks which correspond to the cerebrospinal fluid (CSF), gray matter (GM), and
white matter (WM)) do not line up in this globally aligned space.  Attempting to
create a "reference" histogram from misaligned data is not without controversy.
This can be seen in the results shown in the bottom where the linear binning
analog drastically overstimates the amount of gray matter and simultaneously
underestimates the amount of gray matter.  The k-means approach, using precisely
the same center clusters as determined via the reference histogram, yields a
much better segmentation as it is optimizing the piecewise affine transform over
histogram features.  However, the hard threshold values result in labelings
susceptible to noise in contrast to the GMM-MRF segmentation results.

\begin{figure}[!h]
  \centering
  \includegraphics[width=0.95\linewidth]{Figures/BrainAnalogy.pdf}
  \caption{T1-weighted three-tissue brain segmentation analogy. Placing the
  three segmentation algorithms (i.e., linear binning, k-means, and GMM-MRF) in
  the context of brain tissue segmentation provides an alternative perspective
  for comparison.  In the style of linear binning, we randomly select an image
  reference set using structurally normal individuals which is then used to
  create a reference histogram.  (Bottom) For a subject to be processed, the
  resulting hard threshold values yield the linear binning segmentation solution
  as well as the initialization cluster values for both the k-means and GMM-MRF
  segmentations which are qualitatively different.}
  \label{fig:BrainAnalogy}
\end{figure}

## Effect of reference image set selection

\begin{figure}[htb]
  \centering
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.99\linewidth]{Figures/meanReferencePlot.pdf}
    \caption{Mean reference plot.}
  \end{subfigure}%
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.99\linewidth]{Figures/sdReferencePlot.pdf}
    \caption{Standard deviation reference plot.}
  \end{subfigure}
\caption{}
\label{fig:referenceSet}
\end{figure}

## Effect of MR nonlinear intensity warping and additive noise

Need to add a SSIM calculation for each simulated image along with
different histogram similarity measurements.  We can then rescale
all measurements for comparison and show how the SSIM calculation
has lower variance than the histograms.  THis shows that the
image-to-histogram transformation results in information which is
less robust than the original image.




\begin{figure}[htb]
  \centering
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.99\linewidth]{Figures/vdpSdOverall.pdf}
    \caption{Mean reference plot.}
  \end{subfigure}%
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.99\linewidth]{Figures/diceMeanOverall.pdf}
    \caption{Standard deviation reference plot.}
  \end{subfigure}
\caption{}
\label{fig:simulations}
\end{figure}



## Diagnostic prediction



# Discussion

We recognize that alternative deep learning strategies (hyperparameter
choice, training data selection, etc.) could provide comparable and even
superior performance to what was presented.  However, that is precisely
our point---deep learning, generally, presents a much better alternative
than histogram approaches as network training directly takes place in
the image (i.e., spatial) domain and not in a transformed space where
key information has been discarded.


\newpage

# References {-}