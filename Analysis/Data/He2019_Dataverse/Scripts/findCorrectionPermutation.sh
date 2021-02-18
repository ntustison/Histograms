#! /usr/bin/sh

# PermuteFlipImageOrientationAxes ImageDimension  inputImageFile  outputImageFile xperm yperm {zperm}

###############

# for i in `ls *Noise*.nii.gz`; do echo $i; PermuteFlipImageOrientationAxes 3 $i ../Nifti/${i} 0 2 1 0 0 1; SetDirectionByMatrix ../Nifti/${i} ../Nifti/${i} 1 0 0 0 1 0 0 0 1; done

# image=../NiftiOriginal/7_XeVent_Noise_1.nii.gz

# i=0
# PermuteFlipImageOrientationAxes 3 $image ${outPrefix}${i}.nii.gz 0 2 1 0 0 1
# SetDirectionByMatrix ${outPrefix}${i}.nii.gz ${outPrefix}${i}.nii.gz 1 0 0 0 1 0 0 0 1

###############

# for i in `ls *mask.nii.gz`; do echo $i; PermuteFlipImageOrientationAxes 3 $i ../Nifti/${i} 1 2 0 0 1 1; SetDirectionByMatrix ../Nifti/${i} ../Nifti/${i} 1 0 0 0 1 0 0 0 1; done

image=../NiftiOriginal/7_GRE1L_lungsmask.nii.gz
refImage = /Users/ntustison/Desktop/He2019_Dataverse/Nifti/7_XeVent_Noise_1.nii.gz


# i=0
# PermuteFlipImageOrientationAxes 3 $image ${outPrefix}${i}.nii.gz 0 2 1 0 0 0
# SetDirectionByMatrix ${outPrefix}${i}.nii.gz ${outPrefix}${i}.nii.gz 1 0 0 0 1 0 0 0 1

i=1
PermuteFlipImageOrientationAxes 3 $image ${outPrefix}${i}.nii.gz 1 2 0 0 1 1
SetDirectionByMatrix ${outPrefix}${i}.nii.gz ${outPrefix}${i}.nii.gz 1 0 0 0 1 0 0 0 1
CopyImageHeaderInformation $refImage ${outPrefix}${i}.nii.gz ${outPrefix}${i}.nii.gz 1 1 1

# i=2
# PermuteFlipImageOrientationAxes 3 $image ${outPrefix}${i}.nii.gz 1 0 2 0 0 0
# SetDirectionByMatrix ${outPrefix}${i}.nii.gz ${outPrefix}${i}.nii.gz 1 0 0 0 1 0 0 0 1

# i=3
# PermuteFlipImageOrientationAxes 3 $image ${outPrefix}${i}.nii.gz 2 0 1 0 0 0
# SetDirectionByMatrix ${outPrefix}${i}.nii.gz ${outPrefix}${i}.nii.gz 1 0 0 0 1 0 0 0 1

# i=4
# PermuteFlipImageOrientationAxes 3 $image ${outPrefix}${i}.nii.gz 2 1 0 0 0 0
# SetDirectionByMatrix ${outPrefix}${i}.nii.gz ${outPrefix}${i}.nii.gz 1 0 0 0 1 0 0 0 1
