
# Abstract {-}

Magnetic resonance imaging using hyperpolarized gases, notably He-3 and Xe-129,
has facilitated the novel visualization of airspaces, such as the human lung.
The advent and refinement of these imaging techniques have furthered research
avenues with respect to the growth, development, and pathologies of the
pulmonary system.  In conjunction with the improvements associated with image
acquisition, multiple image analysis strategies have been proposed and developed
for the quantification of hyperpolarized gas images with much research effort
devoted to semantic segmentation, or voxelwise classification, into
clinically-oriented categories based on ventilation levels. Given the functional
nature of these images and the consequent complexity of the segmentation task,
many of these algorithmic approaches reduce the complex spatial image intensity
information to intensity-only considerations, specifically those associated with
the intensity histogram. Although significantly simplifying computational
processing, this transformation results in the loss of important spatial cues
for identifying salient imaging features, such as ventilation defects, which
have been identified as correlating with lung pathophysiology.  In this work, we
demonstrate the interrelatedness of the most common approaches for
histogram-based, ventilation segmentation of hyperpolarized gas lung imaging for
driving voxelwise classification.  We evaluate the underlying assumptions
associated with each approach and show how these assumptions lead to suboptimal
performance.  We then illustrate how a convolutional neural network can be
constructed in a multi-scale, hierarchically feature-based (i.e., spatial)
manner which circumvents the problematic issues associated with existing
histogram-based approaches.  Importantly, we provide the entire evaluation
framework, including this newly reported deep learning functionality, as
open-source through the well-known Advanced Normalization Tools (ANTs) library.

\newpage


