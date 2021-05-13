
# Discussion

\textcolor{blue}{
Over the past decade, multiple algorithms have been proposed for the
segmentation of hyperpolarized gas images into clinically based functional
categories.  These algorithms are optimized using the histogram information
primarily (with many using it exclusively) much to the detriment of
algorithmic robustness and segmentation quality. This is due to the simple fact
that these approaches discard, or do not optimally leverage, a vital piece of
information essential for accurate quantitative image interpretation---the
spatial relationships between voxel intensities.  While simplifying the
underlying complexity of the segmentation problem, these algorithms are
deficient in leveraging the general modelling principle of incorporating all
available prior information to any solution method. In fact, this is a
fundamental implication of the "No Free Lunch Theorem"}
[@Wolpert:1997aa]\textcolor{blue}{---algorithmic performance hinges on available prior
information.}

\textcolor{blue}{
As illustrated in Figure \ref{fig:similarity}, measures based on the human
visual system seem to quantify what is understood intuitively; that image-based
information is much more robust than its corresponding histogram-based
information in the presence of image transformations, such as common MR
artefacts.  This observation is not intended to imply that the histogram-based
approaches are useless in performing research.  In fact, ventilation defect
percentage is perhaps the most widely used clinical measurement reported in the
literature and it is easily quantified from the image histogram.  Thus, even
relatively simple histogram-only segmentation algorithms will provide some
utility which was observed in the measurement bias experiments employing a
variant of ventilation defect percentage to predict diagnostic accuracy.
However, similar to the lossy relationship between the image and its
corresponding histogram, such volumetric-based measures are lossy distillations
of the segmentation information and might obscure important algorithmic
characteristics and relative differences as well as discard potentially useful
spatial information which is why additional experimentation explored measurement
precision in the presence of MR artefacts.}

\textcolor{blue}{
Common MR artefacts of noise and intensity nonlinearities can produce
quantifiable differences in the segmentation results and the degree of deviation
(i.e., lack of measurement precision) largely corresponds to the algorithmic
choice of optimization domain, i.e., image-based vs. histogram-based, with those
algorithms leveraging the former providing improved segmentation repeatability.
Notably, El Bicho generally yields the best segmentation overlap measures over
the specified clusters and MR artefacts most likely due to optimization of the
governing network weights over hierarchical image features found in the training
set as opposed to strictly relative intensities and/or more simplistic
neighborhood intensity information.  In addition, this network demonstrates site
acquisition generalizability as these performance gains are also seen in the
Harvard Dataverse dataset.}

\textcolor{blue}{In addition to motivating a renewed assessment of current
algorithmic approaches to pulmonary hyperpolarized gas segmentation, there other
avenues for further research.   El Bicho was developed in parallel with the
writing of this manuscript merely to showcase the incredible potential that deep
learning can have in the field of hyperpolarized gas imaging (as well as to
update our earlier work }[@Tustison:2019ac]\textcolor{blue}{). We certainly
recognize and expect that alternative deep learning strategies (e.g.,
hyperparameter choice, training data selection, data augmentation, etc.) would
provide comparable and even superior performance to what was presented with El
Bicho. However, that is precisely our motivation for presenting this work—deep
learning, generally, presents a much better alternative than histogram
approaches as network training directly takes place in the image (i.e., spatial)
domain and not in a transformed space where key information has been discarded.
Just as important, deep learning provides other avenues for research exploration
and development. For example, given the relatively lower resolution of the
acquisition image, exploration of the effects of deep learning-based
super-resolution might prove worthy of application-specific investigation}
[@Li:2020aa]\textcolor{blue}{. Also, with the same network software libraries,
high-performing classification networks can be constructed and trained which
might yield novel insights regarding image-based characterization of disease.
One additional modification that we did not explore in this work, but is
extremely important, is the confound caused by multi-site data which has yet to
be explored in-depth. With neural networks, such confounds can be handled as
part of the training process or as an explicit network modification. Either
would be important to consider for future work.}

\textcolor{blue}{
Admittedly, this work was limited in its exploration of MR artefacts.  Noise
variation was limited to a zero-mean Gaussian distribution and nonlinear
intensity variation was explored strictly through smoothly varying histogram
deformation.   Inclusion of other noise models (e.g., shot, salt-and-pepper)
might further characterize algorithmic differences and provide additional
realistic data augmentation strategies.  Specific to nonlinear intensity
variation, a recent addition to the ANTsX ecosystem allows for the possible
simulation of bias fields which would also expand data augmentation and,
significantly, in the spirit of algorithmic parsimony, could potentially remove
the dependency of N4 bias correction as an unnecessary preprocessing step.}

\textcolor{blue}{
Finally, although ventilation defect percentage has proven to be a compelling quantity
for clinical studies, the results from the diagnostic prediction evaluation and
the previous discussion implies that this popular measure does not fully
leverage the spatial information of the segmentation information from any of
these algorithms.  Perhaps the results of this work, in addition to pointing to
the need for rethinking algorithm innovation direction, also point to possibly
investigating differentiating spatial patterns within the images as evidence of
disease and/or growth and correlations with non-imaging data using sophisticated
voxel-scale statistical techniques which intrinsically leverage spatial information (e.g.,
similarity-driven multivariate linear reconstruction} [@Avants:2021un;@Stone:2020aa]\textcolor{blue}{).}



