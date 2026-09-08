function results = fit_brightness_mapping(sample_csv)
%FIT_BRIGHTNESS_MAPPING Estimate linear and quadratic brightness-a mappings.
%
% Candidate a values are screened on [0,8] with a step of 0.1 using the
% entropy of the enhanced HSV value component as the reference-free score.

repo_dir = fileparts(fileparts(mfilename('fullpath')));
addpath(repo_dir);
addpath(fullfile(repo_dir, 'src'));
cfg = config_default();

T = readtable(sample_csv, 'TextType', 'string');
if ~all(ismember({'OutputPath','Lavg'}, T.Properties.VariableNames))
    error('Input table must contain OutputPath and Lavg columns.');
end

a_grid = cfg.a_min:0.1:cfg.a_max;
a_opt = zeros(height(T),1);

for i = 1:height(T)
    rgb = imread(T.OutputPath(i));
    hsv_img = rgb2hsv(im2double(rgb));
    V = hsv_img(:,:,3);
    input = double(V(:));

    best_score = -inf;
    best_a = a_grid(1);
    for a = a_grid
        out = SR_System_RK4(input, a, cfg.b, cfg.noise_D, cfg.rk4_h, cfg.t_end);
        V_out = reshape(out, size(V));
        score = calc_entropy(V_out);
        if score > best_score
            best_score = score;
            best_a = a;
        end
    end
    a_opt(i) = best_a;
end

x = T.Lavg;
p1 = polyfit(x, a_opt, 1);
p2 = polyfit(x, a_opt, 2);
y1 = polyval(p1, x);
y2 = polyval(p2, x);

stats_linear = regression_stats(a_opt, y1);
stats_quadratic = regression_stats(a_opt, y2);

results = struct();
results.a_opt = a_opt;
results.linear_coefficients = p1;
results.quadratic_coefficients = p2;
results.linear = stats_linear;
results.quadratic = stats_quadratic;

fprintf('Linear:    a = %.6f L + %.6f\n', p1(1), p1(2));
fprintf('            R2=%.4f RMSE=%.4f MAE=%.4f\n', stats_linear.R2, stats_linear.RMSE, stats_linear.MAE);
fprintf('Quadratic: a = %.6f L^2 + %.6f L + %.6f\n', p2(1), p2(2), p2(3));
fprintf('            R2=%.4f RMSE=%.4f MAE=%.4f\n', stats_quadratic.R2, stats_quadratic.RMSE, stats_quadratic.MAE);
end

function s = regression_stats(y, yhat)
ss_res = sum((y - yhat).^2);
ss_tot = sum((y - mean(y)).^2);
s.R2 = 1 - ss_res / ss_tot;
s.RMSE = sqrt(mean((y - yhat).^2));
s.MAE = mean(abs(y - yhat));
end
