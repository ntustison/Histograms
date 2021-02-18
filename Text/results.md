
# Results

We perform several comparative evaluations to probe the previously mentioned
algorithmic issues which are broadly categorized in terms of measurement bias
and precision, with most of the focus being on the latter.  Given the lack of
ground-truth in the form of segmentation images, addressing issues of measurement
bias is difficult.  In addition to the fact that the number of ventilation clusters
is not consistent across algorithms, it is not clear that the ventilation categories
across algorithms have identical clinical definition.  This prevents application of
various frameworks accommodating the lack of ground-truth for segmentation performance
analysis (e.g., [@Warfield:2004aa]) to these data.

As we mentioned in the Introduction, all the algorithms have demonstrated
research (and potential clinical) utility based on findings using derived
measures. This is supported by our first evaluation which is based on diagnostic
prediction of given clinical categories assigned to the imaging cohort using
derived random forest models [@Breiman:2001aa].  This approach also provides an
additional check on the validity of the algorithmic implementations.  However,
it is important to recognize that this evaluation is extremely limited as the
underlying data are gross measures which do not provide accuracy estimates on
the level of the algorithmic output (i.e., voxelwise segmentation).

Having established the general validity of the gross algorithmic output, we then
switch to our primary focus which is the comparison of measurement precision
between algorithms.   We first analyze
the unique requirement of a reference distribution for the linear binning
algorithm.  The latter is motivated qualitatively through the analogous
application of T1-weighted brain MR segmentation.  This component is strictly
qualitative as the visual evidence and previous developmental history within
that field should be sufficiently compelling in motivating subsequent
quantitative exploration with hyperpolarized gas lung imaging.  These
qualitative results segue to quantifying the effects of the choice of
reference cohort on the clustering parameters for the linear binning algorithm.
We then incorporate the trained El Bicho model in exploring additional aspects of
measurement variance based on simulating both MR noise and intensity
nonlinearities.

So, in summary, we perform the following evaluations/experiments:[^103]

* Global algorithmic bias (in the absence of ground truth)

    * Diagnostic prediction

* Voxelwise algorithmic precision

    * Three-tissue T1-weighted brain MRI segmentation (qualitative analog)
    * Input/output variance based on reference distribution (linear binning only)
    * Effects of simulated MR artefacts

[^103]: It is important to note that, although these experiments provide supporting
evidence, our principal contention stands prior to these results and are based on
the self-evidentiary observations mentioned in the Introduction.

## Diagnostic prediction

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.99\linewidth]{Figures/volumeXRocDx.pdf}
  \caption{ROC curves resulting from the diagnostic prediction evaluation
  strategy involving randomly permuted training/testing data sets and predictive
  random forest models. Summary values are provided in Table \ref{table:auc}.}
  \label{fig:DxPrediction}
\end{figure}

Due to the absence of ground-truth but the availability , we adopt
the strategy from previous work [@Tustison:2014ab;@Tustison:2020aa] where we
used cross-validation to build and compare prediction models from data derived
from the set of segmentation algorithms.  Specifically, we use pathology
diagnosis (i.e., "CF", "COPD", and "ILD") as an established research-based
correlate of ventilation levels from hyperpolarized gas imaging (e.g.,
[@Myc:2020aa;@Santyr:2019aa;@Mammarappallil:2019aa]) and quantify the
predictive capabilities of corresponding binary random forest classifiers
[@Breiman:2001aa] of the form:

\begin{equation}
  Pathology\,\,vs.\,\,Healthy \sim \sum_{i=1}^3 \frac{Volume_i}{Total\,\,volume}
\end{equation}

where $Volume_i$ is the volume of the $i^{th}$ cluster and $Total\,\,volume$ is total lung
volume.  We used a training/testing split of 80/20.  Due to the small number
of subjects, we combined the young and old healthy data into a single category.
100 permutations were used where training/testing data were randomly assigned
and the corresponding random forest model was constructed at each permutation.

\input{dxPredictionAucTable}

The resulting receiver operating characteristic (ROC) curves for each algorithm
and each diagnostic scenario are provided in Figure \ref{fig:DxPrediction}.  In
addition, we provide the summary area under the ROC curve (AUC) values in Table
\ref{table:auc}. In the absence of ground truth, this type of evaluation does
provide evidence that all these algorithms produce measurements which are clinically
relevant although, it should be noted, that this is a very coarse assessment strategy
given the global measures used (i.e., cluster volume percentage) and the general
clinical categories employed.  In fact, even spirometry measures can be used to achieve
highly accurate diagnostic predictions with machine learning techniques
[@Badnjevic:2018aa].

## T1-weighted brain segmentation analogy

\begin{figure}[!h]
  \centering
  \includegraphics[width=0.95\linewidth]{Figures/BrainAnalogy.pdf}
  \caption{T1-weighted three-tissue brain segmentation analogy. Placing
  three of the four segmentation algorithms (i.e., linear binning, k-means, and GMM-MRF) in
  the context of brain tissue segmentation provides an alternative perspective
  for comparison.  In the style of linear binning, we randomly select an image
  reference set using structurally normal individuals which is then used to
  create a reference histogram.  (Bottom) For a subject to be processed, the
  resulting hard threshold values yield the linear binning segmentation solution
  as well as the initialization cluster values for both the k-means and GMM-MRF
  segmentations which are qualitatively different.}
  \label{fig:BrainAnalogy}
\end{figure}

Much of the quantitative image analysis strategies that have been used for
hyperpolarized gas imaging draw on inspiration from fields with a much greater
historical background of development, including T1-weighted brain MRI tissue
segmentation.  The depth of this development can be gauged simply by the number
of technical reviews (e.g., [@Bezdek:1993aa;@Pham:2000aa;@Despotovic:2015aa]) and
evaluation studies (e.g., [@Cuadra:2005aa;@Boer:2010aa]) that date back decades.
In addition to technical insight, this particular application provides a useful
analogy for some of the algorithmic issues discussed and provides context for
subsequent evaluations specific to hyperpolarized gas imaging.

In the style of linear binning, we randomly selected ten structurally healthy
controls from the publicly available SRPB data set [@srpb] comprising over 1600
participants from 12 sites.  After intensity truncation at the 0.99 quantile, we
normalize the intensity histogram to [0,1].  Eight of these histograms are
provided in the upper left of Figure \ref{fig:BrainAnalogy}.  As we mentioned
previously, the histograms for these structural MRI are typically characterized
by three peaks which correspond to the CSF, GM, and WM.  However, even when
normalized to [0, 1] (i.e., global affine mapping), it is obvious that these
histogram features do not line up and this is due to the intensity distortion
caused by various MR acquisition artefacts mentioned previously.  This is an
argument from analogy against one of the principal assumptions of linear binning
where it is assumed that tissue types ("structural" in the case of T1-weighted
brain MRI or "ventilated" in the case of hyperpolarized gas imaging) can be
sufficiently aligned with a global rescaling of intensity values. If we pursue
this analogy further and use the aggregated reference distribution to segment a
different subject, we can see that, in this particular case, whereas the
optimization criterion leveraged by k-means and GMM-MRF provide an adequate
segmentation, the misalignment in cluster boundaries yield a significant
overestimation of the gray matter volume.


## Effect of reference image set selection

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
algorithms is the generation of a reference distribution.  In addition to the
output measurement variation caused by choice of the reference image cohort,
this played a role in determining whether or not to use N4 preprocessing. As
mentioned, a significant portion of N4 processing involves the deconvolution of
the image histogram to sharpen the histogram peaks which decreases the standard
deviation of the intensity distribution and can also result in an histogram
shift. Using the original set of 10 young healthy data with no N4 preprocessing,
we created a reference distribution according to [@He:2016aa], which resulted in
an approximate distribution of $\mathcal{N}(0.45, 0.24)$.  This produced 0
voxels being classified as belonging to Cluster 1 (i.e., ventilation defect)
because two standard deviations from the mean is less than 0 and Cluster 1
resides in the region below -2 standard deviations.  However using N4-preprocessed
images produced something closer,  $\mathcal{N}(0.56, 0.22)$, to the published
values, $\mathcal{N}(0.52, 0.18)$, reported in [@He:2016aa], resulting in a
non-empty set for that cluster.  This is consistent, though, with linear binning
which does use N4 bias correction for preprocessing.

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
the measurements utlized and produced by linear binning. Regarding the former,
we took all possible combinations of our young healthy control subject images
and looked at the resulting mean and standard deviation values.  As expected,
there is quite a bit of variation for both mean and standard deviation values
(see top portion of Figure \ref{fig:referenceVariance}) which are used to derive
the cluster threshold values.  This directly impacts output measurements such as
ventilation defect percentage. For the reference sets comprising eight or nine
images, we compute the corresponding linear binning segmentation and
estimate the volumetric percentage for each cluster.  Then, for each subject, we
compute the min/max range for these values and plot those results cluster-wise
on the bottom of Figure \ref{fig:referenceVariance}.  This demonstrates that
the additional requirement of a reference distribution is a source of potentially
significant measurement variation for the linear binning algorithm.


## Effects of MR-based simulated image distortions

\begin{figure}[!htb]
  \centering
  \includegraphics[width=0.99\linewidth]{Figures/DiceVarianceStudy.pdf}
\caption{(Left) The deviation in resulting segmentation caused by distortions produced
         noise, histogram-based intensity nonlinearities, and their combination
         as measured by the Dice metric.  Each segmentation is reduced to three
         labels for comparison:  ``ventilation defect'' (Cluster 1),
         ``hypo-ventilation'' (Cluster 2), ``other ventilation'' (Cluster 3).
         (Right) Results from the Tukey Test following one-way ANOVA to compare
         the deviations.  Higher positive values are indicative of increased
         robustness to simulated image distortions.
         }
\label{fig:simulations}
\end{figure}

As we mentioned in the Introduction, noise and nonlinear intensity artefacts
common to MRI can have a significant distortion effect on the image with even
greater effects seen with respect to change in  the structure of the
corresponding histogram.  This final evaluation explores the effects of these
artefacts on the algorithmic output on a voxelwise scale using the Dice
metric (Equation (\ref{eq:dice})) which has a range of [0,1] where 1 signifies
perfect agreement between the segmentations and 0 is no agreement.

Ten simulated images for each of the 51 subjects were generated for each of the
three categories of randomly generated artefacts:  noise, nonlinearities, and
combined noise and intensity nonlinearites.  The original image as well as the
simulated images were segmented using each of the four algorithms.  Following
our earlier protocol, we maintained the original Clusters 1 and 2 per algorithm
and combined the remaining clusters into a single third cluster.  This allowed
us to compare between algorithms and maintain separate those clusters which are
the most studied and reported in the literature.  The Dice metric was used to
quantify the amount of deviation, per cluster, between the segmentation produced
by the original image and the corresponding simulated distorted image
segmentation which are plotted in Figure \ref{fig:simulations} (left column).
These results were then compared, on a per-cluster and per-artefact basis, using
a one-way ANOVA followed by Tukey's Honest Significant Difference (HSD) test.
95% confidence intervals are provided in the right column of Figure
\ref{fig:simulations}.


