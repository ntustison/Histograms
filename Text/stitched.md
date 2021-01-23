---
title:
author:
address:
output:
  pdf_document:
    fig_caption: true
    latex_engine: xelatex
    keep_tex: yes
    number_sections: true
    # includes:
    #   after_body: authorContributions.md
  word_document:
    fig_caption: true
bibliography:
  - references.bib
csl: journal-of-magnetic-resonance-imaging.csl 
longtable: true
urlcolor: blue
header-includes:
  # - \usepackage[left]{lineno}
  # - \linenumbers
  - \usepackage{longtable}
  - \usepackage{graphicx}
  - \usepackage{booktabs}
  - \usepackage{listings}
  - \usepackage{textcomp}
  - \usepackage{xcolor}
  - \usepackage{multirow}
  - \usepackage{subcaption}
  - \definecolor{listcomment}{rgb}{0.0,0.5,0.0}
  - \definecolor{listkeyword}{rgb}{0.0,0.0,0.5}
  - \definecolor{listnumbers}{gray}{0.65}
  - \definecolor{listlightgray}{gray}{0.955}
  - \definecolor{listwhite}{gray}{1.0}
geometry: margin=1.0in
fontsize: 12pt
linestretch: 1.5
mainfont: Georgia
---


\pagenumbering{gobble}

\setstretch{1}

\begin{centering}

$ $

\vspace{4.cm}

\LARGE

{\bf Histograms should not be used to segment functional lung MRI}

\vspace{1.5 cm}

\normalsize

Nicholas J. Tustison$^{1}$,
Talissa A. Altes$^{2}$,
Kun Qing$^{3}$,
James C. Gee$^{4}$,
G. Wilson Miller$^{1}$,
John P. Mugler III$^{1}$,
Jaime F. Mata$^{1}$

\footnotesize

$^{1}$Department of Radiology and Medical Imaging, University of Virginia, Charlottesville, VA \\
$^{2}$Department of Radiology, University of Missouri, Columbia, MO \\
$^{3}$Department of Radiation Oncology, City of Hope, Duarte, CA \\
$^{4}$Department of Radiology, University of Pennsylvania, Philadelphia, PA \\

\end{centering}

\vspace{9 cm}


\scriptsize
Corresponding author: \
Nicholas J. Tustison, DSc \
Department of Radiology and Medical Imaging \
University of Virginia \
ntustison@virginia.edu

<!-- \noindent\rule{4cm}{0.4pt}

\tiny
$^{\dagger}$Data used in preparation of this article were obtained from the Alzheimer’s
Disease Neuroimaging Initiative (ADNI) database (http://adni.loni.usc.edu). As
such, the investigators within the ADNI contributed to the design and
implementation of ADNI and/or provided data but did not participate in analysis
or writing of this report. A complete listing of ADNI investigators can be found
at: http://adni.loni.usc.edu/wp-content/uploads/how to apply/AD NI Acknowledgement List.pdf
 -->

\normalsize

\newpage

\setstretch{1.5}

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



# Introduction {-}

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


Subsequently, initial attempts at quantification were limited to ennumerating
the number of "ventilation defects" or estimating ventilation defect percentage
(as a percentage of total lung volume).

Additional sophistication:

* linear binning
* (semi-automated) k-means
* some percentage of the global mean intensity
* Gaussian mixture modeling with Markov Random Field prior-based smoothing





# Methods {-}


# Results {-}




# Discussion {-}


\newpage

# References {-}