% This script invokes fun_fitplane function on a volume
% which is given by an argument 

% xmin, xmax, ymin, ymax, zmin, zmax
roi_matrix_60 =[90, 520, 5, 310, 500, 700];
roi_matrix_90 =[150, 440, 40, 320, 800, 1000];
roi_matrix_120=[205, 420, 110, 325, 1100, 1300];
roi_matrix_150=[210, 385, 150, 330, 1400, 1600];
roi_matrix_180=[237, 385, 182, 325, 1800, 1900];
roi_matrix_210=[245, 375, 210, 335, 2000, 2200];
roi_matrix_240=[243, 353, 230, 340, 2300, 2500];
roi_matrix_270=[268, 363, 244, 334, 2600, 2800];
roi_matrix_300=[275, 363, 205, 297, 2900, 3100];
roi_matrix_330=[287, 360, 232, 305, 3200, 3400];
roi_matrix_360=[298, 366, 240, 310, 3500, 3700];
roi_matrix_390=[290, 350, 136, 205, 3800, 4000];
roi_matrix_420=[310, 365, 290, 345, 4100, 4300];


roi_matrix_seq=[roi_matrix_60; roi_matrix_90; roi_matrix_120; roi_matrix_150; roi_matrix_180; ...
                roi_matrix_210; roi_matrix_240; roi_matrix_270; roi_matrix_300; ...
				roi_matrix_330; roi_matrix_360; roi_matrix_390; roi_matrix_420];
fprintf ("\n ROI Vectors are \n");
fprintf ("ss %d \n", roi_matrix_seq(3,:));
disp(roi_matrix_seq);
fprintf ("\n");


DIRECTORY_URL = 'd:\work\matlab\tez\_noise\depth_data';
depth_file_seq  = ["Depth_60.txt" "Depth_90.txt" "Depth_120.txt" "Depth_150.txt" "Depth_180.txt" ...
				"Depth_210.txt"  "Depth_240.txt" "Depth_270.txt" "Depth_300.txt" ...
				"Depth_330.txt"  "Depth_360.txt" "Depth_390.txt" "Depth_420.txt"];

fprintf ("\nDepth files are\n");
disp(depth_file_seq);
%fprintf ("%s ", depth_file_seq.');
fprintf ("\n");


if length(depth_file_seq) ~= length(roi_matrix_seq)
   fprintf ("\nLengths are not equal\n");
   return;
end

img_width = 640;
img_height = 480;
cal_params = [0.99, 4e-6];
max_distance = 8;
x=linspace(1, 640, 640);

fun_results = [];
residual_lines_org = [];
residual_lines_cal = [];
%for i = 1:length(depth_file_seq)
len=5;
for i = 2:2
   fprintf ("\nGoing to do ops for Depth file %s \n", i, depth_file_seq(i));
   disp(roi_matrix_seq(i,:));
   depth_data_file = fullfile(DIRECTORY_URL, char(depth_file_seq(i)));
   
   depthData = importdata(depth_data_file);

   %calPtPos = fun_calibrate_point_positions(depthData, img_width, img_height, cal_params);
   
   %[plmdl_org, rmse_org, plmdl_cal, rmse_cal, center_line_residuals_org, center_line_residuals_cal] = ...
   %  fun_find_fitplane_and_rmse( ...
   %   depthData, calPtPos, img_width, ...
   %    img_height, roi_matrix_seq(i,:), max_distance);
	   
   [plmdl, rmse, center_line_residuals_org] = fun_fitplane( ...
       depthData, img_width, img_height, roi_matrix_seq(i,:), max_distance);

   %%plot(x, center_line_residuals_org, '-');
   %%fun_results = [fun_results ; plmdl_org, rmse_org, plmdl_cal, rmse_cal];
   residual_lines_org = [residual_lines_org ; center_line_residuals_org];
   %residual_lines_cal = [residual_lines_cal ; center_line_residuals_cal];
end

fprintf ("\nFound Results in order\n");

%{

figure;
hold on;
for i = 1:len
   plot(x, residual_lines_org(i, :), '-');
end
mean_vals=mean(residual_lines_org, 1);
plot(x, mean_vals, 'LineWidth', 3);
legend('Mesafe: 60 cm', 'Mesafe: 90 cm', 'Mesafe: 120 cm', ...
   'Mesafe: 150 cm', 'Mesafe: 180 cm', 'Ortalama');
hold off;

figure;
hold on;
for i = 1:len
   plot(x, residual_lines_cal(i, :), '-');
end

mean_vals=mean(residual_lines_cal, 1);
plot(x, mean_vals, 'LineWidth', 3);
legend('Mesafe: 60 cm', 'Mesafe: 90 cm', 'Mesafe: 120 cm', ...
   'Mesafe: 150 cm', 'Mesafe: 180 cm', 'Ortalama');
hold off;

%}

% xmin, xmax, ymin, ymax, zmin, zmax
%roi_matrix=[150, 440, 40, 320, 800, 1000]; 
%depthFile = fullfile('d:\work\matlab\tez\_noise\depth_data', 'Depth_90.txt');
%fprintf("%s file is to be imported\n", depthFile);
%depthData = importdata(depthFile);
%img_width = 640;
%img_height = 480;
%cal_params = [0.99, 4e-6];
%calPtPos = fun_calibrate_point_positions(depthData, img_width, img_height, cal_params);

%fun_find_fitplane_and_rmse(depthData, calPtPos, 640, 480, roi_matrix, 5);

%if (5 >= 3)
%   return;
%end

%depth_file_seq  = "Depth_90.txt Depth_120.txt Depth_150.txt Depth_180.txt";
%depth_file_seq  = Depth_90.txt Depth_120.txt Depth_150.txt Depth_180.txt ' ...
%				' Depth_210.txt  Depth_240.txt Depth_270.txt Depth_300.txt ' ...
%				' Depth_330.txt Depth_360.txt Depth_390.txt Depth_420.txt';
%Depth_FILE_Matrix = split(depth_file_seq);
%disp(Depth_FILE_Matrix);

%Depth_90_FILE  = 'Depth_90.txt';
%Depth_120_FILE = 'Depth_120.txt';
%Depth_150_FILE = 'Depth_150.txt';
%Depth_180_FILE = 'Depth_180.txt';
%Depth_210_FILE = 'Depth_210.txt';
%Depth_240_FILE = 'Depth_240.txt';
%Depth_270_FILE = 'Depth_270.txt';
%Depth_300_FILE = 'Depth_300.txt';
%Depth_330_FILE = 'Depth_330.txt';
%Depth_360_FILE = 'Depth_360.txt';
%Depth_390_FILE = 'Depth_390.txt';
%Depth_420_FILE = 'Depth_420.txt';
