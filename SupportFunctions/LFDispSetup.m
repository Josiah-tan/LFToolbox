% LFDispSetup - helper function used to set up a light field display
% 
% Usage: 
% 
%     [ImageHandle, FigureHandle] = LFDispSetup( InitialFrame )
%     [ImageHandle, FigureHandle] = LFDispSetup( InitialFrame, ScaleFactor )
% 
% 
% This sets up a figure for LFDispMousePan and LFDispVidCirc. The figure is configured for
% high-performance display, and subsequent calls will reuse the same figure, rather than creating a
% new window on each call. The function should handle both mono and colour images.
% 
% 
% Inputs:
% 
%     InitialFrame : a 2D image with which to start the display
% 
% Optional Inputs: 
% 
%     ScaleFactor : Adjusts the size of the display -- 1 means no change, 2 means twice as big, etc.
%                   Integer values are recommended to avoid scaling artifacts. Note that the scale
%                   factor is only applied the first time a figure is created -- i.e. the figure
%                   must be closed to make a change to scale.
% 
% Outputs:
% 
%     FigureHandle, ImageHandle : handles of the created objects
%
% todo: doc: changed behaviour to better match matlab's when creating new figures
% you can now have multiple open interactive lfdisp figures
%
% See also:  LFDispVidCirc, LFDispMousePan

% Part of LF Toolbox xxxVersionTagxxx
% Copyright (c) 2013-2015 Donald G. Dansereau

function [ImageHandle, FigureHandle] = LFDispSetup( InitialFrame, ScaleFactor )

%---
ScaleFactor = LFDefaultVal('ScaleFactor', 1);

%---
CurSize = [size(InitialFrame), ScaleFactor];
FigureHandle = get(0, 'CurrentFigure');

%---Check if window already existed with correct size---
RedoWindow = false;
if( ~isempty(FigureHandle) )
	PrevSize = FigureHandle.UserData;
	PrevTag = get(FigureHandle, 'Tag');
	if( strcmp(PrevTag, 'LFDisplay') || ~all(size(PrevSize)==size(CurSize)) || ~all(CurSize == PrevSize) )
		% either not tagged or incorrect size; clear the figure and rebuild it below
		clf( FigureHandle );
		RedoWindow = true;
	end
end

if( isempty(FigureHandle) || RedoWindow )
    % Get screen size
    set( 0, 'units','pixels' );
    ScreenSize = get( 0, 'screensize' );
    ScreenSize = ScreenSize(3:4);
    
    % Create the figure if one doesn't already exist
	if( isempty(FigureHandle) )
		FigureHandle = figure(...
			'doublebuffer','on',...
			'backingstore','off',...
			...%'menubar','none',...
			...%'toolbar','none',...
			'tag','LFDisplay');
	else
		% make sure it's set up correctly
		FigureHandle.set( 'doublebuffer','on',...
			'backingstore','off',...
			...%'menubar','none',...
			...%'toolbar','none',...
			'tag','LFDisplay');
	end

	FigureHandle.UserData = [size(InitialFrame), ScaleFactor];
	FigureHandle.NextPlot = 'add';

    % Set the axis position and size within the figure
    AxesPos = [0,0,size(InitialFrame,2),size(InitialFrame,1)];
    axes('units','pixels',...
         'Position', AxesPos,...
         'xlimmode','manual',...
         'ylimmode','manual',...
         'zlimmode','manual',...
         'climmode','manual',...
         'alimmode','manual',...
         'layer','bottom');
     
    ImageHandle = imshow(InitialFrame);
	
    % Scaling factor sets the size of the display
	% this has the nice side-effect of rescaling and, if needed, repositining the window
	truesize(floor(ScaleFactor*size(InitialFrame(:,:,1))));
    
else
    ImageHandle = findobj(FigureHandle,'type','image');
    set(ImageHandle,'cdata', InitialFrame);
end

