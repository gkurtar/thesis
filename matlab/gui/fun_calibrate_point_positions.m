%--------------------------------------------------------
% This function calibrates a depth point matrix based on
% calibration parameters given as argument.
%
% Input Arguments:
%    pt_positions -> Original Depth Data of x y z point triples, i.e. a (:, 3) matrix
%    img_width    -> Depth Image Width, typically 640 for Kinect v1
%    img_height   -> Depth Image Height, typically 480 for Kinect v1
%    cal_params   -> Calibration Params, a 1x2  double vector
%
% Output Values:
%    cal_pt_positions -> Calibrated Depth Data of x y z point triples, i.e. a (:, 3) matrix
%--------------------------------------------------------
function cal_pt_positions = fun_calibrate_point_positions(pt_positions, img_width, img_height, cal_params)

	%classes = {'numeric'};
    %attributes = {'size', [ : , 3]};
    %validateattributes(A,classes,attributes);

	cal_param_a = cal_params(1);
	cal_param_b = cal_params(2);
	cal_pt_positions=zeros(img_height * img_width, 3);
	
	for i = 1 : img_height
      for j = 1 : img_width
	     rowIndex = (i - 1) * img_width + j;
		 org_depth_val = pt_positions(rowIndex, 3); %assign z val
		 revised_depth = 1 / (cal_param_a / org_depth_val + cal_param_b);
		 
		 cal_pt_positions(rowIndex, 1) = j;
		 cal_pt_positions(rowIndex, 2) = i;
	     cal_pt_positions(rowIndex, 3) = int32(revised_depth);
	  end
	end
	
	fprintf ("Calibrated input point cloud of %d points\n", length(cal_pt_positions));
	return;
end
