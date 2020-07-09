
function [cameraParams] = fun_calibrate_rgbir_camera(argFiles, argSquareSize)

   fprintf("\nBEGIN: fun_calibrate_rgbir_camera(calibration_image_files, %s)\n", argSquareSize);

   %fun_calibrate_rgbir_camera(argFiles, argMeasurementFile, argSquareSize)
   %fprintf("\nBEGIN: fun_calibrate_rgbir_camera(file_array, %s, %s)\n", ...
   %   argMeasurementFile, argSquareSize);

   %if exist(argMeasurementFile, 'file') ~= 2
   %   fprintf('input file does not exist');
   %   return;
   %end

   if (isnan(str2double(argSquareSize)))
      fprintf('SquareSize argument (%s) must be an integer', argSquareSize);
      return;
   end

   files=argFiles;
   %file_to_process = argMeasurementFile;
   squareSize=str2num(argSquareSize);
   
   %fprintf("\nfile_to_process is %s\n", file_to_process);

   file_result='results.txt';
   fileID = fopen(file_result, 'w');
   
   I = imread(files{1}); %Read one of them
   %magnification = 100;
   %figure; imshow(I, 'InitialMagnification', magnification);
   %title('One of the Calibration Images');

   % Detect the checkerboard corners in the images.
   [imagePoints, boardSize] = detectCheckerboardPoints(files);

   % Generate the world coordinates of the checkerboard corners in the
   % pattern-centric coordinate system, with the upper-left corner at (0,0).
   worldPoints = generateCheckerboardPoints(boardSize, squareSize);

   % Calibrate the camera.
   imageSize = [size(I, 1), size(I, 2)];
   cameraParams = estimateCameraParameters(imagePoints, worldPoints, 'ImageSize', imageSize);

   fprintf(fileID, "\nCamera Parameters:\n");
   %diary "results.txt";
   disp(cameraParams);
   %diary off;
   fprintf(fileID, "\n\nCamera Intrinsics\nIntrinsicMatrix:\n");
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
   fprintf(fileID, "\nNumRadialDistortionCoefficients: %d", cameraParams.NumRadialDistortionCoefficients);
   fprintf(fileID, "\nEstimateTangentialDistortion: %d\n", cameraParams.EstimateTangentialDistortion);

   %{
   
   % Read input image
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
   
   %}
   
   fclose(fileID);

   fprintf("\nEND: fun_calibrate_rgbir_camera\n");
   return;

end