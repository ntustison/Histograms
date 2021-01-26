
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

* binary thresholding based on relative intensities [@Woodhouse:2005aa],
* linear intensity standardization based on global rescaling of the intensity
  histogram to a reference distribution based on healthy controls,
  i.e., "linear binning" [@He:2016aa;@He:2020aa],
* non-linear intensity standardization based on piecewise affine transformation
  of the intensity histogram using the K-means algorithm [@Kirby:2012aa], and
* Gaussian mixture modeling (GMM) with spatial constraints using Markov random
  field (MRF) modeling [@Tustison:2011aa].

The early semi-automated technique used to compare smokers and never-smokers in
[@Woodhouse:2005aa] uses manually drawn regions to determine the mean signal
intensity as well as the standard deviation of the noise to derive a threshold
value of three noise standard deviations below the mean intensity.  All voxels
above that threshold value were considered "ventilated" for the purposes of the
study.  Similar to the histogram-only algorithms (i.e., linear binning and
k-means), this approach does not take into account the various artefacts
associated with MRI such as the non-Gaussianity of the MR imaging noise
[@Gudbjartsson:1995aa;@Andersen:1996aa] and the intensity inhomogeneity field
[@Sled:1998aa].

To provide a more granular categorization of ventilation that tracks with
clinical qualitative assessment, an increase in the number of voxel classes have
been added to the various lung parcellation protocols beyond the binary
categories of ventilated and non-ventilated.  Linear binning is a simplified
intensity standardization approach with six discrete intensity levels (or
clusters).  The six clusters are evenly spaced throughout the intensity range
based on the mean and standard deviation values determined from a cohort of
healthy controls all rescaled to $[0,1]$.  Such rescaling for determination of
segmentation clusters of lung images in a particular study can be thought of as
a global affine 1-D transform of the intensity histogram. Note that such a
global transform does not account for MR intensity non-linearities that have
been well-studied [@Wendt:1994aa;@Nyul:1999aa;@Nyul:2000aa;@De-Nunzio:2015aa]
and can cause significant intensity variation even in the same subject due to
a variety of conditions.  As stated in [@Collewet:2004aa]:

> Intensities of MR images can vary, even in the same protocol and the same
> sample and using the same scanner. Indeed, they may depend on the acquisition
> conditions such as room temperature and hygrometry, calibration adjustment,
> slice location, B0 intensity, and the receiver gain value. The consequences of
> intensity variation are greater when different scanners are used.

As we demonstrate in subsequent sections, ignoring these non-linearities can
have significant consequences in the well-studied (and somewhat analogous) area
of brain tissue segmentation in T1-weighted MRI (e.g.,
[@Zhang:2001aa;@Ashburner:2005aa;@Avants:2011aa]).



Finally, we point out that N4 bias correction is used in many of these algorithms
which is also histogram-based.

It should be noted that we are not claiming that these algorithms are erroneous.
Much of the relevant research has been limited to quantifying differences with
respect to ventilation vs. non-ventilation in various clinical categories and
these algorithms have certainly demonstrated the capacity for advancing such
research.  However, as acquistion and analyses methodologies improve, so should
the level of sophistication and performance of the measurement tools.








