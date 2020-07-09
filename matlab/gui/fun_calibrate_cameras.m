% ***********************************************************
% TBD
% Corresponding matlab example is used
% 5 Temmuz 2020
% Rev 1:
%
% **********************************************************
function [cameraParams, depthCamParams] = ...
   fun_calibrate_cameras(argFiles, argMeasurementFile, argDepthDataFile, argSquareSize)

   fprintf("\nBEGIN: fun_calibrate_cameras(file_array, %s, %s)\n", ...
      argMeasurementFile, argDepthDataFile, argSquareSize);

   if (exist(argMeasurementFile, 'file') ~= 2)
      fprintf('input file %s does not exist', argMeasurementFile);
      return;
   end
   
   if (exist(argDepthDataFile, 'file') ~= 2)
      fprintf('input file %s does not exist', argDepthDataFile);
      return;
   end

   if (isnan(str2double(argSquareSize)))
      fprintf('SquareSize argument (%s) must be an integer', argSquareSize);
      return;
   end

   %file_to_process = argMeasurementFile;
   squareSize=str2num(argSquareSize);

   file_result='results.txt';
   fileID = fopen(file_result, 'w');
   
   file_detail_name='results_detailed.txt';
   %fprintf("\nfile_to_process is %s\n", argMeasurementFile);

   % homogeneous transformation matrix predefined
   fprintf(fileID, "\nhomogeneous transformation matrix (RGB -> IR)\n");
   htm_rgb2ir=[1.0000, 0.0032, 0.0004, -25.4961;...
			-0.0032, 1.0000, 0.0075, -1.1101;...
			-0.0004, -0.0075, 1.0000, 3.3304;...
			0, 0, 0, 1];
   fprintf (fileID, "%f ", htm_rgb2ir.');

   I = imread(argFiles{1}); %Read one of them and detect size
   %figure; imshow(I, 'InitialMagnification', magnification);%title('One of the Calibration Images');
   imageSize = [size(I, 1), size(I, 2)];

   % Detect the checkerboard corners in the images.
   [imagePoints, boardSize] = detectCheckerboardPoints(argFiles);

   % Generate the world coordinates of the checkerboard corners in the
   % pattern-centric coordinate system, with the upper-left corner at (0,0).
   worldPoints = generateCheckerboardPoints(boardSize, squareSize);

   % Calibrate the camera.
   %imageSize = [size(I, 1), size(I, 2)];
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
   magnification = 100;
   imOrig = imread(argMeasurementFile);
   figure; imshow(imOrig, 'InitialMagnification', magnification);
   title('Input Image');
   
   % Since the lens introduced little distortion, use 'full' output view to illustrate that
   % the image was undistored. If we used the default 'same' option, it would be difficult
   % to notice any difference when compared to the original image. Notice the small black borders.
   [im, newOrigin] = undistortImage(imOrig, cameraParams, 'OutputView', 'full');
   %figUndistorted = figure;
   %imshow(im, 'InitialMagnification', magnification);
   %title('Undistorted Input Image');
   
   [y_size, x_size, z_size] = size(im);
   figUndistorted = figure('Name', 'Undistorted Input Image', 'Toolbar', 'none', 'Menubar', 'none');
   title('Undistorted Input Image');
   hIm = imshow(im);
   hSP = imscrollpanel(figUndistorted, hIm);
   set(hSP,'Units', 'normalized', 'Position',[0 .1 1 .9]);
   % 2. Add a Magnification Box and an Overview tool.
   hMagBox = immagbox(figUndistorted, hIm);
   pos = get(hMagBox,'Position');
   set(hMagBox,'Position', [0 0 pos(3) pos(4)]);
   imoverview(hIm);
   % 3. Get the scroll panel API to programmatically control the view.
   api = iptgetapi(hSP);
   % 4. Get the current magnification and position.
   mag = api.getMagnification();
   r = api.getVisibleImageRect();
   % 5. View the top left corner of the image.
   api.setVisibleLocation(0.5, 0.5);
   % 6. Change the magnification to the value that just fits.
   api.setMagnification(api.findFitMag());
   % 7. Zoom in to 200% on the dark spot.
   api.setMagnificationAndCenter(2, y_size / 2, x_size / 2);
   
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
   fprintf (fileID, "\nNumber of pts is %d", numOfPts);
   %fprintf (fileID, "\nNumber of pts is %d, Clicked Image Points are:\n", numOfPts);
   %fprintf (fileID, "%d \n", pts_int.');
   
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
	fprintf (fileID, "\n\npt %d is ", i);
    %disp(pts_int(i,:));
	fprintf (fileID, " %d ", pts_int(i,:).');
    fprintf (fileID, "\tWorld Coordinates are:");
	fprintf (fileID, "%f ", ptWorld.');
    %disp(ptWorld);
    distanceToCamera = norm(ptWorld - cameraLocation);
    fprintf(fileID, '\nDistance from the camera is %0.3f mm', distanceToCamera);
	
	ptWorldHg=[ptWorld, 1];
	ptWorldHgTranspose=transpose(ptWorldHg);
	ptWorldInRgbCam = htm_w2c * ptWorldHgTranspose;
	fprintf(fileID, '\nWorld point in RGB camera coordinate system: ', ptWorldInRgbCam);
	fprintf (fileID, "%f ", ptWorldInRgbCam.');
	
	ptWorldInIrCam = htm_rgb2ir * ptWorldInRgbCam;
	fprintf(fileID, '\nWorld point in IR camera coordinate system: ', ptWorldInIrCam);
	fprintf (fileID, "%f ", ptWorldInIrCam.');
	
	%ptWorldInRgbCam =  ptWorldHg * htm_w2c;
	%fprintf('Postmultiply: world point in RGB camera coordinate system\n');
	%disp(ptWorldInRgbCam);
	measured_distances(i, 3) = distanceToCamera;
   end
   
   depth_data = importdata(argDepthDataFile);
   original_depth_distances=zeros(numOfPts, 3);

   fprintf ("\nDistances are:\n");
   for i = 1:numOfPts
      fprintf ("X:%d Y:%d\tDepth: %0.4f\t", measured_distances(i, 1), ...
         measured_distances(i, 2), measured_distances(i, 3));
      
	  depth_x_idx = int32(measured_distances(i, 1) / 2);
	  depth_y_idx = int32(measured_distances(i, 2) / 2);
	  
	  point_index = (depth_y_idx - 1) * 640 + depth_x_idx;
	  
      %original_depth_distances(i, 1) = depth_data(point_index, 1);
      %original_depth_distances(i, 2) = depth_data(point_index, 2);
	  %original_depth_distances(i, 3) = depth_data(point_index, 3);
	  
	  original_depth_distances(i, :) = depth_data(point_index, :);
	  
      fprintf(fileID, "Depth Data for the pos (%d, %d) with idx %d is:\t(%d, %d) => %d \n", ...
         depth_x_idx, depth_y_idx, point_index, ...
         depth_data(point_index, 1), depth_data(point_index, 2), ...
         depth_data(point_index, 3));
   end
   
   fprintf(fileID, "\nOriginal_depth_distances\n");
   fprintf(fileID, " %d ", original_depth_distances(:,3).' );
   fprintf(fileID, "\nMeasured_depth_distances\n");
   fprintf(fileID, " %d ", measured_distances(:,3).' );
   
   depthCamParams=fun_calibrate_depth_camera(...
      original_depth_distances(:,3), measured_distances(:,3));
   
   fprintf(fileID, '\n\nDepth Cam Params is: %0.7f %0.7f\n',...
      depthCamParams(1), depthCamParams(2));

   fprintf("\nEND: fun_calibrate_cameras\n");
   fclose(fileID);
   return;
end