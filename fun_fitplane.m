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
%    point_positions     -> Original Depth Data of x y z point triples, i.e. a (:, 3) matrix
%    img_width           -> Depth Image Width, typically 640 for Kinect v1
%    img_height          -> Depth Image Height, typically 480 for Kinect v1
%    roi_min_max_matrix  -> A 3x2 Matrix that represents a region of interest for which
%                           evaluations of plane fitting would take place.
%    plane_max_distance  -> Maximum distance from an inlier point to the plane, a scalar value.
%
% Output Values:
%    plmdl    -> Fitted plane model of original depth data
%    rmse     -> Root mean square error of residual values of original depth data
%    center_line_residuals  -> Roi area residuals of original depth data
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

   fileID = fopen('res_data.txt', 'w');
   fprintf ("roi_matrix is\n");
   fprintf ("%i ", roi_min_max_vector.');
   fprintf ("\nroi_matrix, x: min %d, max %d\n", roi_x_min, roi_x_max);
   fprintf ("\nroi_matrix, y: min %d, max %d\n", roi_y_min, roi_y_max);
   fprintf ("roi_matrix x len is %d, y len is %d\n", roi_x_len, roi_y_len);
   
   point_cloud = pointCloud(point_positions);
   
   figure;
   pcshow(point_cloud);
   xlabel('X(px)');
   ylabel('Y(px)');
   zlabel('Z(mm)');
   title('Orjinal Nokta Bulutu');
   
   %plane_max_distance = 0.05; %5 cm
   %referenceVector = [0,0,1];
   %maxAngularDistance = 5;
   
   %--------------------------------------------------------------------------
   %------------------ Original Data Processing ------------------------------
   roi = [roi_x_min, roi_x_max; roi_y_min, roi_y_max; roi_z_min, roi_z_max];
   
   sampleIndicesOrgData = findPointsInROI(point_cloud, roi); 
   [fittedPlaneModelOrgData, inlierIndices, outlierIndices] = ...
	  pcfitplane(point_cloud, plane_max_distance, 'SampleIndices', sampleIndicesOrgData);
   plmdl = fittedPlaneModelOrgData;
   pointCloudNearPlaneOrgData = select(point_cloud, inlierIndices);
  
   x_plmdl_org = fittedPlaneModelOrgData.Parameters(1);
   y_plmdl_org = fittedPlaneModelOrgData.Parameters(2);
   z_plmdl_org = fittedPlaneModelOrgData.Parameters(3);
   delta_val_plmdl_org = fittedPlaneModelOrgData.Parameters(4);

   %fprintf ("\nOrg Data fitted plane model parameters are\n\t");
   %fprintf ("%f ", fittedPlaneModelOrgData.Parameters);
   
   %--------------------------------------------------------------------------
   %------------------ Draw figures ------------------------------------------
   
   figure;
   pcshow(pointCloudNearPlaneOrgData);
   title('Orjinal Veri icin en uygun duzlem');
   hold on;
   plot(fittedPlaneModelOrgData);
   hold off;
   
   %[~, ~, ~, meanError] = pcfitplane(ptCloud, maxDistance);
   %fprintf ("\nMean Error is %f\n", meanError);
   
   %--------------------------------------------------------------------------
   %------------------ Compute Diff and rmse for both ------------------------
   
   FITTED_ORG=zeros(img_height, img_width);
   REAL_TO_FITTED_ORG_DIFF=zeros(img_height, img_width); %diff between real and fitted
   SELECTED_TO_FITTED_ORG_DIFF=zeros(roi_y_len, roi_x_len); %diff between selected and fitted
   
   colIndex = 3;
   diffBtwRealDepthAndFitted = 0;
   sumOfSqOfDiffsBtwDepthAndFitted = 0;
   
   sumResidualReal=0;

   for i = 1:img_height
      for j = 1:img_width
   
         rowIndex = (i - 1) * img_width + j;
      
	     if (i >= roi_y_min && i <= roi_y_max ...
	        && j >= roi_x_min && j <= roi_x_max)
		 
		    FITTED_ORG(i, j) = (x_plmdl_org * j + y_plmdl_org * i + delta_val_plmdl_org ) / z_plmdl_org;
			FITTED_ORG(i, j) = abs(FITTED_ORG(i, j));
			
		    if (point_positions(rowIndex, colIndex) ~= 0)
			   diffBtwRealDepthAndFitted = FITTED_ORG(i, j) - point_positions(rowIndex, colIndex);
		       %REAL_TO_FITTED_ORG_DIFF(i, j) = diffBtwRealDepthAndFitted;
		    else
			   diffBtwRealDepthAndFitted = 0;
		    end
		 
		    row_index_stfdiff = i - roi_y_min + 1;
            col_index_stfdiff = j - roi_x_min + 1;
		 
		    SELECTED_TO_FITTED_ORG_DIFF(row_index_stfdiff, col_index_stfdiff) = diffBtwRealDepthAndFitted;
	     else
	        FITTED_ORG(i, j) = 0;
		    diffBtwRealDepthAndFitted = 0;
	     end

	     REAL_TO_FITTED_ORG_DIFF(i, j) = diffBtwRealDepthAndFitted;
		 sumResidualReal = sumResidualReal + diffBtwRealDepthAndFitted;
		 
		 %sumOfSqOfDiffsBtwDepthAndFitted = sumOfSqOfDiffsBtwDepthAndFitted + ...
	     %   diffBtwRealDepthAndFitted * diffBtwRealDepthAndFitted;
   
	     fprintf(fileID, "%d \t %d \t %d \t %7.4f \t %4.4f \n", ...
			   i, j, point_positions(rowIndex, colIndex), ...
			   FITTED_ORG(i, j), diffBtwRealDepthAndFitted);
      end
   end
   
   center_line_row = int32(roi_y_min + roi_y_len / 2);
   center_line_col = int32(roi_x_min + roi_x_len / 2);
   center_line_residuals = REAL_TO_FITTED_ORG_DIFF(center_line_row, :);
   
   fprintf (fileID, "\ncen row = %d cen col = %d\n", center_line_row, center_line_col);
   fprintf (fileID, "center_line_residuals is\n");
   fprintf (fileID, "%f ", center_line_residuals);
   fprintf (fileID, "\nroi_matrix is\n");
   fprintf (fileID, "%i ", roi_min_max_vector.');
   fprintf (fileID, "\nroi_matrix, x: min %d, max %d\n", roi_x_min, roi_x_max);
   fprintf (fileID, "\nroi_matrix, y: min %d, max %d\n", roi_y_min, roi_y_max);
   fprintf (fileID, "roi_matrix x len is %d, y len is %d\n", roi_x_len, roi_y_len);
   
   fprintf ("\nOrg Data fitted plane model parameters are\n\t");
   fprintf ("%f ", fittedPlaneModelOrgData.Parameters);
    
   %compute for real to fitted diff matrix
   SQE = REAL_TO_FITTED_ORG_DIFF.^2;
   MSE = mean(SQE(:));
   SDEV = std(REAL_TO_FITTED_ORG_DIFF(:));
   fprintf ("\nOriginal Depth Residuals\n\t; mse %f, rmse %f, std_dev: %f", MSE, sqrt(MSE), SDEV);
   fprintf (fileID, "\nOriginal Depth Residuals\n\t; mse %f, rmse %f, std_dev: %f", MSE, sqrt(MSE), SDEV);
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
   imagesc(REAL_TO_FITTED_ORG_DIFF);
   title('Duzlem artik degerleri');

   subplot(1,2,2);
   %figure;
   imagesc(SELECTED_TO_FITTED_ORG_DIFF);
   title('Secili alanda artik degerler');
   movegui(gcf,'center');
   
   
   return;
end

