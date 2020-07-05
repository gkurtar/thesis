%-----------------------------------------------------------------------------
% This function fits a plane for input 3d point position set.
% After fitting plane, corresponding residual values are found and
% rmse values are calculated. Corresponding figures, such as 
% original point cloud, fitted plane and residual values
% would be displayed also.
%
% It returns fitting plane model object and corresponding rmse value
% for input points as well as residuals of the center horizontal row of the roi
%
% Input Arguments:
%    point_positions     -> Depth Data of x y z point triples, i.e. a (:, 3) matrix
%    img_width           -> Depth Image Width, typically 640 for Kinect v1
%    img_height          -> Depth Image Height, typically 480 for Kinect v1
%    roi_min_max_matrix  -> A 3x2 Matrix that represents a region of interest for which
%                           evaluations of plane fitting would take place.
%    plane_max_distance  -> Maximum distance from an inlier point to the plane, a scalar value.
%
% Output Values:
%    plmdl                 -> Fitted plane model of depth data
%    rmse                  -> Root mean square error of residual values of depth data
%    center_line_residuals -> Roi area residuals of depth data
%
%-------------------------------------------------------------------------------
function [plmdl, rmse, center_line_residuals] = fun_fitplane(...
      point_positions, img_width, img_height, roi_min_max_vector, plane_max_distance)

   roi_x_min = roi_min_max_vector(1);  %(1, 1);
   roi_x_max = roi_min_max_vector(2);
   roi_y_min = roi_min_max_vector(3);
   roi_y_max = roi_min_max_vector(4);
   roi_z_min = roi_min_max_vector(5);
   roi_z_max = roi_min_max_vector(6);
   
   roi_x_len = roi_x_max - roi_x_min;
   roi_y_len = roi_y_max - roi_y_min;

   fileID = fopen('result_depth_analysis.txt', 'w');
   fprintf(fileID, "===========================================\n");
   fprintf(fileID, "Height Index\tWidth Index\tDepth Value\tFitted Data\tDifference\n");
   fprintf(fileID, "===========================================\n");
   
   fprintf ("roi_matrix is\n");
   fprintf ("%i ", roi_min_max_vector.');
   %fprintf ("\nroi_matrix, x: min %d, max %d\n", roi_x_min, roi_x_max);
   %fprintf ("y: min %d, max %d", roi_y_min, roi_y_max);
   fprintf ("\nroi_matrix x len is %d, y len is %d\n", roi_x_len, roi_y_len);
   
   point_cloud = pointCloud(point_positions);
   
   figure;
   pcshow(point_cloud);
   xlabel('X(px)');
   ylabel('Y(px)');
   zlabel('Z(mm)');
   title('Derinlik Verisi Nokta Bulutu');
   
   %plane_max_distance = 0.05; %5 cm
   %referenceVector = [0,0,1];
   %maxAngularDistance = 5;
   
   %--------------------------------------------------------------------------
   %------------------ Original Data Processing ------------------------------
   roi = [roi_x_min, roi_x_max; roi_y_min, roi_y_max; roi_z_min, roi_z_max];
   
   sampleIndicesOfData = findPointsInROI(point_cloud, roi); 
   [fittedPlaneModelData, inlierIndices, outlierIndices] = ...
	  pcfitplane(point_cloud, plane_max_distance, 'SampleIndices', sampleIndicesOfData);
   plmdl = fittedPlaneModelData;
   pointCloudNearPlane = select(point_cloud, inlierIndices);
  
   x_plmdl = fittedPlaneModelData.Parameters(1);
   y_plmdl = fittedPlaneModelData.Parameters(2);
   z_plmdl = fittedPlaneModelData.Parameters(3);
   delta_val_plmdl = fittedPlaneModelData.Parameters(4);

   %fprintf ("\nFitted plane model parameters are\n\t");
   %fprintf ("%f ", fittedPlaneModelData.Parameters);
   
   %--------------------------------------------------------------------------
   %------------------ Draw figures ------------------------------------------
   
   figure;
   pcshow(pointCloudNearPlane);
   title('Derinlik verisi icin en uygun duzlem');
   hold on;
   plot(fittedPlaneModelData);
   hold off;
   
   %[~, ~, ~, meanError] = pcfitplane(ptCloud, maxDistance);
   %fprintf ("\nMean Error is %f\n", meanError);
   
   %--------------------------------------------------------------------------
   %------------------ Compute Diff and rmse for both ------------------------
   
   FITTED_DATA=zeros(img_height, img_width);
   REAL_TO_FITTED_DIFF=zeros(img_height, img_width); %diff between real and fitted
   SELECTED_TO_FITTED_DIFF=zeros(roi_y_len, roi_x_len); %diff between selected and fitted
   
   colIndex = 3;
   diffBtwRealDepthAndFitted = 0;
   sumOfSqOfDiffsBtwDepthAndFitted = 0;
   
   sumResidualReal=0;

   for i = 1:img_height
      for j = 1:img_width
   
         rowIndex = (i - 1) * img_width + j;
      
	     if (i >= roi_y_min && i <= roi_y_max ...
	        && j >= roi_x_min && j <= roi_x_max)
		 
		    FITTED_DATA(i, j) = (x_plmdl * j + y_plmdl * i + delta_val_plmdl ) / z_plmdl;
			FITTED_DATA(i, j) = abs(FITTED_DATA(i, j));
			
		    if (point_positions(rowIndex, colIndex) ~= 0)
			   diffBtwRealDepthAndFitted = FITTED_DATA(i, j) - point_positions(rowIndex, colIndex);
		       %REAL_TO_FITTED_DIFF(i, j) = diffBtwRealDepthAndFitted;
		    else
			   diffBtwRealDepthAndFitted = 0;
		    end
		 
		    row_index_stfdiff = i - roi_y_min + 1;
            col_index_stfdiff = j - roi_x_min + 1;
		 
		    SELECTED_TO_FITTED_DIFF(row_index_stfdiff, col_index_stfdiff) = diffBtwRealDepthAndFitted;
	     else
	        FITTED_DATA(i, j) = 0;
		    diffBtwRealDepthAndFitted = 0;
	     end

	     REAL_TO_FITTED_DIFF(i, j) = diffBtwRealDepthAndFitted;
		 sumResidualReal = sumResidualReal + diffBtwRealDepthAndFitted;
		 
		 %sumOfSqOfDiffsBtwDepthAndFitted = sumOfSqOfDiffsBtwDepthAndFitted + ...
	     %   diffBtwRealDepthAndFitted * diffBtwRealDepthAndFitted;
   
	     fprintf(fileID, "%d \t %d \t %d \t %7.4f \t %4.4f \n", ...
			   i, j, point_positions(rowIndex, colIndex), ...
			   FITTED_DATA(i, j), diffBtwRealDepthAndFitted);
      end
   end
   
   center_line_row = int32(roi_y_min + roi_y_len / 2);
   center_line_col = int32(roi_x_min + roi_x_len / 2);
   center_line_residuals = REAL_TO_FITTED_DIFF(center_line_row, :);
   
   fprintf (fileID, "\ncen row = %d cen col = %d\n", center_line_row, center_line_col);
   fprintf (fileID, "center_line_residuals is\n");
   fprintf (fileID, "%f ", center_line_residuals);
   fprintf (fileID, "\nroi_matrix is\n");
   fprintf (fileID, "%i ", roi_min_max_vector.');
   fprintf (fileID, "\nroi_matrix, x: min %d, max %d\n", roi_x_min, roi_x_max);
   fprintf (fileID, "\nroi_matrix, y: min %d, max %d\n", roi_y_min, roi_y_max);
   fprintf (fileID, "roi_matrix x len is %d, y len is %d\n", roi_x_len, roi_y_len);
   
   fprintf ("\nDepth Data fitted plane model parameters are\n\t");
   fprintf ("%f ", fittedPlaneModelData.Parameters);
    
   %compute for real to fitted diff matrix
   SQE = REAL_TO_FITTED_DIFF.^2;
   MSE = mean(SQE(:));
   SDEV = std(REAL_TO_FITTED_DIFF(:));
   fprintf ("\nDepth Residuals\n\t; mse %f, rmse %f, std_dev: %f", MSE, sqrt(MSE), SDEV);
   fprintf (fileID, "\nDepth Residuals\n\t; mse %f, rmse %f, std_dev: %f", MSE, sqrt(MSE), SDEV);
   rmse = sqrt(MSE);

   %msqe_depth = sumOfSqOfDiffsBtwDepthAndFitted / (img_width * img_height);
   %fprintf ("\n\n\n\nOriginal Depth; sum of sq %f, mean square %f, rmse %f", ...
   %   sumOfSqOfDiffsBtwDepthAndFitted, msqe_depth, sqrt(msqe_depth));

   fclose(fileID);
   fprintf ("\nfitted plane and depth diffs are shown.\n");

   %--------------------------------------------------------------------------
   %------------------ Draw figures ------------------------------------------

   figure('position', [0, 0, 900, 360])
   subplot(1,2,1);
   imagesc(REAL_TO_FITTED_DIFF);
   title('Duzlem artik degerleri');

   subplot(1,2,2);
   %figure;
   imagesc(SELECTED_TO_FITTED_DIFF);
   title('Secili alanda artik degerler');
   movegui(gcf,'center');
   
   
   return;
end