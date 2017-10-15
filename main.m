%% I. Add paths

addpath(genpath(pwd));




%% III. Create the pattern size text file.

pattern_size = input('Enter the grid size in mm:\n');

file = fopen('pattern_sz.txt', 'w+');

fprintf(file, '%d', pattern_size);

fclose(file);

copyfile('pattern_sz.txt', 'pattern_size.txt');
delete('pattern_sz.txt')




%% Flow of the calibration.

% if the centers of the micro-lenses are not known beforehand, run 
% LightFieldCalib_Step1_MicroLensCenter

% Assumed that the micro-lens centers are extracted.

% I. Extract the central sub-aperture image 

% % Plenoptic_GeoCalibration_Step2_Center_Image

% II. Detect the micro-lens centers near the corners.

% % centersNearWorldCorners

% III. Find the corners in the image (this works for one image only).

% % microImageCornerDetection

% IV. Find the corresponding centers that observe these corners.

% % centersFromCorners

% V. Classify micro-lenses based on focus measure

% % clusterCornerPointsLocal

% % typeClassificationUsingCircularRegion

% % makeGridTypeGeneral

% VI. Assign the correspondences

% % cornerCorrespondences

% VII. Calibrate.

% % cornerLinearSolutionManyImages













