
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
  field (MRF) spatial prior modeling [@Tustison:2011aa]

where each of these algorithms has been contextualized in terms of the intensity
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
types consistent with that of human experts.  In addition, to provide
a more granular categorization of ventilation for greater compatibility with
clinical qualitative assessment, many current techniques have increased the
number of voxel classes (i.e., clusters) beyond the binary categories of
"ventilated" and "non-ventilated."

Linear binning is a simplified type of MR intensity standardization
[@Nyul:1999aa] in which a set of healthy controls, all intensity normalized to
[0, 1], is used to calculate the cluster threshold values, based on an
aggregated estimate of the parameters of a single Gaussian fit. A subject image
to be segmented is then rescaled to this reference histogram (i.e., a global
affine 1-D transform). This mapping results in alignment of the cluster
boundaries such that corresponding labels are assumed to have the same clinical
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
a linear fashion to constitute a single reference standard. Of more concrete
concern, though, is that the requirement for a healthy cohort for determination
of algorithmic parameters introduces a non-negligible source of measurement
variance, as we will also demonstrate.

Previous attempts at histogram standardization [@Nyul:1999aa;@Nyul:2000aa] in
light of these MR intensity nonlinearities have relied on 1-D piecewise affine
mappings between corresponding structural features found within the histograms
themselves (i.e., peaks and valleys).  For example, structural MRI, such as
T1-weighted neuroimaging, utilizes the well-known relative intensities of major
tissues types (i.e., cerebrospinal fluid, gray matter, and white matter), which
characteristically correspond to visible histogram peaks, as landmarks to
determine the nonlinear intensity mapping between images. However, in
hyperpolarized gas imaging of the lung, no such characteristic structural
features exist, generally speaking, between histograms.  This is most likely due
to the primarily functional utility (vs. anatomical) nature of these images. The
approach used by some groups [@Cooley:2010aa;@Kirby:2012aa] of employing some
variant of the well-known k-means algorithm as a clustering strategy
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
k-means, this "distance" is the intensity variance.

Histogram-based optimization is used in conjunction with spatial considerations
in the approach detailed in [@Tustison:2011aa].  Based on a well-established
iterative approach originally used for NASA satellite image processing and
subsequently appropriated for brain tissue segmentation in T1-weighted MRI
[@Vannier:1985aa], a GMM is used to model the intensity clusters of the
histogram with class modulation in the form of probabilistic voxelwise label
considerations, i.e., MRF modeling,  within image neighborhoods [@Besag:1986aa]
using the expectation-maximization (EM) algorithm [@Dempster:1977aa].
Initialization for this particular application is in the form of k-means
clustering which, itself, is initialized automatically using evenly spaced
cluster centers.  This has the advantage, in contrast to k-means and the other
algorithms outlined, that it does not use hard intensity thresholds for
distinguishing class labels which does demonstrates robustness to certain
imaging distortions, such as noise.  However, as we will demonstrate, this
algorithm is also flawed in that it implicitly assumes, incorrectly, that
meaningful structure is found, and can be adequately characterized, within the
associated image histogram in order to optimize a multi-class labeling
which also leads to susceptibility to MR nonlinear intensity variation.

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
significant effects on the histogram even though a visual, clinically-based
assessment of the image can remain largely unchanged.

\begin{figure}[!htb] \centering
  \includegraphics[width=0.95\textwidth]{Figures/similarity.pdf}
  \caption{Image-based SSIM vs. histogram-based Pearson's correlation differences
  under distortions induced by the common MR artefacts of noise and intensity nonlinearities.  For the
  nonlinearity-only simulations, the images maintain their structural integrity
  as the SSIM values remain close to 1.  This is in contrast to the
  corresponding range in histogram similarity is much larger.
  Although not as large, the range in histogram differences with simulated noise
  is much greater than the range in SSIM.  Both point to the potential lack of
  robustness in the histogram domain vs. the image domain in relation to
  simulated MR artefacts.}
  \label{fig:similarity}
\end{figure}

To briefly explore these effects further for the purposes of motivating
additional experimentation, we provide a summary illustration from a set of
image simulations in Figure \ref{fig:similarity} which are detailed later in
this work and used for algorithmic comparison.  Simulated MR artefacts
were applied to each image which included
both noise and nonlinear intensity mappings (and their combination) which made
for a total simulated cohort of
~50 images ($\times 10$ simulations per image $\times 3$ types of artefact simulations).   Prior to any algorithmic
comparative analysis, we quantified the difference of each simulated image with
the corresponding original image using the structural similarity index measurement (SSIM)
[@Wang:2004aa]. SSIM is a highly-cited measure which quantifies structural
differences between a reference and distorted (i.e., transformed) image based on
known properties of the human visual system.  SSIM has a range $[-1,1]$ where 0
indicates no structural similarity and 1 indicates perfect structural
similarity. We also generated the histograms corresponding to these images.
Although several histogram similarity measures exist, we chose Pearson's
correlation primarily as it resides in the same [min, max] range as SSIM with
analogous significance. In addition to the fact that the image-to-histogram
transformation discards important spatial information, from Figure
\ref{fig:similarity}, it should be apparent that this transformation also
results in greater variance in the resulting information under common MR imaging
artefacts, according to these measures.  Thus, prior to any algorithmic
considerations, these observations point to the fact that optimizing in the domain
of the histogram will be generally less robust than optimizing directly in the image
domain.

Ultimately, we are not claiming that these algorithms are erroneous, per se.
Much of the relevant research has been limited to quantifying differences with
respect to ventilation versus non-ventilation in various clinical categories and
these algorithms have certainly demonstrated the capacity for advancing such
research.  However, the aforementioned issues influence quantitation in terms of
core scientific measurement principles such as precision (e.g., reproducibility
and repeatability [@Svenningsen:2020aa]) and bias which become increasingly
significant with multi-site [@Couch:2019aa] and large-scale studies.  In addition, generally
speaking, refinements in measuring capabilities correlate with scientific
advancement so as acquisition and analysis methodologies improve, so should the
level of sophistication and performance of the measurement tools.

In assessing these segmentation algorithms for hyperpolarized gas imaging, it is
important to note that human expertise leverages more than relative intensity
values to identify salient, clinically relevant features in images---something
more akin to the complex neural network structure versus the 1-D intensity
histogram.  The increased popularity of deep-layered neural networks as
[@LeCun:2015aa], particularly convolutional neural networks (CNN), is due to
their outstanding performance in certain computational tasks, including
classification and semantic segmentation in medical imaging [@Shen:2017aa].
Their potential for leveraging spatial information from images surpasses the
perceptual capabilities of previous approaches and even rivals that of human
raters [@Zhang:2018aa].  We introduced a deep learning approach in
[@Tustison:2019ac] and further expand on that work for comparison with existing
approaches in this work.  In the spirit of open science, we have made the entire
evaluation framework, including our novel contributions, available within our
Advanced Normalization Tools software ecosystem (ANTsX) [@Tustison:2020aa].







