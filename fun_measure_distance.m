
function [measured_distances] = ...
   fun_measure_distance(argFiles, argMeasurementFile, argSquareSize)

%fprintf("\nBEGIN: fun_measure_distance(%s, %d, %s)\n", ...
%   argFiles{:}, argSelectedIndex, argSquareSize);

fprintf("\nBEGIN: fun_measure_distance(file_array, %s, %s)\n", ...
   argMeasurementFile, argSquareSize);

if exist(argMeasurementFile, 'file') ~= 2
   error('input file does not exist');
   return;
elseif (isnan(str2double(argSquareSize)))
   error('SquareSize argument (%s) must be an integer', argSquareSize);
   return;
%elseif (argSelectedIndex > length(argFiles))
%   error('Selected Index (%s) is invalid', argSelectedIndex);
%   return;
else
   fprintf('going to process images');
end

files=argFiles;
%file_to_process = argFiles{argSelectedIndex};
file_to_process = argMeasurementFile;
squareSize=str2num(argSquareSize);

file_result='results.txt';
fileID = fopen(file_result, 'w');

fprintf("\nfile_to_process is %s\n", file_to_process);

%numImages = 22;
%files = cell(1, numImages);
%for i = 1:numImages
%    files{i} = fullfile('d:\','work','matlab', 'tez', '_md', 'rgbdist', sprintf('rgb%d.png', i));
%end

% homogeneous transformation matrix predefined
fprintf(fileID, "\nhomogeneous transformation matrix (RGB -> IR)\n");
htm_rgb2ir=[1.0000, 0.0032, 0.0004, -25.4961;...
			-0.0032, 1.0000, 0.0075, -1.1101;...
			-0.0004, -0.0075, 1.0000, 3.3304;...
			0, 0, 0, 1];
fprintf (fileID, "%f ", htm_rgb2ir.');
%disp(htm_rgb2ir);

magnification = 100;
I = imread(files{1}); %Read one of them
%figure; imshow(I, 'InitialMagnification', magnification);
%title('One of the Calibration Images');

% Detect the checkerboard corners in the images.
[imagePoints, boardSize] = detectCheckerboardPoints(files);

% Generate the world coordinates of the checkerboard corners in the
% pattern-centric coordinate system, with the upper-left corner at (0,0).
%squareSize = 34; % in millimeters
worldPoints = generateCheckerboardPoints(boardSize, squareSize);

% Calibrate the camera.
imageSize = [size(I, 1), size(I, 2)];
cameraParams = estimateCameraParameters(imagePoints, worldPoints, 'ImageSize', imageSize);

fprintf(fileID, "\nCamera Parameters:\n");
%diary "results.txt";
disp(cameraParams);
%diary off;
fprintf(fileID, "\n\nCamera Intrinsics");
fprintf(fileID, "\nIntrinsicMatrix:\n");
fprintf(fileID, "%f ", cameraParams.IntrinsicMatrix.');
fprintf(fileID, "\nFocalLength: ");
fprintf(fileID, "%f ", cameraParams.FocalLength.');
fprintf(fileID, "\nPrincipalPoint: ");
fprintf(fileID, "%f ", cameraParams.PrincipalPoint.');
fprintf(fileID, "\nSkew: %0.3f", cameraParams.Skew);
fprintf(fileID, "\nRadialDistortion: ");
fprintf(fileID, "%0.4f ", cameraParams.RadialDistortion.');
fprintf(fileID, "\nTangentialDistortion: ");
fprintf(fileID, "%0.4f ", cameraParams.TangentialDistortion.');
fprintf(fileID, "\nImageSize: ");
fprintf(fileID, "%d ", cameraParams.ImageSize.');
fprintf(fileID, "\n\nCamera Extrinsics ");
fprintf(fileID, "\nRotationMatrices: ");
fprintf(fileID, "%d ", size(cameraParams.RotationMatrices).');
fprintf(fileID, "matrix\nTranslationVectors: ");
fprintf(fileID, "%d ", size(cameraParams.TranslationVectors).');

fprintf(fileID, "matrix\n\nAccuracy of Estimation");
fprintf(fileID, "\nMeanReprojectionError: %0.3f", cameraParams.MeanReprojectionError);
fprintf(fileID, "\nReprojectionErrors: ");
fprintf(fileID, "%d ", size(cameraParams.ReprojectionErrors).');
fprintf(fileID, "matrix\nReprojectedPoints: ");
fprintf(fileID, "%d ", size(cameraParams.ReprojectedPoints).');

fprintf(fileID, "matrix\n\nCalibration Settings");
fprintf(fileID, "\nNumPatterns: %d", cameraParams.NumPatterns);
fprintf(fileID, "\nWorldUnits: %s", cameraParams.WorldUnits);
fprintf(fileID, "\nWorldPoints: ");
fprintf(fileID, "%d ", size(cameraParams.WorldPoints).');
fprintf(fileID, "matrix\nEstimateSkew: %d", cameraParams.EstimateSkew);
fprintf(fileID, "\nNumRadialDistortionCoefficients: %d",...
   cameraParams.NumRadialDistortionCoefficients);
fprintf(fileID, "\nEstimateTangentialDistortion: %d\n", ...
   cameraParams.EstimateTangentialDistortion);

% Read input image
%imOrig = imread(fullfile('d:\','work','matlab', 'tez', '_md', 'rgbdist', 'rgb23.png'));
imOrig = imread(file_to_process);
figure; imshow(imOrig, 'InitialMagnification', magnification);
title('Input Image');

% Since the lens introduced little distortion, use 'full' output view to illustrate that
% the image was undistored. If we used the default 'same' option, it would be difficult
% to notice any difference when compared to the original image. Notice the small black borders.
[im, newOrigin] = undistortImage(imOrig, cameraParams, 'OutputView', 'full');
figUndistorted = figure;
imshow(im, 'InitialMagnification', magnification);
title('Undistorted Input Image');

% Detect the checkerboard.
[imagePoints, boardSize] = detectCheckerboardPoints(im);

% Adjust the imagePoints so that they are expressed in the coordinate system
% used in the original image, before it was undistorted.  This adjustment
% makes it compatible with the cameraParameters object computed for the original image.
imagePoints = imagePoints + newOrigin; % adds newOrigin to every row of imagePoints

% Compute rotation and translation of the camera.
[R, t] = extrinsics(imagePoints, worldPoints, cameraParams);
fprintf (fileID, "\n\nRotation:\n");
fprintf (fileID, "%f ", R.');
fprintf (fileID, "\n\nTranslation:\n");
fprintf (fileID, "%f ", t.');

% find homogeneous transformation matrix from world to camera
htm_w2c = rotm2tform(R);
tm_w2c= [t, 1];
htm_w2c(:,4) = tm_w2c;
fprintf (fileID, "\n\nHomogeneous transformation matrix from world to camera:\n");
fprintf (fileID, "%f ", htm_w2c.');

% Compute cameraLocation
[~, cameraLocation] = extrinsicsToCameraPose(R, t);
fprintf (fileID, "\n\nCameraLocation:\n", cameraLocation);
fprintf (fileID, "%f ", cameraLocation.');

% get image points via mouse click
[xpts, ypts] = getpts(figUndistorted);
pts = [xpts, ypts];
disp(pts);
numOfPts = size(pts,1);
%extraDim = zeros(numOfPts, 1);
%pts = [pts extraDim];
pts_int = int32(pts);
fprintf (fileID, "\n\nNumber of pts is %d, Clicked Image Points are:\n", numOfPts);
fprintf (fileID, "%d \n", pts_int.');
%disp(pts_int);

% Compute the distance to the camera.
fprintf (fileID, "\nGoing to measure distances.\n");

measured_distances=zeros(numOfPts, 3);

for i = 1:numOfPts
	%ptWorld = pts(i,:, :);
	
	measured_distances(i, 1) = pts_int(i,1);
	measured_distances(i, 2) = pts_int(i,2);

	% Convert to world coordinates.
	%ptWorld = pointsToWorld(cameraParams, R, t, pts(i,:));
    ptWorld = pointsToWorld(cameraParams, R, t, pts_int(i,:));
	% Remember to add the 0 z-coordinate.
	ptWorld = [ptWorld, 0];

    %fprintf (fileID, "\npt %d is %s", i , pts_int(i,:));
	fprintf (fileID, "\n\n\npt %d is ", i);
    disp(pts_int(i,:));
	fprintf (fileID, "%d ", pts_int(i,:).');
    fprintf (fileID, "\nWorld Coordinates are:\n");
	fprintf (fileID, "%f ", ptWorld.');
    %disp(ptWorld);
    distanceToCamera = norm(ptWorld - cameraLocation);
    fprintf(fileID, '\n\nDistance from the camera is %0.3f mm', distanceToCamera);
	
	ptWorldHg=[ptWorld, 1];
	ptWorldHgTranspose=transpose(ptWorldHg);
	ptWorldInRgbCam = htm_w2c * ptWorldHgTranspose;
	fprintf(fileID, '\n\nWorld point in RGB camera coordinate system:\n', ptWorldInRgbCam);
	fprintf (fileID, "%f ", ptWorldInRgbCam.');
	
	ptWorldInIrCam = htm_rgb2ir * ptWorldInRgbCam;
	fprintf(fileID, '\n\nWorld point in IR camera coordinate system:\n', ptWorldInIrCam);
	fprintf (fileID, "%f ", ptWorldInIrCam.');
	
	%ptWorldInRgbCam =  ptWorldHg * htm_w2c;
	%fprintf('Postmultiply: world point in RGB camera coordinate system\n');
	%disp(ptWorldInRgbCam);
	measured_distances(i, 3) = distanceToCamera;
end

fclose(fileID);

fprintf ("\nDistances are:\n");
for i = 1:numOfPts
fprintf ("X:%d Y:%d\tDepth: %0.4f\n", measured_distances(i, 1), ...
   measured_distances(i, 2), measured_distances(i, 3));
end


fprintf("\nEND: fun_measure_distance\n");

%if (3 < 5)
%disp("END"); 
%return;
%end

return;

end