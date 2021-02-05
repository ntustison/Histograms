


# Discussion

Imagine, dear Reader, the reality of the future clinical application of
functional lung imaging beyond mere research activity.  In fact, imagine
yourself being a patient on the receiving end of an imaging battery which
includes hyperpolarized gas imaging.  Now imagine that, upon receiving the
images for assessment, the radiologist declares "Yes, these are nice but I'd
rather work with the corresponding histograms."  If this strikes you as absurd,
then the point that we are trying to make should be clear.

We recognize that alternative deep learning strategies (hyperparameter
choice, training data selection, etc.) could provide comparable and even
superior performance to what was presented.  However, that is precisely
our point---deep learning, generally, presents a much better alternative
than histogram approaches as network training directly takes place in
the image (i.e., spatial) domain and not in a transformed space where
key information has been discarded.

As we mentioned previously, although susceptible to varyious levels of
bias and lack of precision, these algorithms are decent for what they've been
used for---global measurements, no more granular than spirometry, for
doing research (while providing pretty visuals for publications.)
However, if you want to do more sophisticated studies involving, for
example, the spatial manifestation and/or growth of disease aided
by advanced statistical techniques (such as similarity-driven multivariate
linear reconstruction, then one should move beyond these shitty algorithms


In addition to the fundamental issues of precision and bias, we also point
out that generally good modelling practice is to incorporate as much
prior information as possible.  Histogram-only algorithms throw out a
significant portion of that prior information.  This is a key consequence of
the "No Free Lunch Theorem" [@Wolpert:1997aa]

Instead of investing time in propping up shitty algorithms, we should be
donig things like looking at tailored network architectures/features and
data augmentation strategies.

So, in summary:

* In addition to completely discarding spatial information, linear binning is
  based on overly simplistic assumptions, especially given common MR artefacts.
  The additional requirement of a reference distribution, with its questionable
  assumption of Gaussianity, is also a potential source of output variance.

* Hierarchical k-means also ignores spatial information and, although it does
  use a principled optimization criterion, this criterion is not adequately
  tailored for hyperpolarized gas imaging and relatively more susceptible to
  various levels of noise than competing approaches.

* The GMM-MRF approach does employ spatial considerations in the form of Markov
  random fields but these are highly simplistic prior modeling of local voxel
  neighborhoods which do not capture the complexity of ventilation
  defects/heterogeneity appearance in the images.  Although the simplistic
  assumptions provide some robustness to noise, the highly variable histogram
  structure in the presence of MR nonlinearities causes significant variance in
  the resulting GMM fitting.