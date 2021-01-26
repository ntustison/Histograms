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

Magnetic resonance imaging using hyperpolarized gases has facilitated the novel
visualization of airspaces, such as the human lung. The advent and refinement of
these imaging techniques have furthered research avenues with respect to the
growth, development, and pathologies of the pulmonary system.  In conjunction
with the improvements associated with image acquisition, multiple image analysis
strategies have been proposed and developed for the quantification of
hyperpolarized gas images with much research effort devoted to semantic
segmentation, or voxelwise classification, into clinically-oriented categories
based on functional ventilation levels. Given the functional nature of these
images and the consequent complexity of the segmentation task, many of these
algorithmic approaches reduce the complex spatial image intensity information to
intensity-only considerations, particularly those associated with the intensity
histogram. Although facilitating computational processing, this simplifying
transformation results in the loss of important spatial cues for identifying
salient imaging features, such as ventilation defects---an identified correlate
of lung pathophysiology.  In this work, we demonstrate the interrelatedness of
the most common approaches for intensity-only (e.g., histogram), ventilation
segmentation of hyperpolarized gas lung imaging for driving voxelwise
classification.  We evaluate the underlying assumptions associated with each
approach and show how these assumptions lead to suboptimal performance.  We then
illustrate how a convolutional neural network can be constructed in a
multi-scale, hierarchically feature-based (i.e., spatial) manner which
circumvents the problematic issues associated with existing intensity-only
approaches.  Importantly, we provide the entire evaluation framework, including
this newly reported deep learning functionality, as open-source through the
well-known Advanced Normalization Tools (ANTs) library.

\newpage



# Introduction {-}

## Early acquisition and development {-}

Early hyperpolarized gas pulmonary imaging research reported findings in
qualitative terms.

Descriptions:

* "$^{3}$He MRI depicts anatomical structures reliably" [@Bachert:1996aa]

* "hypointense areas" [@Kauczor:1996aa]

* "signal intensity inhomogeneities" [@Kauczor:1996aa]

* "wedge-shaped areas with less signal intensity" [@Kauczor:1996aa]

* "patchy or wedge-shaped defects" [@Kauczor:1997aa]

* "ventilation defects" [@Altes:2001aa]

* "defects were pleural-based, frequently wedge-shaped, and varied in size from tiny to segmental" [@Altes:2001aa]


## Historical overview of quantification {-}

Initial attempts at quantification of ventilation images were limited to ennumerating
the number of "ventilation defects" or estimating ventilation defect percentage
(as a percentage of total lung volume).  Often these measurements were acquired on a
slice-by-slice basis.

Prior to the popularization of deep learning in medical image analysis,
including in the field of hyperpolarized gas imaging [@Tustison:2019ac], widely
used semi-automated or automated segmentation techniques were primarily based on
intensity-only considerations.  In order of increasing sophistication, these
techniques can be categorized as follows:

* binary thresholding based on relative intensities [@Woodhouse:2005aa;@Shammi:2021aa],
* linear intensity standardization based on global rescaling of the intensity
  histogram to a reference distribution based on healthy controls,
  i.e., "linear binning" [@He:2016aa;@He:2020aa],
* nonlinear intensity standardization based on piecewise affine transformation
  of the intensity histogram using the K-means algorithm [@Kirby:2012aa], and
* Gaussian mixture modeling (GMM) with Markov random field (MRF) spatial
  modeling [@Tustison:2011aa].

The early semi-automated technique used to compare smokers and never-smokers in
[@Woodhouse:2005aa] uses manually drawn regions to determine the mean signal
intensity and the standard deviation of the noise to derive a threshold value of
three noise standard deviations below the mean intensity.  All voxels above that
threshold value were considered "ventilated" for the purposes of the study.
Related approaches, which continue to be used currently (e.g.,
[@Shammi:2021aa]), simply use a rescaled threshold value to binarize the
segmentation.  Similar to the histogram-only algorithms (i.e., linear binning
and k-means), these approaches do not take into account the various artefacts
associated with MRI such as the non-Gaussianity of the MR imaging noise
[@Gudbjartsson:1995aa;@Andersen:1996aa] and the intensity inhomogeneity field
[@Sled:1998aa] which prevent simple intensity thresholds from distinguishing
tissue types consistent with that of human experts.

To provide a more granular categorization of ventilation that tracks with
clinical qualitative assessment, an increase in the number of voxel classes have
been added to the various lung parcellation protocols beyond the binary
categories of "ventilated" and "non-ventilated."  Linear binning is a simplified
intensity standardization approach with six discrete intensity levels (or
clusters).  The six clusters are evenly spaced throughout the intensity range
based on the mean and standard deviation values determined from a cohort of
healthy controls.

Intensity rescaling for determination of segmentation clusters of lung images
can be thought of as a global affine 1-D transform of the intensity histogram to
a standardized 1-D reference histogram. Such a global transform does not account
for MR intensity nonlinearities that have been well-studied
[@Wendt:1994aa;@Nyul:1999aa;@Nyul:2000aa;@De-Nunzio:2015aa] and can cause
significant intensity variation even in the same tissue region of the same
subject.  As stated in [@Collewet:2004aa]:

> Intensities of MR images can vary, even in the same protocol and the same
> sample and using the same scanner. Indeed, they may depend on the acquisition
> conditions such as room temperature and hygrometry, calibration adjustment,
> slice location, B0 intensity, and the receiver gain value. The consequences of
> intensity variation are greater when different scanners are used.

As we demonstrate in subsequent sections, ignoring these nonlinearities can
have significant consequences in the well-studied (and somewhat analogous) area
of brain tissue segmentation in T1-weighted MRI (e.g.,
[@Zhang:2001aa;@Ashburner:2005aa;@Avants:2011aa]) and we demonstrate its effect
in hyperpolarized gas imaging quantification robustness.  In addition, it is not
a given that we have a sufficient understanding of what constitutes a "normal"
in the context of mean and standard MR intensity values and whether or not those
values can be combined in a linear fashion to constitute a reference standard.
Of more concrete concern, though, is that the requirement for a healthy cohort
for determination of algorithmic parameters introduces an (unnecessary) source
of measurement variance.

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
some groups [@Kirby:2012aa] of employing k-means as a clustering strategy
[@Hartigan:1979aa] to minimize the within-class variance of its intensities can
be viewed as an alternative optimization strategy for determining a nonlinear
mapping between histograms for a clinically-based MR intensity standardization.
Although manual k-means initialization is often used where representative voxels
are selected for each class by the operator, linear binning can be considered a
type of automated initialization.  However, k-means does constitute an
algorithmic approach with additional degrees of flexibility over linear binning
as it employs basic prior knowledge in the form of a generic clustering
desideratum for optimizing a type of MR intensity standardization[^1]

[^1]: The prior knowledge for histogram mapping is the general machine learning
heuristic of clustering samples based on the minimizing within-class distance
while simultaneously maximizing the between-class distance.  In the case of
k-means, this "distance" is the variance as optimizing based on the Euclidean
distance is NP-hard.

Histogram-based optimization is used in conjunction with spatial considerations
in the approach detailed in [@Tustison:2011aa].  Based on a well-developed
iterative approach originally used for NASA satellite image processing and
subsequently appropriated for brain tissue segmentation in T1-weighted MRI
[@Vannier:1985aa], a GMM is used to model the intensity clusters within the
histogram with class modulation in the form of probabilistic voxelwise label
considerations within image neighborhoods.  Initialization for this particular
application is in the form of k-means clustering which, itself, is initialized
automatically using evenly spaced cluster centers---similar to linear
binning without the reference distribution.  This has a number of advantages in
that it accommodates MR intensity nonlinearities, like k-means, but in contrast
to k-means and the other algorithms outlined, does not use hard intensity
thresholds for distinguishing class labels.  However, as we will demonstrate,
this algorithm is also flawed in that it implicitly assumes,
incorrectly, that meaningful structure is found, and can be characterized,
within the associated image histogram in order to optimize class labeling.

Finally, we point out that N4 bias correction is used in many of these
algorithms which is also histogram-based.

It should be noted that we are not claiming that these algorithms are erroneous.
Much of the relevant research has been limited to quantifying differences with
respect to ventilation vs. non-ventilation in various clinical categories and
these algorithms have certainly demonstrated the capacity for advancing such
research.  However, as acquistion and analyses methodologies improve, so should
the level of sophistication and performance of the measurement tools.

*In assessing these algorithms, it is important to note that human expertise
leverages more than relative intensity values to identify salient, clinically
relevant features in images.*








# Methods {-}


# Results {-}




# Discussion {-}


\newpage

# References {-}