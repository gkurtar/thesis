% ***********************************************************
% TBD
% Corresponding matlab example is used
% 5 Temmuz 2020
% Rev 1:
%
% **********************************************************
function [depthCameraParams] = fun_calibrate_depth_camera(...
      argOriginalDepthPositions, argEvaluatedDepthPositions)

   fprintf("\nBEGIN: fun_calibrate_depth_camera\n");
   
   depthCameraParams = [1, 0];

   if (~isvector(argOriginalDepthPositions) || ~isvector(argEvaluatedDepthPositions))
      fprintf('input arguments should be vectors\n');
      return;
   end
   
   if (~isnumeric(argOriginalDepthPositions) || ~isnumeric(argEvaluatedDepthPositions))
      fprintf('Depth Positions should be numeric\n');
      return;
   end

   if (~eq(length(argOriginalDepthPositions), length(argEvaluatedDepthPositions)))
      fprintf("input vector sizes should be same\n");
      return;
   end
   
   if (~eq(length(argOriginalDepthPositions), length(argEvaluatedDepthPositions)))
      fprintf("input vector sizes should be same\n");
      return;
   end
   
   if (length(argOriginalDepthPositions) < 3)
      fprintf("input vector size should not be less than 3\n");
      return;
   end
   
   originalDepthPositions = [];
   evaluatedDepthPositions = [];
   
   k = 1;
   for i=1:length(argOriginalDepthPositions)
      if (abs(argOriginalDepthPositions(i)) < 1E-7)
	     continue;
      elseif (abs(argEvaluatedDepthPositions(i)) < 1E-7)
	     continue;
      else
         originalDepthPositions(k) = argOriginalDepthPositions(i);
         evaluatedDepthPositions(k) = argEvaluatedDepthPositions(i);
		 k = k + 1;
      end  
   end
   
   fprintf("\nAfter checking: org depth_distances\n");
   fprintf(" %d ", originalDepthPositions.' );
   fprintf("\nAfter checking: eval depth_distances\n");
   fprintf(" %d ", evaluatedDepthPositions.' );
   
   if (length(originalDepthPositions) < 3)
      fprintf("controlled input and its size is (%d) not enough\n",...
         length(originalDepthPositions));
      return;
   end

   OrgDepthPosAsInverse = 1 ./ originalDepthPositions;
   EvalDepthPosAsInverse = 1 ./ evaluatedDepthPositions;
   
   fprintf("\nOriginal_depth_distances\n");
   fprintf(" %d ", originalDepthPositions.' );
   fprintf("\nInverse original_depth_distances\n");
   fprintf(" %d ", OrgDepthPosAsInverse.' );
   
   fprintf("\nMeasured_depth_distances\n");
   fprintf(" %d ", evaluatedDepthPositions.' );
   fprintf("\nInverse measured_depth_distances\n");
   fprintf(" %d ", EvalDepthPosAsInverse.' );
   
   depthCameraParams = polyfit(OrgDepthPosAsInverse, EvalDepthPosAsInverse, 1);
   f = polyval(depthCameraParams, OrgDepthPosAsInverse);
   %[p, S, mu] = polyfit(OrgDepthPosAsInverse, EvalDepthPosAsInverse, 1);
   %f = polyval(p, OrgDepthPosAsInverse, S, mu);
   figure;
   title("Inverse Sensor Depth versus Inverse Evaluated Depth Graph");
   plot(OrgDepthPosAsInverse, EvalDepthPosAsInverse, 'o', OrgDepthPosAsInverse, f, '-');
   xlabel("Inverse Sensor Depth Value");
   ylabel("Evaluated Sensor Depth Value");
   legend('data','linear fit');
   fprintf("\n");
   disp(depthCameraParams);
   
   figure;
   title("Sensor Depth versus Evaluated Depth Graph");
   plot(originalDepthPositions, evaluatedDepthPositions, 'o', OrgDepthPosAsInverse, f, '-');
   xlabel("Sensor Depth Value");
   ylabel("Evaluated Sensor Depth Value");
   %depthCameraParams = p;

   fprintf("\nEND: fun_calibrate_depth_camera\n");
   return;

end