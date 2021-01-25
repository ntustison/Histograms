
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
  i.e., "linear binning" [@He:2016aa,He:2020aa],
* non-linear intensity standardization based on piecewise linear transformation
  of the intensity histogram using the K-means algorithm [@Kirby:2012aa], and
* Gaussian mixture modeling (GMM) with spatial constraints using Markov random
  field (MRF) modeling [@Tustison:2011aa].

The early semi-automated technique used to compare smokers and never-smokers in
[@Woodhouse:2005aa] uses manually drawn regions to determine the mean signal
intensity as well as the standard deviation of the noise to derive a threshold
value of three noise standard deviations below the mean intensity.  All voxels
above that threshold value were considered "ventilated" for the purposes of the
study.  Similar to the histogram-only algorithms (i.e., linear binning and
k-means), this approach does not take into account the various artefacts associated
with MRI such as the non-Gaussianity of the imaging noise [@] and the intensity
inhomogeneity field [@].

It is vitally important that it is understood that we are not claiming that
these algorithms are erroneous.  Much of the relevant research has been limited
to quantifying differences with respect to ventilation vs. non-ventilation in
various clinical categories and these algorithms have certainly demonstrated the
capacity for advancing such research.  However, as acquistion and analyses
methodologies improve, so should the level of sophistication and performance
of our measurement tools.








