%% Single-image example using the proposed method.
clc; clear; close all;

repo_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(repo_dir);
addpath(fullfile(repo_dir, 'src'));

cfg = config_default();
img_path = fullfile(repo_dir, 'data', 'demo', 'input.png');
if ~exist(img_path, 'file')
    error('Place a demo image at data/demo/input.png');
end

rgb = imread(img_path);
if size(rgb,3) == 1, rgb = repmat(rgb, [1 1 3]); end
hsv_img = rgb2hsv(im2double(rgb));
V = hsv_img(:,:,3);
L_avg = mean(V(:));

[a_best, a_pred, info] = BSR_Optimizer(V, L_avg, cfg.b, 'proposed', cfg);
[rgb_out, ~] = apply_SR_enhancement(rgb, a_best, cfg.b, cfg);

out_path = fullfile(repo_dir, 'results', 'demo_output.png');
if ~exist(fullfile(repo_dir, 'results'), 'dir'), mkdir(fullfile(repo_dir, 'results')); end
imwrite(rgb_out, out_path);

fprintf('L_avg = %.6f\n', L_avg);
fprintf('a_pred = %.6f\n', a_pred);
fprintf('a_best = %.6f\n', a_best);
fprintf('fitness evaluations = %d\n', info.eval_count);
fprintf('saved: %s\n', out_path);
