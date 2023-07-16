function Ray = D2D_UndistortRay( Ray, CameraModel, Options )

	Options = LFDefaultField( 'Options', 'NInverse_Distortion_Iters', 3 );

	DistortionModel = Options.DistortionModel;
	ParamInfo.FieldNames = {'Bias', 'Radial'};
	ParamInfo.SizeInfo = {[1 DistortionModel.AddBias * 2], [1 DistortionModel.RadialParamsToOpt]};
	Distortion = UnflattenStruct(CameraModel.Distortion, ParamInfo);

	if isempty(Distortion.Bias)
		Distortion.Bias = [0 0];
	end

	OriginalDirection = bsxfun(@minus, Ray(3:4,:), Distortion.Bias');

	Direction = OriginalDirection;
	for (InverseIters = 1:Options.NInverse_Distortion_Iters)
		DirectionR2 = sum(Direction.^2);
		Accumulator = 1;
		for idx = 1:length(Distortion.Radial)
			Accumulator = Accumulator + Distortion.Radial(idx) * DirectionR2.^idx;
		end
		switch( DistortionModel.Model )
			case 'multiplication'
				Direction = OriginalDirection ./ repmat(Accumulator, 2, 1);
			case 'division'
				Direction = OriginalDirection .* repmat(Accumulator, 2, 1);
			otherwise
				error('Unrecognised distortion model');
		end
	end
	
	Direction = bsxfun(@plus, Direction, Distortion.Bias');
	Ray(3:4,:) = Direction;
end
