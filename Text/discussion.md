
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
  although they does use a principled optimization criterion, this criterion is
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
incorporating as much prior information as possible to any solution method.
In fact, this is a fundamental implication of the  "No Free Lunch Theorem"
[@Wolpert:1997aa]---algorithmic performance hinges on available prior
information.

As illustrated in Figure \ref{fig:similarity}, measures based on the human
visual system seem to quantify what is understood intuitively that image domain
information is much more robust than histogram domain information in the
presence of image transformations, such as distortions.  This appears to also be
supported in our simulation experiments illustrated in Figure
\ref{fig:simulations} where the histogram-based algorithms, overall, performed
worse than El Bicho.  As a CNN, El Bicho optimizes the governing network weights
over image features as opposed to strictly relative intensities.  This work
should motivate additional exploration focusing on issues related to
algorithmic bias on a voxelwise scale which would require going beyond simple
globally-based assessment measures (such as the diagnostic prediction evaluation
detailed above using global volume proportions).  This would enable investigating
differentiating spatial patterns within the images as evidence of disease and/or
growth and correlations with non-imaging data using sophisticated voxel-scale
statistical techniques (e.g., symmetric multivariate linear reconstruction
[@Stone:2020aa]).

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


