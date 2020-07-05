function varargout = gui_measure_distance(varargin)
% GUI_MEASURE_DISTANCE MATLAB code for gui_measure_distance.fig
%      GUI_MEASURE_DISTANCE, by itself, creates a new GUI_MEASURE_DISTANCE or raises the existing
%      singleton*.
%
%      H = GUI_MEASURE_DISTANCE returns the handle to a new GUI_MEASURE_DISTANCE or the handle to
%      the existing singleton*.
%
%      GUI_MEASURE_DISTANCE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI_MEASURE_DISTANCE.M with the given input arguments.
%
%      GUI_MEASURE_DISTANCE('Property','Value',...) creates a new GUI_MEASURE_DISTANCE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_measure_distance_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_measure_distance_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui_measure_distance

% Last Modified by GUIDE v2.5 30-Jun-2020 21:51:00

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_measure_distance_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_measure_distance_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before gui_measure_distance is made visible.
function gui_measure_distance_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui_measure_distance (see VARARGIN)

% Choose default command line output for gui_measure_distance
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes gui_measure_distance wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_measure_distance_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pb_SelectInputFile.
function pb_SelectInputFile_Callback(hObject, eventdata, handles)
   
   %sel_dir = uigetdir;
   %fprintf ("sel dir is %s dene1\n", sel_dir);
   
   %sel_dir=dir('*.*');
   %listing = dir(sel_dir);
   %for ix=1:length(listing)
   %   fn=listing(ix).name;
	%	[fPath, fName, fExt] = fileparts(fn);
	%if strcmp(lower(fExt), '.png')
	%	fprintf ("\tFILE %d is %s\n", ix, fn);
	%end
   %end
   

   [file, path] = uigetfile('*.*');
   if isequal(file,0)
      disp('User selected Cancel');
   else
      disp(['User selected ', fullfile(path,file)]);
	  set(handles.tbxInputImage, 'String', fullfile(path,file));
	  
   end

   
% hObject    handle to pb_SelectInputFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pb_SelectCalibrationFiles.
function pb_SelectCalibrationFiles_Callback(hObject, eventdata, handles)
% hObject    handle to pb_SelectCalibrationFiles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

   [sel_files, sel_path] = uigetfile('*.*', 'Select One or More Files', 'MultiSelect', 'on');

   if isequal(sel_files, 0)
      disp('User selected Cancel');
   else
      disp(['User selected other ', fullfile(sel_path,sel_files)]);
	  disp("\ndene\n");
	  disp(length(sel_files));
	  disp("\ndene\n");
	  
      if ~iscell(sel_files)
         sel_files = {sel_files};
      end
	  
	  ff = cell(1, length(sel_files));
	  
	  for ix=1:length(sel_files)
         %fn ='sss';
         %fn=sel_files{ix}.name;
		 %fn = fullfile(sel_path, sel_files{ix});
		 %fn = strcat(sel_path, sel_files{ix});
		 fn = sprintf('%s', sel_files{ix});
		 
		 ff{ix} = fullfile(sel_path, sel_files{ix});
         %[fPath, fName, fExt] = fileparts(fn);
         %fprintf ("dene3 ix " + ix + " fn " + fn + "\n");
      end
	  
	
set(handles.lbxImages, 'string', ff);
guidata(hObject, handles);

   end


% --- Executes on selection change in lbxImages.
function lbxImages_Callback(hObject, eventdata, handles)
% hObject    handle to lbxImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lbxImages contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbxImages


% --- Executes during object creation, after setting all properties.
function lbxImages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbxImages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tbxSquareSize_Callback(hObject, eventdata, handles)
% hObject    handle to tbxSquareSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxSquareSize as text
%        str2double(get(hObject,'String')) returns contents of tbxSquareSize as a double


% --- Executes during object creation, after setting all properties.
function tbxSquareSize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxSquareSize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbProcess.
function pbProcess_Callback(hObject, eventdata, handles)
% hObject    handle to pbProcess (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

   strSize=get(handles.tbxSquareSize, 'String');
   sqSize = str2num(strSize);

   listItems = get(handles.lbxImages, 'String');
   item_count = numel(listItems);

   fprintf("\nitem count is: %d \n", item_count);

   if (item_count <= 0)
      %set(handles.txtInfo, 'String', "Please select calibration images");
	  fprintf("\nPlease select calibration images!\n");
      return;
   end

   index_selected = get(handles.lbxImages, 'Value');
   fprintf("\nselected idx is: %d \n", index_selected);

   item_selected = listItems{index_selected};
   fprintf("\nselected item is: %s \n", item_selected);

%disp(item_count);
%disp("END: item count\n");

%for ix=1:length(listItems)
%   item_selected = listItems{ix};
%disp("list element: ");
%disp(item_selected);
%disp("   list element: ");
%end

   inputimage_selected= get(handles.tbxInputImage, 'String');

   if exist(inputimage_selected, 'file') ~= 2
      %set(handles.txtInfo, 'String', "input file does not exist");
      fprintf("input file (%s) does not exist!", inputimage_selected);
      return;
   end
   
   if (isnan(str2double(strSize)))
      %set(handles.txtInfo, 'String', "square size must be set as a numeric value");
      fprintf("Square size (%s) should be numeric!", strSize);
      return;
   end

   %fun_measure_distance(listItems, index_selected, strSize);
   [measured_distances, cameraParams] = ...
      fun_measure_distance(listItems, inputimage_selected, strSize);
   %global camera_parameters;
   %camera_parameters = cameraParams;
   return;



function tbxInputImage_Callback(hObject, eventdata, handles)
% hObject    handle to tbxInputImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxInputImage as text
%        str2double(get(hObject,'String')) returns contents of tbxInputImage as a double


% --- Executes during object creation, after setting all properties.
function tbxInputImage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxInputImage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_SelectImageToMeasure.
function pb_SelectImageToMeasure_Callback(hObject, eventdata, handles)
% hObject    handle to pb_SelectImageToMeasure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: delete(hObject) closes the figure

selection = questdlg('Close?',...
      'Close Request Function',...
      'This', 'All', 'Cancel', 'This'); 
   switch selection
      case 'This'
	     delete(hObject);
      case 'All'
	     Figures = findobj('Type', 'Figure', '-not', 'Tag', get(handles.output,'Tag'));
         close(Figures);
	     %close all;
         delete(hObject);
      case 'Cancel'
	     fprintf("cancel selected\n");
		 %delete(hObject);
      return 
   end


function tbxDepthDataFile_Callback(hObject, eventdata, handles)
% hObject    handle to tbxDepthDataFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxDepthDataFile as text
%        str2double(get(hObject,'String')) returns contents of tbxDepthDataFile as a double


% --- Executes during object creation, after setting all properties.
function tbxDepthDataFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxDepthDataFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbSelectDepthDataFile.
function pbSelectDepthDataFile_Callback(hObject, eventdata, handles)
% hObject    handle to pbSelectDepthDataFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

   [file, path] = uigetfile('*.*');
   if isequal(file,0)
      disp('User selected Cancel');
   else
      disp(['User selected ', fullfile(path,file)]);
	  set(handles.tbxDepthDataFile, 'String', fullfile(path,file));
   end



function tbxImageWidth_Callback(hObject, eventdata, handles)
% hObject    handle to tbxImageWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxImageWidth as text
%        str2double(get(hObject,'String')) returns contents of tbxImageWidth as a double


% --- Executes during object creation, after setting all properties.
function tbxImageWidth_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxImageWidth (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tbxImageHeight_Callback(hObject, eventdata, handles)
% hObject    handle to tbxImageHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxImageHeight as text
%        str2double(get(hObject,'String')) returns contents of tbxImageHeight as a double


% --- Executes during object creation, after setting all properties.
function tbxImageHeight_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxImageHeight (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tbxMaxDistance_Callback(hObject, eventdata, handles)
% hObject    handle to tbxMaxDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxMaxDistance as text
%        str2double(get(hObject,'String')) returns contents of tbxMaxDistance as a double


% --- Executes during object creation, after setting all properties.
function tbxMaxDistance_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxMaxDistance (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tbxXMin_Callback(hObject, eventdata, handles)
% hObject    handle to tbxXMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxXMin as text
%        str2double(get(hObject,'String')) returns contents of tbxXMin as a double


% --- Executes during object creation, after setting all properties.
function tbxXMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxXMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tbxXMax_Callback(hObject, eventdata, handles)
% hObject    handle to tbxXMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxXMax as text
%        str2double(get(hObject,'String')) returns contents of tbxXMax as a double


% --- Executes during object creation, after setting all properties.
function tbxXMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxXMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tbxYMin_Callback(hObject, eventdata, handles)
% hObject    handle to tbxYMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxYMin as text
%        str2double(get(hObject,'String')) returns contents of tbxYMin as a double


% --- Executes during object creation, after setting all properties.
function tbxYMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxYMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tbxYMax_Callback(hObject, eventdata, handles)
% hObject    handle to tbxYMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxYMax as text
%        str2double(get(hObject,'String')) returns contents of tbxYMax as a double


% --- Executes during object creation, after setting all properties.
function tbxYMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxYMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tbxZMin_Callback(hObject, eventdata, handles)
% hObject    handle to tbxZMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxZMin as text
%        str2double(get(hObject,'String')) returns contents of tbxZMin as a double


% --- Executes during object creation, after setting all properties.
function tbxZMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxZMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tbxZMax_Callback(hObject, eventdata, handles)
% hObject    handle to tbxZMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxZMax as text
%        str2double(get(hObject,'String')) returns contents of tbxZMax as a double


% --- Executes during object creation, after setting all properties.
function tbxZMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxZMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in lbxRois.
function lbxRois_Callback(hObject, eventdata, handles)
% hObject    handle to lbxRois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lbxRois contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbxRois
   contents = cellstr(get(hObject,'String'));
   selected_item = contents{get(hObject,'Value')};
   fprintf ("Selected item is %s\n", selected_item);
   
   if (contains(selected_item, "[") && contains(selected_item, "]"))
      fprintf ("Selected item contains brackets %s\n", selected_item);
	  substr = extractBetween(selected_item, "[", "]");
	  fprintf ("Substr is %s\n", substr{:});
	  splitted_str=split(substr, ',');
	  %fprintf ("Splitted str is: ");
	  %fprintf ("%s ", splitted_str{:});
	  element_count = size(splitted_str);
      fprintf ("  ???size is %d\n", element_count(1));
	  if (element_count(1) == 6)
         set(handles.tbxXMin, 'String', splitted_str{1});
         set(handles.tbxXMax, 'String', splitted_str{2});
         set(handles.tbxYMin, 'String', splitted_str{3});
         set(handles.tbxYMax, 'String', splitted_str{4});
         set(handles.tbxZMin, 'String', splitted_str{5});
         set(handles.tbxZMax, 'String', splitted_str{6});
      end
   else
      set(handles.tbxXMin, 'String', "");
      set(handles.tbxXMax, 'String', "");
      set(handles.tbxYMin, 'String', "");
      set(handles.tbxYMax, 'String', "");
      set(handles.tbxZMin, 'String', "");
      set(handles.tbxZMax, 'String', "");
   end

return;


% --- Executes during object creation, after setting all properties.
function lbxRois_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbxRois (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbAnalyse.
function pbAnalyse_Callback(hObject, eventdata, handles)
% hObject    handle to pbAnalyse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

   depth_data_file= get(handles.tbxDepthDataFile, 'String');
   fprintf("depth_data_file is %s \n", depth_data_file);

   if exist(depth_data_file, 'file') ~= 2
      %set(handles.txtInfo, 'String', "depth file does not exist");
	  fprintf("depth file %s does not exist!\n", depth_data_file);
      return;
   end

   strImageWidth=get(handles.tbxImageWidth, 'String');
   strImageHeight=get(handles.tbxImageHeight, 'String');
   strMaxDistance=get(handles.tbxMaxDistance, 'String');
   strXMin=get(handles.tbxXMin, 'String');
   strXMax=get(handles.tbxXMax, 'String');
   strYMin=get(handles.tbxYMin, 'String');
   strYMax=get(handles.tbxYMax, 'String');  
   strZMin=get(handles.tbxZMin, 'String');
   strZMax=get(handles.tbxZMax, 'String');
   
   if (isnan(str2double(strImageWidth)) ...
      || isnan(str2double(strImageHeight)) ...
	  || isnan(str2double(strMaxDistance)) ...
	  || isnan(str2double(strXMin)) ...
	  || isnan(str2double(strXMax)) ...
	  || isnan(str2double(strYMin)) ...
	  || isnan(str2double(strYMax)) ...
	  || isnan(str2double(strZMin)) ...
	  || isnan(str2double(strZMax))  )
      fprintf("Image Width/Height, Max Distance and X Y Z Min Max values should all be integer\n");
	  return;
   end

   nImageWidth = str2num(strImageWidth);
   nImageHeight = str2num(strImageHeight);
   nMaxDistance = str2num(strMaxDistance);
   nXMin = str2num(strXMin);
   nXMax = str2num(strXMax);
   nYMin = str2num(strYMin);
   nYMax = str2num(strYMax);
   nZMin = str2num(strZMin);
   nZMax = str2num(strZMax);

   if (  ~isIntegerValue(nImageWidth) ...
      || ~isIntegerValue(nImageHeight) ...
	  || ~isIntegerValue(nMaxDistance) ...
	  || ~isIntegerValue(nXMin) ...
	  || ~isIntegerValue(nXMax) ...
	  || ~isIntegerValue(nYMin) ...
	  || ~isIntegerValue(nYMax) ...
	  || ~isIntegerValue(nZMin) ...
	  || ~isIntegerValue(nZMax)  )
      fprintf("Each of Image Width/Height, Max Distance and X Y Z Min Max values must be int\n");
	  return;
   end
   
   fprintf("Inputs are W:%d, H:%d, Max:%d, OK\n", ...
      nImageWidth, nImageHeight, nMaxDistance);
   
   roi_matrix = [nXMin; nXMax; nYMin; nYMax; nZMin; nZMax];
   fprintf("ROI is: ");
   fprintf(" %d", roi_matrix.');
   fprintf("\n");
   
   depthDataOrg = importdata(depth_data_file);
   
   %try to get calibration parameters
   %global camera_parameters;
	  
   if handles.cbxUseCalData.Value
      fprintf("checkbox selected, going to use calibrated depth data\n");
        
      %if (isempty(camera_parameters))
      %   fprintf("Could not detect camera parameters!\n");
      %   return;
      %end
      strDCP1=get(handles.tbxDCP1, 'String');
      strDCP2=get(handles.tbxDCP2, 'String');
	  
	  if (isnan(str2double(strDCP1)) || isnan(str2double(strDCP2))  )
         fprintf("Depth Camera Parameters are invalid\n");
	     return;
      end
	  
	  dDCP1 = str2double(strDCP1);
	  dDCP2 = str2double(strDCP2);
	  camera_parameters = [dDCP1, dDCP2];
      fprintf("Camera Parameters are: [ %f %f ] ", ...
         camera_parameters(1), camera_parameters(2));
      %disp(camera_parameters);
	  
	  calPtPos = fun_calibrate_point_positions(...
         depthDataOrg, nImageWidth, nImageHeight, camera_parameters);
      depthData = calPtPos;
	  fprintf("calibrated depth data\n");
   else
      depthData = depthDataOrg;
   end

   fprintf("\nAll inputs and camera parameters are OK, going to fit plane!\n");
   [plmdl, rmse, center_line_residuals_org] = fun_fitplane( ...
         depthData, nImageWidth, nImageHeight, roi_matrix, nMaxDistance);
   
   return;

function T = isIntegerValue(X)
T = (mod(X, 1) == 0);


% --- Executes on button press in cbxUseCalData.
function cbxUseCalData_Callback(hObject, eventdata, handles)
% hObject    handle to cbxUseCalData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cbxUseCalData



function tbxDCP1_Callback(hObject, eventdata, handles)
% hObject    handle to tbxDCP1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxDCP1 as text
%        str2double(get(hObject,'String')) returns contents of tbxDCP1 as a double


% --- Executes during object creation, after setting all properties.
function tbxDCP1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxDCP1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tbxDCP2_Callback(hObject, eventdata, handles)
% hObject    handle to tbxDCP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tbxDCP2 as text
%        str2double(get(hObject,'String')) returns contents of tbxDCP2 as a double


% --- Executes during object creation, after setting all properties.
function tbxDCP2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tbxDCP2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
