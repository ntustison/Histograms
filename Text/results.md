
# Results

Evaluations:

* Algorithmic precision

    * Three-tissue T1-weighted brain MRI segmentation (qualitative analog)
    * Input variance of reference distribution $\longrightarrow$ output variance (linear binning only)
    * Effects of simulated MR artefacts

* Algorithmic bias (in the absence of ground truth)

    * Dx prediction
    * STAPLE

## Dx prediction

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.99\linewidth]{Figures/volumeXRocDx.pdf}
  \caption{}
  \label{fig:DxPrediction}
\end{figure}

\include{dxPredictionAucTable}

In the absence of ground truth, this type of evaluation does confirm that these
these measurements are clinically relevant.  However, this is a very coarse
assessment.  For example, spirometry measures alone can be used to achieve
highly accurate predictions using machine learning techniques [@Badnjevic:2018aa].


## T1-weighted brain segmentation analogy

As a preview of the


In Figure \ref{fig:BrainAnalogy}

Although the reference image set has been intensity normalized to $[0, 1]$ with
truncated image intensities (quantiles = $[0, 0.99]$), it is apparent that
the major features of the respective image histograms (specifically, the three
peaks which correspond to the cerebrospinal fluid (CSF), gray matter (GM), and
white matter (WM)) do not line up in this globally aligned space.  Attempting to
create a "reference" histogram from misaligned data is not without controversy.
This can be seen in the results shown in the bottom where the linear binning
analog drastically overstimates the amount of gray matter and simultaneously
underestimates the amount of gray matter.  The k-means approach, using precisely
the same center clusters as determined via the reference histogram, yields a
much better segmentation as it is optimizing the piecewise affine transform over
histogram features.  However, the hard threshold values result in labelings
susceptible to noise in contrast to the GMM-MRF segmentation results.

\begin{figure}[!h]
  \centering
  \includegraphics[width=0.95\linewidth]{Figures/BrainAnalogy.pdf}
  \caption{T1-weighted three-tissue brain segmentation analogy. Placing the
  three segmentation algorithms (i.e., linear binning, k-means, and GMM-MRF) in
  the context of brain tissue segmentation provides an alternative perspective
  for comparison.  In the style of linear binning, we randomly select an image
  reference set using structurally normal individuals which is then used to
  create a reference histogram.  (Bottom) For a subject to be processed, the
  resulting hard threshold values yield the linear binning segmentation solution
  as well as the initialization cluster values for both the k-means and GMM-MRF
  segmentations which are qualitatively different.}
  \label{fig:BrainAnalogy}
\end{figure}

## Effect of reference image set selection

<!--
\begin{figure}[!h]
  \centering
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/meanReferencePlot.pdf}
    \caption{Original: variation of the reference mean.}
  \end{subfigure}%
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/meanReferenceN4Plot.pdf}
    \caption{N4:  variation of the mean.}
  \end{subfigure} \\
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/sdReferencePlot.pdf}
    \caption{Original:  variation of the standard deviation.}
  \end{subfigure}%
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/sdReferenceN4Plot.pdf}
    \caption{N4:  variation of the standard deviation.}
  \end{subfigure} \\
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/referencePlot_10_1.pdf}
    \caption{Original:  clustered reference distribution.}
  \end{subfigure}%
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/referencePlot_10_1_N4.pdf}
    \caption{N4:  clustered reference distribution.}
  \end{subfigure}
\caption{Original (left) vs. N4-preprocessed (right) images and the effects on the
reference distribution.  The reference distribution was generated from 10 young
healthy controls.  Sample reference distributions were generated for all combinations
from 1 to 9 images (both original and N4-preprocessed) and (a)-(d) plotted the resulting
variance in reference distribution parameters (i.e., mean and standard deviation)
which define the clusters in the linear binning algorithm. Reference distributions
for all ten healthy controls for both the (e) original and (f) N4 images.}
\label{fig:referenceSet}
\end{figure}
-->

\begin{figure}[!h]
  \centering
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/referencePlot_10_1.pdf}
    \caption{Original:  clustered reference distribution.}
  \end{subfigure}%
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/referencePlot_10_1_N4.pdf}
    \caption{N4:  clustered reference distribution.}
  \end{subfigure}
\caption{}
\label{fig:n4ornot}
\end{figure}

One important issue was whether or not to use the N4 bias correction algorithm
as a preprocessing step.  We ultimately decided to include it for a couple
reasons.  It is explicitly used in multiple algorithms (e.g.,
[@Tustison:2011aa;@He:2016aa;@Shammi:2021aa]) despite the issues raised previously
and elsewhere [@He:2020aa] due to the fact that it qualitatively improves
image appearance.[^4]

[^4]:  This assessment is based on multiple conversations between the first
author (as the developer of N4 and Atropos) and co-author Dr. Talissa Altes,
one of the most experienced individuals in the field.

\begin{figure}[!h]
  \centering
  \includegraphics[width=0.99\textwidth]{Figures/referenceVariation.pdf}
  \caption{}
  \label{fig:referenceVariance}
\end{figure}

There was another practical reason why this step was included and it concerns
the reference distribution required by the linear binning algorithm. As
mentioned, a significant portion of N4 processing involves the deconvolution of
the image histogram to sharpen the histogram peaks which decreases the standard
deviation of the intensity distribution and can also result in an histogram
shift. Using the original set of 10 young healthy data with no N4 preprocessing,
we created a reference distribution according to [@He:2016aa], which resulted in
an approximate distribution of $\mathcal{N}(0.45, 0.24)$.  This produced 0
voxels being classified as belonging to cluster 1 (i.e., ventilation defect)
because two standard deviations from the mean is less than 0 and cluster 1
resides between -3 and -2 standard deviations.  However using N4-preprocessed
images produced something closer,  $\mathcal{N}(0.56, 0.22)$, to the published
values, $\mathcal{N}(0.52, 0.18)$, reported in [@He:2016aa], resulting in a
non-empty set for cluster 1.

In addition to this pointing to a potential issue when applying linear binning
to multi-site data, it prompted us to look at an associated precision issue due
to reference cohort selection.


## Effect of MR nonlinear intensity warping and additive noise

Need to add a SSIM calculation for each simulated image along with different
histogram similarity measurements.  We can then rescale all measurements for
comparison and show how the SSIM calculation has lower variance than the
histograms.  THis shows that the image-to-histogram transformation results in
information which is less robust than the original image.






\begin{figure}[htb]
  \centering
  \includegraphics[width=0.99\linewidth]{Figures/VarianceStudy.pdf}
\caption{}
\label{fig:simulations}
\end{figure}


\input{varianceTable}

## Diagnostic prediction
