
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

Initial attempts at quantification of ventilation images were limited to
ennumerating the number of "ventilation defects" or estimating ventilation
defect percentage (as a percentage of total lung volume).  Often these
measurements were acquired on a slice-by-slice basis.

Prior to the popularization of deep learning in medical image analysis,
including in the field of hyperpolarized gas imaging [@Tustison:2019ac], widely
used semi-automated or automated segmentation techniques were primarily based on
intensity-only considerations.  In order of increasing sophistication, these
techniques can be categorized as follows:

* binary thresholding based on relative intensities
  [@Woodhouse:2005aa;@Shammi:2021aa],
* linear intensity standardization based on global rescaling of the intensity
  histogram to a reference distribution based on healthy controls, i.e., "linear
  binning" [@He:2016aa;@He:2020aa],
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

As we demonstrate in subsequent sections, ignoring these nonlinearities can have
significant consequences in the well-studied (and somewhat analogous) area of
brain tissue segmentation in T1-weighted MRI (e.g.,
[@Zhang:2001aa;@Ashburner:2005aa;@Avants:2011aa]) and we demonstrate its effect
in hyperpolarized gas imaging quantification robustness in conunction with noise
considerations.  In addition, it is not a given that we have a sufficient
understanding of what constitutes a "normal" in the context of mean and standard
MR intensity values and whether or not those values can be combined in a linear
fashion to constitute a reference standard. Of more concrete concern, though, is
that the requirement for a healthy cohort for determination of algorithmic
parameters introduces an (unnecessary) source of measurement variance.

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
in the approach detailed in [@Tustison:2011aa].  Based on a well-established
iterative approach originally used for NASA satellite image processing and
subsequently appropriated for brain tissue segmentation in T1-weighted MRI
[@Vannier:1985aa], a GMM is used to model the intensity clusters of the
histogram with class modulation in the form of probabilistic voxelwise label
considerations within image neighborhoods using the expectation-maximization
algorithm.  Initialization for this particular application is in the form of
k-means clustering which, itself, is initialized automatically using evenly
spaced cluster centers---similar to linear binning without the reference
distribution.  This has a number of advantages in that it accommodates MR
intensity nonlinearities, like k-means, but in contrast to k-means and the other
algorithms outlined, does not use hard intensity thresholds for distinguishing
class labels.  However, as we will demonstrate, this algorithm is also flawed in
that it implicitly assumes, incorrectly, that meaningful structure is found, and
can be adequately characterized, within the associated image histogram in order
to optimize class labeling.

Additionally, many of these segmentation algorithms use the N4 bias correction
preprocessing algorithm [@Tustison:2010ac] to mitigate MR intensity
inhomogeneity artefacts which is an extension of the popular nonparametric
nonuniform intensity normalization (N3) algorithm [@Sled:1998aa]. Interestingly,
N3/N4 also iteratively optimizes towards a final solution using information from
both the histogram and image domains.  Based on the intuition that the bias
field acts as a smoothing convolution operation on the original image intensity
histogram, N3/N4 optimizes a nonlinear intensity mapping, based on
histogram deconvolution, which smoothly varies across the image.  This nonlinear
mapping sharpens the histogram peaks which presumably correspond to tissue
types. While such assumptions are appropriate for the domain in which N3/N4 was
developed (i.e., T1-weighted brain tissue segmentation) and while it is assumed
that the enforcement of low-frequency modulation of the intensity mapping
prevents new image features from being generated, it is not clear what effects
N4 parameter choices have on the final segmentation solution, particularly for
those algorithms that are limited to intensity-only considerations.

## Motivation for current study

All these methods can be described in terms of the intensity histogram. Investigating the assumptions
outlined above, particularly those associated with the nonlinear intensity
mappings due to both the MR acquisition and inhomogeneity mitigation
preprocessing, we became concerned by the susceptibility of the histogram
structure to such variations and the potential effects on current clinical
measures of interest (e.g., ventilation defect percentage) derived from these
algorithms.  Figure \ref{fig:motivation} provides a visualization representing
some of the structural changes that we observed when simulating these nonlinear
mappings.  It is important to notice that even relatively small alterations
in the image intensities can have significant effects on the histogram even
though a visual, clinically-based assessment of the image can be unchanged.

\begin{figure}[!h]
  \centering
  \includegraphics[width=0.9\linewidth]{Figures/motivation.pdf}
    \caption{Illustration of the effect of MR nonlinear intensity
    warping on the histogram structure.  We simulate these mappings by
    perturbing specified points along the bins of the histograms by a
    Gaussian random variable of 0 mean and specified max standard deviation
    (``Max SD'').  By simulating these types of intensity changes,
    we can visualize the effects on the underlying intensity histograms and
    investigate the effects on salient outcome measures.  Here we simulate
    intensity mappings which, although relatively small, can have a significant effect on
    the histogram structure.}
  \label{fig:motivation}
\end{figure}

Ultimately, we are not claiming that these algorithms are erroneous per se. Much
of the relevant research has been limited to quantifying differences with
respect to ventilation versus non-ventilation in various clinical categories and
these algorithms have certainly demonstrated the capacity for advancing such
research.  However, these issues influence quantitation in terms of core
scientific measurement principles such as precision (e.g., repeatability) and
bias.  In addition, as acquistion and analysis methodologies improve, so should
the level of sophistication and performance of the measurement tools. In
evaluating and assessing these algorithms, it is important to note that human
expertise leverages more than relative intensity values to identify salient,
clinically relevant features in images. Fortunately, modern algorithmic
paradigms, specifically deep learning, have the potential for leveraging spatial
information from the images that surpasses the perceptual capabilities of
previous approaches and even rivals that of human raters [@@Zhang:2018aa].  We
introduced such an approach in [@Tustison:2019ac] and further expand on that
work for comparison with existing approaches in this work.  In the spirit of
open science, we have made the entire evaluation framework, including our novel
contributions, available within our ANTsR and ANTsPy libraries for both R and
Python users, respectively.







