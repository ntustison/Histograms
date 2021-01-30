
# Results

## T1-weighed brain segmentation analogy

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

\begin{figure}[htb]
  \centering
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.99\linewidth]{Figures/meanReferencePlot.pdf}
    \caption{Mean reference plot.}
  \end{subfigure}%
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.99\linewidth]{Figures/sdReferencePlot.pdf}
    \caption{Standard deviation reference plot.}
  \end{subfigure}
\caption{}
\label{fig:referenceSet}
\end{figure}

## Effect of MR nonlinear intensity warping and additive noise

\begin{figure}[htb]
  \centering
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.99\linewidth]{Figures/vdpSdOverall.pdf}
    \caption{Mean reference plot.}
  \end{subfigure}%
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.99\linewidth]{Figures/diceMeanOverall.pdf}
    \caption{Standard deviation reference plot.}
  \end{subfigure}
\caption{}
\label{fig:simulations}
\end{figure}



## Diagnostic prediction
