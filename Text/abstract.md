
# Abstract {-}

__Purpose:__  To evaluate the most common approaches for histogram-based
optimization of hyperpolarized gas lung imaging segmentation in comparison
with image-based optimization via a trained convolutional neural network (CNN).

__Methods:__  Four previously published histogram-based segmentation
algorithms (linear binning, hierarchical k-means, fuzzy spatial c-means, and a
Gaussian Mixture Model with a Markov Random Field prior) and a CNN were used to
segment two data sets, one public ($n=29$) and one retrospective collection
($n=51$) of hyperpolarized 129Xe gas lung images, transformed by common MRI
artefacts (nonlinear intensity variation and additive noise). The resulting
ventilation-based segmentations were compared in terms of measurement bias and
precision.

__Results:__ Although facilitating computational processing and providing
discriminating clinically relevant measures of interest, histogram-based
segmentation methods are less robust in the presence of common MRI artefacts
relative to the exemplar CNN.

__Conclusions:__ Direct optimization within the image domain using CNNs
leverages spatial information which mitigates problematic issues associated with
histogram-based approaches and suggests a preferred future research direction.
Further, the entire processing and evaluation framework, including the newly
reported deep learning functionality, are available as open-source through the
well-known Advanced Normalization Tools ecosystem.


<!--

Magnetic resonance imaging (MRI) using hyperpolarized gases has made possible the
novel visualization of airspaces in the human lung, which has advanced
research into the growth, development, and pathologies of the pulmonary system.
In conjunction with the innovations associated with image acquisition, multiple
image analysis strategies have been proposed and refined for the quantification
of such lung imaging with much research effort devoted to semantic segmentation,
or voxelwise classification, into clinically oriented categories based on
ventilation levels. Given the functional nature of these images and the
consequent sophistication of the segmentation task, many of these algorithmic
approaches reduce the complex spatial image information to intensity-only
considerations, which can be contextualized in terms of the intensity histogram.
Although facilitating computational processing, this simplifying transformation
results in the loss of important spatial cues for identifying salient image
features, such as ventilation defects (a well-studied correlate of lung
pathophysiology), as spatial objects.  In this work, we discuss the
interrelatedness of the most common approaches for histogram-based optimization
of hyperpolarized gas lung imaging segmentation and demonstrate how certain
assumptions lead to suboptimal performance, particularly in terms of measurement
precision. In contrast, we illustrate how a convolutional neural network is
optimized (i.e., trained) directly within the image domain to leverage spatial
information.  This image-based optimization mitigates the problematic issues
associated with histogram-based approaches and suggests a preferred future
research direction.  Importantly, we provide the entire processing and
evaluation framework, including the newly reported deep learning functionality,
as open-source through the well-known Advanced Normalization Tools ecosystem.

-->

\newpage

<!--
\textcolor{red}{Notes to self:}

* Calling CNN "el Bicho" until we can come up a different name.
* Jaime to edit Subsections 2.1?
* Possible co-authors:  Tally Altes, Kun Qing, John Mugler, Wilson Miller, James Gee, Mu He
* \sout{Need five more young healthy subjects.}
* Need to finalize experiments

    * Nonlinear experiments: Noise, MR intensity nonlinear mapping, Noise + Nonlinear mapping
    * one issue is "should we preprocess with N4?"  --- yes, it helps segmentation, and more than
      one group uses it.
-->

\newpage