%-----------------------------------------------------------------------------
% This function fits a plane for two different 3d point position set.
% After fitting plane, corresponding residual values are found and
% rmse values are calculated. Corresponding figures, such as original
% and calibrated point clouds, fitted planes and residual values
% would be displayed also.
%
% It returns fitting plane model object and corresponding rmse value
% for both set of points
%
% Input Arguments:
%    point_positions     -> Original Depth Data of x y z point triples, i.e. a (:, 3) matrix
%    cal_point_positions -> Calibrated Depth Data of x y z point triples, i.e. a (:, 3) matrix
%    img_width           -> Depth Image Width, typically 640 for Kinect v1
%    img_height          -> Depth Image Height, typically 480 for Kinect v1
%    roi_min_max_matrix  -> A 3x2 Matrix that represents a region of interest for which
%                           evaluations of plane fitting would take place.
%    plane_max_distance  -> Maximum distance from an inlier point to the plane, a scalar value.
%
% Output Values:
%    plmdl_org    -> Fitted plane model of original depth data
%    rmse_org     -> Root mean square error of residual values of original depth data
%    plmdl_cal    -> Fitted plane model of calibrated depth data
%    rmse_cal     -> Root mean square error of residual values of calibrated depth data
%
%-------------------------------------------------------------------------------
function [plmdl_org, rmse_org, plmdl_cal, rmse_cal] = fun_find_fitplane_and_rmse(...
   point_positions, cal_point_positions, img_width, img_height, ...
   roi_min_max_vector, plane_max_distance)

   roi_x_min = roi_min_max_vector(1);  %(1, 1);
   roi_x_max = roi_min_max_vector(2);
   roi_y_min = roi_min_max_vector(3);
   roi_y_max = roi_min_max_vector(4);
   roi_z_min = roi_min_max_vector(5);
   roi_z_max = roi_min_max_vector(6);
   
   roi_x_len = roi_x_max - roi_x_min;
   roi_y_len = roi_y_max - roi_y_min;

   fprintf ("roi_matrix is\n");
   fprintf ("%i ", roi_min_max_vector.');
   fprintf ("\nroi_matrix, x: min %d, max %d\n", roi_x_min, roi_x_max);
   fprintf ("roi_matrix x len is %d, y len is %d\n", roi_x_len, roi_y_len);
   
   %figure;
   figure('position', [0, 0, 600, 450])
   subplot(1,2,1);
   point_cloud = pointCloud(point_positions);
   pcshow(point_cloud);
   xlabel('X(m)');
   ylabel('Y(m)');
   zlabel('Z(m)');
   title('Orjinal Nokta Bulutu');
   
   subplot(1,2,2);
   cal_point_cloud = pointCloud(cal_point_positions);
   %figure;
   pcshow(cal_point_cloud);
   xlabel('X(m)');
   ylabel('Y(m)');
   zlabel('Z(m)');
   title('Kalibre Nokta Bulutu');
   
   movegui(gcf,'center');
   
   %plane_max_distance = 0.05; %5 cm
   %referenceVector = [0,0,1];
   %maxAngularDistance = 5;
   
   %--------------------------------------------------------------------------
   %------------------ Original Data Processing ------------------------------
   roi = [roi_x_min, roi_x_max; roi_y_min, roi_y_max; roi_z_min, roi_z_max];
   
   sampleIndicesOrgData = findPointsInROI(point_cloud, roi); 
   [fittedPlaneModelOrgData, inlierIndices, outlierIndices] = ...
	  pcfitplane(point_cloud, plane_max_distance, 'SampleIndices', sampleIndicesOrgData);
   plmdl_org = fittedPlaneModelOrgData;
   pointCloudNearPlaneOrgData = select(point_cloud, inlierIndices);
  
   x_plmdl_org = fittedPlaneModelOrgData.Parameters(1);
   y_plmdl_org = fittedPlaneModelOrgData.Parameters(2);
   z_plmdl_org = fittedPlaneModelOrgData.Parameters(3);
   delta_val_plmdl_org = fittedPlaneModelOrgData.Parameters(4);

   fprintf ("\nOrg Data fitted plane model parameters are\n\t");
   fprintf ("%f ", fittedPlaneModelOrgData.Parameters);
   %disp(fittedPlaneModelOrgData.Parameters);
 
   %--------------------------------------------------------------------------
   %------------------ Calibrated Data Processing ----------------------------
   sampleIndicesCalData = findPointsInROI(cal_point_cloud, roi); 
   [fittedPlaneModelCalData, inlierIndices, outlierIndices] = ...
	  pcfitplane(cal_point_cloud, plane_max_distance, 'SampleIndices', sampleIndicesCalData);
   plmdl_cal = fittedPlaneModelCalData;
   pointCloudNearPlaneCalData = select(cal_point_cloud, inlierIndices);
   
   x_plmdl_cal = fittedPlaneModelCalData.Parameters(1);
   y_plmdl_cal = fittedPlaneModelCalData.Parameters(2);
   z_plmdl_cal = fittedPlaneModelCalData.Parameters(3);
   delta_val_plmdl_cal = fittedPlaneModelCalData.Parameters(4);
  
   fprintf ("\nCal Data fitted plane model parameters are\n\t");
   fprintf ("%f ", fittedPlaneModelCalData.Parameters);
   %disp(fittedPlaneModelCalData.Parameters);
   
   %--------------------------------------------------------------------------
   %------------------ Draw figures ------------------------------------------
   %figure('position', [0, 0, 900, 500])
   %subplot(1, 2, 1);
   figure;
   pcshow(pointCloudNearPlaneOrgData);
   title('Orjinal Veri icin en uygun duzlem');
   hold on;
   plot(fittedPlaneModelOrgData);
   hold off;
   
   figure;
   %subplot(1, 2, 2);
   pcshow(pointCloudNearPlaneCalData);
   title('Kalibre edilmis veri icin en uygun duzlem ');
   hold on
   plot(fittedPlaneModelCalData);
   hold off
   
   %movegui(gcf,'center');
   %[~, ~, ~, meanError] = pcfitplane(ptCloud, maxDistance);
   %fprintf ("\nMean Error is %f\n", meanError);
   
   %--------------------------------------------------------------------------
   %------------------ Compute Diff and rmse for both ------------------------
   
   fileID = fopen('res_data.txt', 'w');
   FITTED_ORG=zeros(img_height, img_width);
   REAL_TO_FITTED_ORG_DIFF=zeros(img_height, img_width); %diff between real and fitted
   SELECTED_TO_FITTED_ORG_DIFF=zeros(roi_y_len, roi_x_len); %diff between selected and fitted
   
   FITTED_CAL=zeros(img_height, img_width);
   REAL_TO_FITTED_CAL_DIFF=zeros(img_height, img_width); %diff between real and fitted
   SELECTED_TO_FITTED_CAL_DIFF=zeros(roi_y_len, roi_x_len); %diff between selected and fitted

   colIndex = 3;
   diffBtwRealDepthAndFitted = 0;
   diffBtwCalDepthAndFitted = 0;
   sumOfSqOfDiffsBtwDepthAndFitted = 0;
   sumOfSqOfDiffsBtwCalDepthAndFitted = 0;
   
   sumResidualReal=0;

   for i = 1:img_height
      for j = 1:img_width
   
         rowIndex = (i - 1) * img_width + j;
      
	     if (i >= roi_y_min && i <= roi_y_max ...
	        && j >= roi_x_min && j <= roi_x_max)
		 
		    FITTED_ORG(i, j) = (x_plmdl_org * j + y_plmdl_org * i + delta_val_plmdl_org ) / z_plmdl_org;
			FITTED_ORG(i, j) = abs(FITTED_ORG(i, j));
			
			FITTED_CAL(i, j) = (x_plmdl_cal * j + y_plmdl_cal * i + delta_val_plmdl_cal ) / z_plmdl_cal;
			FITTED_CAL(i, j) = abs(FITTED_CAL(i, j));

		    if (point_positions(rowIndex, colIndex) ~= 0)
			   diffBtwRealDepthAndFitted = FITTED_ORG(i, j) - point_positions(rowIndex, colIndex);
		       %REAL_TO_FITTED_ORG_DIFF(i, j) = diffBtwRealDepthAndFitted;
			   diffBtwCalDepthAndFitted = FITTED_CAL(i, j) - cal_point_positions(rowIndex, colIndex);
		    else
			   diffBtwRealDepthAndFitted = 0;
			   diffBtwCalDepthAndFitted = 0;
		    end
		 
		    row_index_stfdiff = i - roi_y_min + 1;
            col_index_stfdiff = j - roi_x_min + 1;
		 
		    SELECTED_TO_FITTED_ORG_DIFF(row_index_stfdiff, col_index_stfdiff) = diffBtwRealDepthAndFitted;
			SELECTED_TO_FITTED_CAL_DIFF(row_index_stfdiff, col_index_stfdiff) = diffBtwCalDepthAndFitted;
	     else
	        FITTED_ORG(i, j) = 0;
			FITTED_CAL(i, j) = 0;
		    diffBtwRealDepthAndFitted = 0;
			diffBtwCalDepthAndFitted = 0;
	     end

	     REAL_TO_FITTED_ORG_DIFF(i, j) = diffBtwRealDepthAndFitted;
		 REAL_TO_FITTED_CAL_DIFF(i, j) = diffBtwCalDepthAndFitted;
		 
		 sumResidualReal = sumResidualReal + diffBtwRealDepthAndFitted;
		 
		 %sumOfSqOfDiffsBtwDepthAndFitted = sumOfSqOfDiffsBtwDepthAndFitted + ...
	     %   diffBtwRealDepthAndFitted * diffBtwRealDepthAndFitted;	
	     %sumOfSqOfDiffsBtwCalDepthAndFitted = sumOfSqOfDiffsBtwCalDepthAndFitted + ...
	     %   diffBtwCalDepthAndFitted * diffBtwCalDepthAndFitted;
   
	     fprintf(fileID, "%d \t %d \t %d \t %d \t %7.4f \t %4.2f \t %7.4f \t %4.2f \n", ...
			   i, j, point_positions(rowIndex, colIndex), cal_point_positions(rowIndex, colIndex), ...
			   FITTED_ORG(i, j), diffBtwRealDepthAndFitted, FITTED_CAL(i, j), diffBtwCalDepthAndFitted);
      end
   end
   
   %compute for real to fitted diff matrix
   SQE = REAL_TO_FITTED_ORG_DIFF.^2;
   MSE = mean(SQE(:));
   SDEV = std(REAL_TO_FITTED_ORG_DIFF(:));
   fprintf ("\nOriginal Depth Residuals\n\t; mse %f, rmse %f, std_dev: %f", MSE, sqrt(MSE), SDEV);

   %compute for calibrated to fitted diff matrix
   SQE  = REAL_TO_FITTED_CAL_DIFF.^2;
   MSE  = mean(SQE(:));
   SDEV = std(REAL_TO_FITTED_CAL_DIFF(:));
   fprintf ("\n\nCalibrated Depth Residuals\n\t; mse %f, rmse %f, std_dev: %f", MSE, sqrt(MSE), SDEV);

   %msqe_depth = sumOfSqOfDiffsBtwDepthAndFitted / (img_width * img_height);
   %fprintf ("\n\n\n\nOriginal Depth; sum of sq %f, mean square %f, rmse %f", ...
   %   sumOfSqOfDiffsBtwDepthAndFitted, msqe_depth, sqrt(msqe_depth));
	  
   %msqe_cal_depth = sumOfSqOfDiffsBtwCalDepthAndFitted / (img_width * img_height);
   %fprintf ("\n\nCalibrated Depth; sum of sq %f, mean square %f, rmse %f ", ...
   %   sumOfSqOfDiffsBtwCalDepthAndFitted, msqe_cal_depth, sqrt(msqe_cal_depth));

   fclose(fileID);
   fprintf ("\nfitted plane and depth diffs are shown.\n");

   %--------------------------------------------------------------------------
   %------------------ Draw figures ------------------------------------------

   figure('position', [0, 0, 900, 360])
   subplot(1,2,1);
   imagesc(REAL_TO_FITTED_ORG_DIFF);
   title('Orjinal veriye uygun duzlem artik degerleri');

   subplot(1,2,2);
   imagesc(REAL_TO_FITTED_CAL_DIFF);
   title('Kalibre veriye uygun duzlem artik degerleri');
   movegui(gcf,'center');


   %figure;
   figure('position', [0, 0, 820, 360])
   subplot(1,2,1);
   imagesc(SELECTED_TO_FITTED_ORG_DIFF);
   title('Orjinal veri icin secili alanda artik degerler');
   
   subplot(1,2,2);
   %figure;
   imagesc(SELECTED_TO_FITTED_CAL_DIFF);
   title('Kalibre veri icin secili alanda artik degerler');
   movegui(gcf,'center');
   
   return;
end

