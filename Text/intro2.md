
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
  [@Woodhouse:2005aa;@Thomen:2015aa;@Shammi:2021aa],
* linear intensity standardization based on a global rescaling of the intensity
  histogram to a reference distribution based on healthy controls, i.e., "linear
  binning" [@He:2016aa;@He:2020aa],
* nonlinear intensity standardization based on piecewise affine transformation
  of the intensity histogram using a customized hierarchical
  [@Kirby:2012aa;@Kirby:2012ab] or adaptive [@Zha:2016aa] k-means algorithm,
* nonlinear intensity standardization using fuzzy c-means [@Ray:2003aa] with spatial
  considerations based on local voxel neighborhoods [@Hughes:2018aa], and
* Gaussian mixture modeling (GMM) of the intensity histogram with Markov random
  field (MRF) spatial prior modeling [@Tustison:2011aa].

Given the functional nature of hyperpolarized gas images and the consequent
sophistication of the segmentation task, these algorithmic approaches reduce the complex
spatial image information to primarily intensity-only optimization considerations,
which can be contextualized in terms of the intensity histogram. Although facilitating
computational processing, this simplifying transformation results in the loss of
important spatial cues for identifying salient image features, such as
ventilation defects (a well-studied correlate of lung pathophysiology), as
spatial objects.

Each of these algorithms can be viewed as a type of MR intensity standardization
[@Nyul:1999aa] with varying degrees of flexibility and algorithmic sophistication.
Intensity-only approaches (e.g., linear binning and k-means), due to hard threshold
values, are unable to account for various MRI artefacts such as noise
[@Gudbjartsson:1995aa;@Andersen:1996aa] and the intensity inhomogeneity field
[@Sled:1998aa] (a well-known source of MR nonlinear intensity) which prevent hard
threshold values from distinguishing tissue types precisely consistent with that
of human experts.   Such MR intensity nonlinearities have been well-studied
[@Wendt:1994aa;@Nyul:1999aa;@Nyul:2000aa;@Collewet:2004aa;@De-Nunzio:2015aa] and
are known to cause significant intensity variation even in the same region of
the same subject.  As stated in [@Collewet:2004aa]:

> Intensities of MR images can vary, even in the same protocol and the same
> sample and using the same scanner. Indeed, they may depend on the acquisition
> conditions such as room temperature and hygrometry, calibration adjustment,
> slice location, B0 intensity, and the receiver gain value. The consequences of
> intensity variation are greater when different scanners are used.

Ignoring these nonlinearities is known to have significant consequences in
the well-studied (and somewhat analogous)
area of brain tissue segmentation in T1-weighted MRI (e.g.,
[@Zhang:2001aa;@Ashburner:2005aa;@Avants:2011aa]).

Previous attempts at histogram standardization [@Nyul:1999aa;@Nyul:2000aa] in
light of MR intensity nonlinearities have relied on 1-D piecewise affine
mappings between corresponding structural features found within the histograms
themselves (e.g., peaks and valleys).  For example, structural MRI, such as
T1-weighted neuroimaging, utilizes the well-known relative intensities of major
tissue types (i.e., cerebrospinal fluid (CSF), gray matter (GM), and white
matter (WM)), which characteristically correspond to visible histogram peaks, as
landmarks to determine the nonlinear intensity mapping between histograms.
However, in hyperpolarized gas imaging of the lung, no such characteristic
structural features exist, generally speaking, between histograms.
Additionally, because of the functional nature of these images, the segmentation
clusters that correspond to features of interest are not necessarily guaranteed
to exist (e.g., ventilation defects in the case of healthy normal subjects with
no lung pathology).

Additional sophistication incorporating spatial considerations is found in the
fuzzy spatial c-means [@Chuang:2006aa] and Gaussian mixture-modeling (GMM) with
a Markov random field (MRF) prior algorithms.  The former, similar to k-means,
optimizes over the within-class sample variance but includes a per-sample membership
weighting [@Bezdek:1981aa] whereas the latter is optimized via the
expectation-maximization (EM) algorithm [@Dempster:1977aa].  These algorithms
have the advantage, in contrast to histogram-only algorithms, \textcolor{blue}{that} the
intensity thresholds between class labels are softened which demonstrates some
relative robustness to certain imaging distortions, such as noise.  However, as
we will demonstrate, all these algorithms are flawed in the inherent assumption
that meaningful structure is found, and can be adequately characterized, within
the associated
image histogram in order to optimize a multi-class labeling.

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
  histogram structure where the amount of random 1-D deformation increases with each
  row.  By simulating these
  types of intensity changes, we can visualize the effects on the underlying
  intensity histograms and investigate the effects on salient outcome measures.
  Here we simulate intensity mappings which, although relatively small, can have
  a significant effect on the histogram structure.}
  \label{fig:motivation}
\end{figure}

Investigating the assumptions outlined above, particularly those associated with
the nonlinear intensity mappings due to both the MR acquisition and
inhomogeneity mitigation preprocessing, we became concerned by the
susceptibility of the histogram structure to such variations and the potential
effects on current clinical measures of interest derived from these algorithms
(e.g., ventilation defect percentage).  Specifically, we noticed that histogram-based intensity
perturbations can produce virtually little, if any, changes in the features of
the image despite a relatively significant change in the histogram structure.
Such effects imply that MR artefacts could profoundly impact histogram-based
algorithmic performance. Figure \ref{fig:motivation} provides a sample
visualization representing some of the structural changes that we observed when
simulating these nonlinear mappings.  It is important to notice that even
relatively small alterations in the image intensities can have significant
effects on the histogram even though a visual assessment of the image can remain
largely unchanged.

\begin{figure}[!htb] \centering
  \includegraphics[width=0.95\textwidth]{Figures/similarityMultisite.pdf}
  \caption{Multi-site:  (left) University of Virginia (UVa) and (right)
  Harvard Dataverse 129Xe data.
  Image-based SSIM vs. histogram-based Pearson's correlation differences
  under distortions induced by the common MR artefacts of noise and intensity nonlinearities.  For the
  nonlinearity-only simulations, the images maintain their structural integrity
  as the SSIM values remain close to 1.  This is in contrast to the
  corresponding range in histogram similarity which is much larger. The effects with simulated Gaussian noise are similar where the range in histogram differences with simulated noise is much greater than the range in SSIM. Both sets of observations are evidence of the lack of robustness to distortions in the histogram domain in comparison with the original image domain. }
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
[@LeCun:2015aa], particularly convolutional neural networks (CNN).
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
gas images *as spatial samplings of real-world objects*, as opposed to lossy
representations of such objects.  In the spirit of open science, we have made
the entire evaluation framework, including our novel contributions, available
within the Advanced Normalization Tools software ecosystem (ANTsX)
[@Tustison:2020aa].




