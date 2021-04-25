
# Abstract {-}

__Purpose:__  \textcolor{blue}{To characterize the differences in algorithmic approaches
for segmentation of hyperpolarized gas lung images categorized
by optimization domain, specifically image-based versus histogram-based.}

<!--
To evaluate the most common approaches for histogram-based
optimization of hyperpolarized gas lung imaging segmentation in comparison
with image-based optimization via a trained convolutional neural network (CNN).
-->

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

\newpage


\newpage