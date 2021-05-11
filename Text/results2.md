
# Results

We performed several comparative evaluations to probe the previously mentioned
issues broadly categorized in terms of measurement bias and precision, with most
of the focus being on the latter.  Given the lack of ground-truth in the form of
segmentation images, addressing issues of measurement bias is difficult.  In
addition to the fact that the number of ventilation clusters is not consistent
across algorithms, it is not clear that the ventilation categories across
algorithms have identical clinical definition. This prevents application of
various frameworks accommodating the lack of ground-truth for segmentation
performance analysis (e.g., [@Warfield:2004aa]) to these data.

As mentioned in the Introduction, the cited algorithms have all demonstrated
research utility and potential clinical utility. This is supported by our first
evaluation which is based on diagnostic prediction of given clinical categories
assigned to the imaging cohort using
derived random forest models [@Breiman:2001aa].  This approach also provides an
additional check on the validity of the algorithmic implementations.  However,
it is important to recognize that this evaluation is extremely limited as the
underlying data are gross measures which do not provide accuracy estimates on
the level of the algorithmic output (i.e., voxelwise segmentation).

Having established the general validity of the gross algorithmic output, we then
switch to our primary focus which is the comparison of measurement precision
between algorithms.   We first analyzed the unique requirement of a reference
distribution for the linear binning algorithm.  Specifically, we quantify the
effects of the choice of reference cohort on the clustering parameters for the
linear binning algorithm. We then incorporate the trained El Bicho model in
exploring additional aspects of measurement variance based on simulating both MR
noise and intensity nonlinearities.

\textcolor{blue}{To summarize}, we performed the following evaluations/experiments:

* Global algorithmic bias (in the absence of ground truth)

    * Diagnostic prediction

* Voxelwise algorithmic precision

    * Input/output variance based on reference distribution (linear binning only)
    * Effects of simulated MR artefacts on multi-site data

<!--
[^103]: It is important to note that, although these experiments provide supporting
evidence, our principal contentions stand prior to these results and are based on
the self-evidentiary observations mentioned in the Introduction.
-->

## Diagnostic prediction

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.99\linewidth]{Figures/volumeXRocDx.pdf}
  \caption{ROC curves resulting from the diagnostic prediction evaluation
  strategy involving randomly permuted training/testing data sets and predictive
  random forest models.}
  \label{fig:DxPrediction}
\end{figure}

Due to the absence of ground-truth, we adopted
the strategy from previous work [@Tustison:2014ab;@Tustison:2021aa] where we
used cross-validation to build and compare prediction models from data derived
from the set of segmentation algorithms.  Specifically, we use pathology
diagnosis (i.e., "CF", "COPD", and "ILD") as an established research-based
correlate of ventilation levels from hyperpolarized gas imaging (e.g.,
[@Myc:2020aa;@Santyr:2019aa;@Mammarappallil:2019aa]) and quantified the
predictive capabilities of corresponding binary random forest classifiers
[@Breiman:2001aa] of the form:

\begin{equation}
  Pathology\,\,vs.\,\,Healthy \sim \sum_{i=1}^3 \frac{Volume_i}{Total\,\,volume}
\end{equation}

where $Volume_i$ is the volume of the $i^{th}$ cluster and $Total\,\,volume$ is total lung
volume \textcolor{blue}{which is recognized as a multiple-cluster summation
extension of the ventilation defect percentage.}  We used a training/testing split of 80/20.  Due to the small number
of subjects, we combined the young and old healthy data into a single category.
100 permutations were used where training/testing data were randomly assigned
and the corresponding random forest model was constructed at each permutation.

<!-- \input{dxPredictionAucTable} -->

The resulting receiver operating characteristic (ROC) curves for each algorithm
and each diagnostic scenario are provided in Figure \ref{fig:DxPrediction}.
All four algorithms perform significantly better than a random classifier.
In the absence of ground truth, this type of evaluation does provide evidence
that all these algorithms produce measurements which are clinically relevant
although, it should be noted, that this is a very coarse assessment strategy
given the global measures used (i.e., cluster volume percentage) and the general
clinical categories employed.  In fact, even spirometry measures can be used to
achieve highly accurate diagnostic predictions with machine learning techniques
[@Badnjevic:2018aa].

## Effects of reference image set selection

\begin{figure}[!htb]
  \centering
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/referencePlot_10_1.pdf}
    \caption{Reference distribution (original images).}
  \end{subfigure}%
  \begin{subfigure}{0.5\textwidth}
    \centering
    \includegraphics[width=0.95\linewidth]{Figures/referencePlot_10_1_N4.pdf}
    \caption{Reference distribution (N4 images).}
  \end{subfigure}
  \caption{Ten young healthy subjects were combined to create two reference
        distributions, one based on the (a) original images and the other using (b) N4
        preprocessing.  Based on the generated mean and standard deviation of the
        aggregated samples, we label the resulting clusters in the respective
        histograms.  Due to the lower mean and higher standard deviation of the
        original image set, Cluster 1 is not within the range of $[0, 1]$ for the
        resulting reference distribution which motivated the use of the
        N4 preprocessed image set.
         }
\label{fig:n4ornot}
\end{figure}

One of the additional input requirements for linear binning over the other
algorithms is the generation of a reference distribution.  Therefore, we
additionally investigated the influence of reference data set on the outcome of
linear binning classification, since this is an integral aspect unique to this
method.  In addition to the
output measurement variation caused by choice of the reference image cohort,
this played a role in determining whether or not to use N4 preprocessing. As
mentioned, a significant portion of N4 processing involves the deconvolution of
the image histogram to sharpen the histogram peaks which decreases the standard
deviation of the intensity distribution and can also result in a histogram
shift. Using the original set of 10 young healthy data with no N4 preprocessing,
we created a reference distribution according to [@He:2016aa], which resulted in
an approximate distribution of $\mathcal{N}(0.45, 0.24)$.  This produced 0
voxels being classified as belonging to Cluster 1 (Figure \ref{fig:n4ornot}(a))
because two standard deviations from the mean is less than 0 and Cluster 1
resides in the region below -2 standard deviations.  However, using N4-preprocessed
images produced something closer,  $\mathcal{N}(0.56, 0.22)$, to the published
values, $\mathcal{N}(0.52, 0.18)$, reported in [@He:2016aa], resulting in a
non-empty set for that cluster.  This is consistent, though, with linear binning
which does use N4 bias correction for preprocessing.  We also mention that the
Harvard Dataverse images used were preprocessed using N4 [@He:2019aa]
which provides a third reason for its use on the University of Virginia image
dataset (to maximize cross cohort consistency).  In the case of the former
image set, we did use the previously reported linear binning mean and standard
deviation algorithm parameter values (i.e., $\mathcal{N}(0.52, 0.18)$).  This
was the only parameter difference between analyzing the two image sets.

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.99\textwidth]{Figures/referenceVariation.pdf}
  \caption{(Top) Variation of the mean (left) and standard deviation (right)
  over choice of reference set based on all different combinations of young
  healthy subjects per specified number of subjects. Although these parameters
  demonstrate convergence, there is still non-zero variation for any given set.
  (Bottom) This input variance is a source of output variance in the cluster
  volume plotted as the maximum range per subject as a percentage of total lung
  volume.  We limit this exploration to reference sets with eight or nine images.
  }
  \label{fig:referenceVariance}
\end{figure}

The previous implications of the chosen image reference set also caused us to
look at this choice as a potential source of both input and output variance in
the measurements utilized and produced by linear binning. Regarding the former,
we took all possible combinations of our young healthy control subject images
and looked at the resulting mean and standard deviation values.  As expected,
there is significant variation for both mean and standard deviation values
(see top portion of Figure \ref{fig:referenceVariance}) which are used to derive
the cluster threshold values.  This directly impacts output measurements such as
ventilation defect percentage. For the reference sets comprising eight or nine
images, we compute the corresponding linear binning segmentation and
estimate the volumetric percentage for each cluster.  Then, for each subject, we
computed the min/max range for these values and plotted those results cluster-wise
on the bottom of Figure \ref{fig:referenceVariance}.  This demonstrates that
the additional requirement of a reference distribution is a source of potentially
significant measurement variation for the linear binning algorithm.


## Effects of MR-based simulated image distortions

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.75\linewidth]{Figures/DiceVarianceStudyVersion2a.pdf}
  \caption{University of Virginia image cohort.  \textcolor{blue}{Box plots
  illustrate the lack of segmentation overlap with reference segmentations
  caused by distortions produced by noise, histogram-based intensity
  nonlinearities, and their combination as measured by the Dice metric over all
  five algorithms.  We provide the results of the two pathologically-relevant
  labels for comparison: ``ventilation defect'' (Cluster 1) and
  ``hypo-ventilation'' (Cluster 2).  }
  }
\label{fig:simulations}
\end{figure}

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.85\linewidth]{Figures/DiceVarianceStudyVersion2b.pdf}
  \caption{University of Virginia image cohort.  \textcolor{blue}{(Left) Results
  from Tukey's test following one-way ANOVA to compare the resulting overlaps
  between algorithms (cf Figure \ref{fig:simulations}). Higher positive values
  indicate increased robustness to simulated image distortions. A solid line indicates
  statistical significance at the 0.05 level whereas the dashed line indicates no
  statistically significant difference.  (Right)
  To further visualize the Tukey results, a simplified alluvial diagram is used to
  provide connections illustrating relative performance between algorithms where
  the algorithms listed on the left have improved performance relative to their
  connected algorithms on the right with the width of the connection being
  proportional to difference in performance.}
  }
\label{fig:simulations2}
\end{figure}


As we mentioned in the Introduction, noise and nonlinear intensity artefacts
common to MRI can have a significant distortion effect on the image with even
greater effects seen with respect to change in  the structure of the
corresponding histogram.  This final evaluation explores the effects of these
artefacts on the algorithmic output on a voxelwise scale using the Dice
metric (Equation (\ref{eq:dice})) which has a range of [0,1] where 1 signifies
perfect agreement between the segmentations and 0 is no agreement.

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.75\linewidth]{FiguresDataverse/DiceVarianceStudyVersion2a.pdf}
  \caption{Harvard Dataverse image cohort.  \textcolor{blue}{Box plots
  illustrate the lack of segmentation overlap with reference segmentations
  caused by distortions produced by noise, histogram-based intensity
  nonlinearities, and their combination as measured by the Dice metric over all
  five algorithms.  We provide the results of the two pathologically-relevant
  labels for comparison: ``ventilation defect'' (Cluster 1) and
  ``hypo-ventilation'' (Cluster 2).}
  }
\label{fig:simulationsDataverse}
\end{figure}

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.85\linewidth]{FiguresDataverse/DiceVarianceStudyVersion2b.pdf}
  \caption{Harvard Dataverse image cohort.  \textcolor{blue}{(Left) Results
  from Tukey's test following one-way ANOVA to compare the resulting overlaps
  between algorithms (cf Figure \ref{fig:simulationsDataverse}). Higher positive values
  indicate increased robustness to simulated image distortions. A solid line indicates
  statistical significance at the 0.05 level whereas the dashed line indicates no
  statistically significant difference.  (Right)
  To further visualize the Tukey results, a simplified alluvial diagram is used to
  provide connections illustrating relative performance between algorithms where
  the algorithms listed on the left have improved performance relative to their
  connected algorithms on the right with the width of the connection being
  proportional to difference in performance.}
  }
  \label{fig:simulationsDataverse2}
\end{figure}

Ten simulated images for each of the subjects of both the University of Virginia
and Harvard Dataverse cohort were generated for each of the three categories of
randomly generated artefacts:  noise, nonlinearities, and combined noise and
intensity nonlinearities.  The original image as well as the simulated images
were segmented using each of the five algorithms.  Following our earlier
protocol, we maintained the original Clusters 1 and 2 per algorithm and combined
the remaining clusters into a single third cluster.  This allowed us to compare
between algorithms and maintain separate those clusters which are the most
studied and reported in the literature.  The Dice metric was used to quantify
the amount of deviation, per cluster, between the segmentation produced by the
original image and the corresponding simulated distorted image segmentation
which is summarized in Figures \ref{fig:simulations} and
\ref{fig:simulationsDataverse}. The algorithms were then compared, on a
per-cluster and per-artefact basis, using one-way ANOVA followed by Tukey's
Honest Significant Difference (HSD) test in Figures \ref{fig:simulations2} and
\ref{fig:simulationsDataverse2}.  \textcolor{blue}{The results of these tests
are further visualized via simplified alluvial diagrams with the superior
performing algorithms, in terms of Dice overlap,  listed on the
left connecting to their worse performing counterparts on the right where the width of the
connection is proportional to the overlap difference and colored by
artefact type.  The algorithms which exploit image-based spatial information,
most notably El Bicho, demonstrate generally superior performance as compared
with their histogram-only counterparts in both data sets.  For example, in
Cluster 1, for both datasets, the sole histogram-only algorithm that demonstrates
any elevated pairwise performance is k-means but, proportionally, this significance
is dwarfed by the performance of the algorithms which leverage spatial information.
Additionally, it is apparent from these tests that El Bicho consistently provides the
best performance across the specified clusters in the presence of MR-based image distortions.
}








