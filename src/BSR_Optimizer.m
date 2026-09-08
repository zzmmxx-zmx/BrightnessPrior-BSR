function [a_best, a_pred, info] = BSR_Optimizer(img_V, L_avg, b, mode, cfg)
%BSR_OPTIMIZER Unified parameter-selection routine used in the experiments.
%
% Modes
%   fixed           : fixed SR with a = 2
%   prediction_only : direct use of brightness-prior prediction
%   local_no_prior  : local PSO on [3.5,4.5]
%   proposed        : prior-guided local PSO around a_pred
%   global          : global PSO on [0,8]

if nargin < 4 || isempty(mode), mode = 'proposed'; end
if nargin < 5 || isempty(cfg), cfg = config_default(); end

rng(cfg.rng_seed, 'twister');

a_pred = 20.992 .* (L_avg.^2) - 17.682 .* L_avg + 5.121;
a_pred = max(cfg.a_min, min(cfg.a_max, a_pred));

img_eval = prepare_evaluation_image(img_V, cfg.search_size);
input_eval = double(img_eval(:));
img_size = size(img_eval);

info = struct('mode', mode, 'a_pred', a_pred, 'b', b, ...
              'search_size', cfg.search_size, 'search_range', [NaN, NaN], ...
              'n_particles', 0, 'max_iter', 0, 'eval_count', 0);

t_start = tic;

switch lower(mode)
    case 'fixed'
        a_best = cfg.fixed_a;

    case 'prediction_only'
        a_best = a_pred;

    case 'local_no_prior'
        lb = cfg.local_no_prior_lb;
        ub = cfg.local_no_prior_ub;
        [a_best, n_eval] = pso_search(input_eval, img_size, b, lb, ub, ...
            cfg.local_center, cfg.local_particles, cfg.local_iterations, cfg);
        info.search_range = [lb, ub];
        info.n_particles = cfg.local_particles;
        info.max_iter = cfg.local_iterations;
        info.eval_count = n_eval;

    case 'proposed'
        lb = max(cfg.a_min, a_pred - cfg.delta);
        ub = min(cfg.a_max, a_pred + cfg.delta);
        [a_best, n_eval] = pso_search(input_eval, img_size, b, lb, ub, ...
            a_pred, cfg.local_particles, cfg.local_iterations, cfg);
        info.search_range = [lb, ub];
        info.n_particles = cfg.local_particles;
        info.max_iter = cfg.local_iterations;
        info.eval_count = n_eval;

    case 'global'
        lb = cfg.a_min;
        ub = cfg.a_max;
        [a_best, n_eval] = pso_search(input_eval, img_size, b, lb, ub, ...
            cfg.local_center, cfg.global_particles, cfg.global_iterations, cfg);
        info.search_range = [lb, ub];
        info.n_particles = cfg.global_particles;
        info.max_iter = cfg.global_iterations;
        info.eval_count = n_eval;

    otherwise
        error('Unknown optimization mode: %s', mode);
end

info.time = toc(t_start);
info.a_best = a_best;
end

function img_eval = prepare_evaluation_image(img, target_size)
if max(size(img,1), size(img,2)) > target_size
    scale = target_size / max(size(img,1), size(img,2));
    img_eval = imresize(img, scale);
else
    img_eval = img;
end
end

function [g_best_x, eval_count] = pso_search(input, img_size, b, lb, ub, init_center, n_particles, max_iter, cfg)
particles_x = lb + (ub - lb) .* rand(n_particles, 1);
particles_x(1) = max(lb, min(ub, init_center));
particles_v = zeros(n_particles, 1);

p_best_x = particles_x;
p_best_fit = -inf(n_particles, 1);
g_best_fit = -inf;
g_best_x = particles_x(1);
eval_count = 0;

for i = 1:n_particles
    fit = fitness_entropy(input, particles_x(i), b, img_size, cfg);
    eval_count = eval_count + 1;
    p_best_fit(i) = fit;
    if fit > g_best_fit
        g_best_fit = fit;
        g_best_x = particles_x(i);
    end
end

for iter = 1:max_iter
    w = cfg.w_start - (cfg.w_start - cfg.w_end) .* (iter / max_iter);
    for i = 1:n_particles
        r1 = rand();
        r2 = rand();
        particles_v(i) = w .* particles_v(i) + ...
            cfg.c1 .* r1 .* (p_best_x(i) - particles_x(i)) + ...
            cfg.c2 .* r2 .* (g_best_x - particles_x(i));

        particles_x(i) = max(lb, min(ub, particles_x(i) + particles_v(i)));
        fit = fitness_entropy(input, particles_x(i), b, img_size, cfg);
        eval_count = eval_count + 1;

        if fit > p_best_fit(i)
            p_best_fit(i) = fit;
            p_best_x(i) = particles_x(i);
        end
        if fit > g_best_fit
            g_best_fit = fit;
            g_best_x = particles_x(i);
        end
    end
end
end

function fit = fitness_entropy(input, a, b, img_size, cfg)
output = SR_System_RK4(input, a, b, cfg.noise_D, cfg.rk4_h, cfg.t_end);
img = reshape(output, img_size);
img_u8 = im2uint8(max(0, min(1, img)));
counts = imhist(img_u8);
p = counts ./ sum(counts);
p(p == 0) = [];
fit = -sum(p .* log2(p));
end
