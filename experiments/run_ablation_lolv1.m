%% Reproduce the SR parameter-selection ablation on LOL-v1 eval15.
clc; clear; close all;

repo_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(repo_dir);
addpath(fullfile(repo_dir, 'src'));

cfg = config_default();
low_dir = fullfile(repo_dir, 'data', 'LOL-v1', 'eval15', 'low');
ref_dir = fullfile(repo_dir, 'data', 'LOL-v1', 'eval15', 'high');
out_dir = fullfile(repo_dir, 'results', 'lolv1_ablation');
vis_dir = fullfile(out_dir, 'visual_results');

if ~exist(low_dir, 'dir') || ~exist(ref_dir, 'dir')
    error(['LOL-v1 eval15 was not found. Place paired images under:\n' ...
           '  data/LOL-v1/eval15/low\n  data/LOL-v1/eval15/high']);
end
if ~exist(out_dir, 'dir'), mkdir(out_dir); end
if ~exist(vis_dir, 'dir'), mkdir(vis_dir); end

methods = {'fixed','prediction_only','local_no_prior','proposed','global'};
method_names = {'Fixed SR','Prediction only','Local PSO w/o prior','Proposed','Global PSO'};

exts = {'*.png','*.jpg','*.jpeg','*.bmp','*.tif'};
files = [];
for e = 1:numel(exts)
    files = [files; dir(fullfile(low_dir, exts{e}))]; %#ok<AGROW>
end
if isempty(files), error('No input images were found in %s', low_dir); end
[~, order] = sort({files.name});
files = files(order);

rows = {};
row_id = 1;

for i = 1:numel(files)
    name = files(i).name;
    low_path = fullfile(low_dir, name);
    ref_path = fullfile(ref_dir, name);
    if ~exist(ref_path, 'file')
        warning('Reference image not found for %s. Skipped.', name);
        continue;
    end

    fprintf('\n[%d/%d] %s\n', i, numel(files), name);
    rgb_low = imread(low_path);
    rgb_ref = imread(ref_path);
    if size(rgb_low,3) == 1, rgb_low = repmat(rgb_low, [1 1 3]); end
    if size(rgb_ref,3) == 1, rgb_ref = repmat(rgb_ref, [1 1 3]); end

    hsv_img = rgb2hsv(im2double(rgb_low));
    V = hsv_img(:,:,3);
    L_avg = mean(V(:));

    for k = 1:numel(methods)
        [a_best, a_pred, info] = BSR_Optimizer(V, L_avg, cfg.b, methods{k}, cfg);
        [rgb_out, ~] = apply_SR_enhancement(rgb_low, a_best, cfg.b, cfg);
        metrics = calc_metrics_pair(rgb_out, rgb_ref);

        method_dir = fullfile(vis_dir, regexprep(method_names{k}, '[^A-Za-z0-9_-]', '_'));
        if ~exist(method_dir, 'dir'), mkdir(method_dir); end
        imwrite(rgb_out, fullfile(method_dir, name));

        rows(row_id,:) = {name, method_names{k}, L_avg, a_pred, a_best, info.time, ...
            info.n_particles, info.max_iter, info.eval_count, metrics.psnr, metrics.ssim, metrics.entropy_gray}; %#ok<SAGROW>
        row_id = row_id + 1;

        fprintf('  %-22s a=%.4f  PSNR=%.4f  SSIM=%.4f  Entropy=%.4f  Time=%.4f s\n', ...
            method_names{k}, a_best, metrics.psnr, metrics.ssim, metrics.entropy_gray, info.time);
    end
end

vars = {'Image','Method','Lavg','a_pred','a_best','Time_s','Particles','Iterations','EvalCount','PSNR','SSIM','GrayEntropy'};
T = cell2table(rows, 'VariableNames', vars);
writetable(T, fullfile(out_dir, 'ablation_detailed_results.csv'));

summary_rows = cell(numel(method_names), 8);
for k = 1:numel(method_names)
    Tk = T(strcmp(T.Method, method_names{k}), :);
    summary_rows(k,:) = {method_names{k}, mean(Tk.Time_s), mean(Tk.PSNR), mean(Tk.SSIM), ...
        mean(Tk.GrayEntropy), mean(Tk.a_best), mean(Tk.EvalCount), ...
        sprintf('%.0f x %.0f', mean(Tk.Particles), mean(Tk.Iterations))};
end
summary_vars = {'Method','Mean_Time_s','Mean_PSNR','Mean_SSIM','Mean_GrayEntropy','Mean_a_best','Mean_EvalCount','Budget'};
Summary = cell2table(summary_rows, 'VariableNames', summary_vars);
writetable(Summary, fullfile(out_dir, 'ablation_summary_results.csv'));

disp(' ');
disp('===== Average Results =====');
disp(Summary);
