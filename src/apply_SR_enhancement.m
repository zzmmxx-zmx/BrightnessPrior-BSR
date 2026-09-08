function [rgb_out, V_out] = apply_SR_enhancement(rgb_img, a, b, cfg)
%APPLY_SR_ENHANCEMENT Apply bistable enhancement to the HSV value channel.

if nargin < 4 || isempty(cfg), cfg = config_default(); end

rgb_in = im2double(rgb_img);
hsv_img = rgb2hsv(rgb_in);
H = hsv_img(:,:,1);
S = hsv_img(:,:,2);
V = hsv_img(:,:,3);

signal = SR_System_RK4(double(V(:)), a, b, cfg.noise_D, cfg.rk4_h, cfg.t_end);
V_out = reshape(signal, size(V));
V_out = max(0, min(1, V_out));

rgb_out = hsv2rgb(cat(3, H, S, V_out));
rgb_out = max(0, min(1, rgb_out));
end
