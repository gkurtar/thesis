% This method draws 2D figure of y-z points for
% the point cloud and distance given as arguments 


roi_matrix_300=[275, 363, 205, 297, 2900, 3100];
roi_matrix_330=[287, 360, 232, 305, 3200, 3400];
roi_matrix_360=[298, 366, 240, 310, 3500, 3700];
roi_matrix_390=[290, 350, 136, 205, 3800, 4000];
roi_matrix_420=[310, 365, 290, 345, 4100, 4300];

roi_matrix_420=[320, 365, 290, 340, 4100, 4300];

roi_matrix=roi_matrix_330;

roi_x_min = roi_matrix(1);
roi_x_max = roi_matrix(2);
roi_y_min = roi_matrix(3);
roi_y_max = roi_matrix(4);
roi_z_min = roi_matrix(5);
roi_z_max = roi_matrix(6);

roi_x_len = roi_matrix(2) - roi_matrix(1);
roi_y_len = roi_matrix(4) - roi_matrix(3);

%str = input('Enter the filename: ', 's');
depthFile = fullfile('d:\', 'work', 'matlab', 'tez', '_noise', 'depth_data', 'Depth_360.txt'); %sprintf('rgb%d.png', i));
depthData = importdata(depthFile);
fprintf("%s file is imported\n", depthFile);

%{
ptCloud = pointCloud(depthData);
figure;
pcshow(ptCloud);
xlabel('X(m)');
ylabel('Y(m)');
zlabel('Z(m)');
title('Orjinal Nokta Bulutu');
%}

DEPTH_VALS=[];
PLANE_COORDS=[];
DIFFS=[];
colIndex = 3;

%if (5 >= 3)
%   return;
%end

for i = 1:480
   for j = 1:640
      rowIndex = (i - 1) * 640 + j;
      
	  if (i >= roi_y_min & i <= roi_y_max & j >= roi_x_min & j <= roi_x_max)
		 
		 fprintf ("i %d, j %d, row %d depth %d \n", i, j, rowIndex, depthData(rowIndex, colIndex));
		 
		 if (depthData(rowIndex, colIndex) ~= 0)
		    DEPTH_VALS = [DEPTH_VALS depthData(rowIndex, colIndex)];
			PLANE_COORDS = [PLANE_COORDS j];
			DIFFS=[DIFFS rand * 2];
		 else
			diffBtwDepthAndFitted = 0;
		 end
		 
	  else
		 diffBtwDepthAndFitted = 0;
	  end
	  
      %fprintf(fileID, "%d \t %d \t %d \t %d \t %f \t %f \n", ...
		%	i, j, rowIndex, depthData(rowIndex, colIndex), FITTED(i, j), diffBtwDepthAndFitted);
   end
end

fprintf ("x_min %d, x_max %d, y_min %d y_max %d \n", roi_x_min, roi_x_max, roi_y_min, roi_y_max);

%PLANE_COORDS = PLANE_COORDS - (roi_x_min + roi_x_len / 2); 

fprintf ("fitted plane and depth diffs are shown.\n");

figure;
%imagesc(REAL_TO_FITTED_DIFF);
%plot(DEPTH_VALS, PLANE_COORDS);
%scatter(DEPTH_VALS, PLANE_COORDS, DIFFS);
scatter(DEPTH_VALS, PLANE_COORDS);
xlabel('Mesafe(mm)');
ylabel('Piksel');
%scatter(DEPTH_VALS(:,1),depthData(:,2), depthData(:,3)- FITTED(3,:),'filled');
title('Duzlem mesafesi 420 cm');

