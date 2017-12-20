# plenoptic-camera-calibration
Matlab code for plenoptic camera calibration. CHeck the supplementary video for an overview of the process.

Before running the following steps ensure that the micro-lens centers are available. If not, run LightFieldCalib_Step1_MicroLensCenter using your camera's
white images.



## Step 1
<img align="right" width="100" height="65" src="https://user-images.githubusercontent.com/30299128/31303253-46be7a3c-aad8-11e7-8b7a-db69738d2887.jpg">

```
Plenoptic_GeoCalibration_Step2_Center_Image: Obtain the central sub-aperture images.
```

## Step 2
<img align="right" width="100" height="65" src="https://user-images.githubusercontent.com/30299128/31303283-d1d645dc-aad8-11e7-9d9f-d8e2230c4845.jpg">

```
centersNearWorldCorners: Find the micro-lenses which observe the same 3D corner.
```

## Step 3
<img align="right" width="100" height="100" src="https://user-images.githubusercontent.com/30299128/31303299-30589204-aad9-11e7-8b40-bb4031f14b3f.png">

```
microImageCornerDetection: Detect the corners in the micro-images. Input is a single image 
but can be wrapped to run in many images.
```

## Step 4
```
centersFromCorners: Match detected micro-image corners to its corresponding micro-lens center.
```

## Step 5
Runs for one image of the dataset. No need to run for others. If no lens_types are saved, use other image or increase the number of detected corner.

<img align="right" width="100" height="65" src="https://user-images.githubusercontent.com/30299128/31303335-b417667e-aad9-11e7-9a51-998a142d54fc.jpg">

```
clusterCornerPointsLocal

typeClassificationUsingCircularRegion

makeGridTypeGeneral
```

## Step 6
```
cornerCorrespondences: Assign the 2D-to-3D correspondences.
```


## Step 7
This step can be run with one or more images. At the moment the user enters which type of lenses wants to calibrate but
can be easily wrapped to run for all the types. If different number than 1, 2, 3 is given as input the calibration will 
procceed assuming all the lenses are the same. In order for this to work though, the correspondences have to be assigned 
in a similar manner. Saves the intrinsics and extrinsics after the linear solution and the non-linear optimisation.

```
cornerLinearSolutionManyImages
```

<p align="center">
  <img width="350" height="190" src="https://user-images.githubusercontent.com/30299128/34208931-440bf0c4-e55e-11e7-919f-e890c1886551.gif">
</p>
