
# Abstract {-}

__Purpose:__  \textcolor{blue}{To characterize the differences between
histogram-based and image-based algorithms for segmentation of
hyperpolarized gas lung images.}

<!--
To evaluate the most common approaches for histogram-based
optimization of hyperpolarized gas lung imaging segmentation in comparison
with image-based optimization via a trained convolutional neural network (CNN).
-->

__Methods:__  Four previously published histogram-based segmentation algorithms
(i.e., linear binning, hierarchical k-means, fuzzy spatial c-means, and a
Gaussian Mixture Model with a Markov Random Field prior) and an
\textcolor{blue}{image-based convolutional neural network} were used to segment
two simulated data sets derived from a public ($n=29$) and a retrospective
collection ($n=51$) of hyperpolarized 129Xe gas lung images transformed by
common MRI artefacts \textcolor{blue}{
(noise and nonlinear intensity distortion). The resulting
ventilation-based segmentations were used to
assess algorithmic performance and characterize optimization
domain differences} in terms of measurement bias and precision.

__Results:__ Although facilitating computational processing and providing
discriminating clinically relevant measures of interest, histogram-based
segmentation methods  \textcolor{blue}{discard important contextual, spatial
information and are consequently less robust, in terms of measurement
precision, in the presence of common MRI
artefacts relative to the image-based convolutional neural network}.

__Conclusions:__ Direct optimization within the image domain using convolutional
neural networks leverages spatial information which mitigates problematic issues
associated with histogram-based approaches and suggests a preferred future research
direction. Further, the entire processing and evaluation framework, including the newly
reported deep learning functionality, is available as open-source through the
well-known Advanced Normalization Tools ecosystem.

\newpage


\newpage