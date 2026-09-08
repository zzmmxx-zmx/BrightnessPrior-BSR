function metrics = calc_metrics_pair(rgb_out, rgb_ref)
%CALC_METRICS_PAIR PSNR, SSIM, and gray-level entropy for paired evaluation.
%
% The entropy reported here is computed from the grayscale image converted
% from the final enhanced RGB output. The PSO fitness uses V-channel entropy.

rgb_out = im2double(rgb_out);
rgb_ref = im2double(rgb_ref);

if size(rgb_out,3) == 1
    rgb_out = cat(3, rgb_out, rgb_out, rgb_out);
end
if size(rgb_ref,3) == 1
    rgb_ref = cat(3, rgb_ref, rgb_ref, rgb_ref);
end
if size(rgb_ref,1) ~= size(rgb_out,1) || size(rgb_ref,2) ~= size(rgb_out,2)
    rgb_ref = imresize(rgb_ref, [size(rgb_out,1), size(rgb_out,2)]);
end

rgb_out = max(0, min(1, rgb_out));
rgb_ref = max(0, min(1, rgb_ref));

metrics.psnr = psnr(rgb_out, rgb_ref);
metrics.ssim = ssim(rgb_out, rgb_ref);
metrics.entropy_gray = calc_entropy(rgb_out);
end
