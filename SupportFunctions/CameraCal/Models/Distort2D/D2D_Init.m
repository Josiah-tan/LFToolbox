% todo[doc]
function [CameraModel, CalOptions] = D2D_Init( CameraModel, CalOptions )
	CalOptions.DistortionParamsToOpt = 1:(CalOptions.DistortionModel.RadialParamsToOpt + CalOptions.DistortionModel.AddBias * 2);

	if( isempty(CameraModel.Distortion) && ~isempty(CalOptions.DistortionParamsToOpt) )
		CameraModel.Distortion( CalOptions.DistortionParamsToOpt ) = 0;
	end

end
