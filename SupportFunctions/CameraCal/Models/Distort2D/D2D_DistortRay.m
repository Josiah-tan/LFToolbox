function Ray = D2D_DistortRay( Ray, CameraModel, Options )
	if( ~isempty(CameraModel.Distortion) && any(CameraModel.Distortion(:)~=0) )

		DistortionModel = Options.DistortionModel;
		ParamInfo.FieldNames = {'Bias', 'Radial'};
		ParamInfo.SizeInfo = {[1 DistortionModel.AddBias * 2], [1 DistortionModel.RadialParamsToOpt]};
		Distortion = UnflattenStruct(CameraModel.Distortion, ParamInfo);
		if isempty(Distortion.Bias)
			Distortion.Bias = [0 0];
		end

		Direction = Ray(3:4,:);
		Direction = bsxfun(@minus, Direction, Distortion.Bias');
		DirectionR2 = sum(Direction.^2);
		Accumulator = 1;
		for idx = 1:length(Distortion.Radial)
			Accumulator = Accumulator + Distortion.Radial(idx) * DirectionR2.^idx;
		end
		Direction = Direction .* repmat(Accumulator, 2, 1);
		Direction = bsxfun(@plus, Direction, Distortion.Bias');
		Ray(3:4,:) = Direction;
	end
end
