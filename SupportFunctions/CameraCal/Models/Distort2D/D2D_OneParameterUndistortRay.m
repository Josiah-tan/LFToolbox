function Ray = D2D_OneParameterUndistortRay( Ray, CameraModel, Options )

	DistortionModel = Options.DistortionModel;
	ParamInfo.FieldNames = {'Bias', 'Radial'};
	ParamInfo.SizeInfo = {[1 DistortionModel.AddBias * 2], [1 DistortionModel.RadialParamsToOpt]};
	Distortion = UnflattenStruct(CameraModel.Distortion, ParamInfo);
	DistortionRadial = Distortion.Radial(1);

	if DistortionRadial == 0
		return 
	end
	if isempty(Distortion.Bias)
		Distortion.Bias = [0 0];
	end

	OriginalDirection = bsxfun(@minus, Ray(3:4,:), Distortion.Bias');

	DirectionR2 = sum(OriginalDirection.^2);

	switch( DistortionModel.Model )
		case 'division'
			ratio = (1 - sqrt(1 - 4 * DistortionRadial * DirectionR2)) ./ (2 * DirectionR2 * DistortionRadial);
			Direction = OriginalDirection .* repmat(ratio, 2, 1);
		case 'multiplication'
			p = 1 / DistortionRadial;
			DirectionR = sqrt(DirectionR2);
			q_row = -DirectionR .* p;
			delta_row = q_row .^ 2 ./ 4 + p .^ 3 ./ 27;
			ru_row = DirectionR;
			for index=1:length(delta_row)
				q = q_row(1, index);
				delta = delta_row(1, index);
				if delta > 0
					ru = nthroot(-q ./ 2 + sqrt(delta), 3) + nthroot(-q ./ 2 - sqrt(delta), 3);
				elseif delta == 0
					ru = 3 .* q ./ p;
				else
					ru = 2 .* sqrt(-p ./ 3) .* cos(1 ./ 3 .* acos(3 .* q ./ (2 * p) .* sqrt(-3 ./ p)) - 2 * pi / 3);
				end
				ru_row(1, index) = ru;
			end
			Direction = OriginalDirection .* repmat(ru_row ./ DirectionR, 2, 1);
		otherwise
			error('unsupported distortion model for one parameter undistortion');
	end

	Direction = bsxfun(@plus, Direction, Distortion.Bias');
	Ray(3:4,:) = Direction;
end

