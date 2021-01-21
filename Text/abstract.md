
# Abstract {-}

Magnetic resonance imaging using hyperpolarized gases, most notably He-3 and
Xe-129, has made possible the novel visualization of airspaces, such as the
human lung. The advent and refinement of these imaging capabilities has
furthered the development of various avenues of research into the growth,
development, and disease associated with the pulmonary system.  In conjunction
with the improvements associated with image acquisition, multiple image analysis
approaches have been proposed and developed for quantifying such images with
much research effort devoted to semantic segmentation, or voxelwise
classification, into clinically-oriented categories based on ventilation levels.
Given the functional nature of these images and the consequent complexity of the
segmentation task, many of these algorithmic approaches reduce the complex
spatial image intensity information to intensity-only considerations,
specifically those associated with the intensity histogram. This results in the
loss of important spatial cues for identifying unique imaging features,
specifically ventilation defects (as spatial objects) which have been identified
as correlating with lung pathophysiology.  In this work, we demonstrate the
interrelatedness of the most common approaches for ventilation-based
segmentation of hyperpolarized gas lung imaging which rely on the intensity
histogram for driving voxelwise classification.  We also illustrate the
underlying assumptions associated with each approach and how these assumptions
lead to suboptimal performance.  We then illustrate how a deep learning-based
solution is constructed in a multi-scale, hierarchically feature-based (i.e.,
spatial) manner which circumvents the problematic issues associated with
existing histogram-based approaches.  Importantly, we provide this newly reported
deep learning functionality and evaluation framework as open-source through the
well-known Advanced Normalization Tools (ANTs) library.

\newpage


