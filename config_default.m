function cfg = config_default()
%CONFIG_DEFAULT Default parameters used by the reproducibility scripts.

cfg.b = 1.0;
cfg.noise_D = 0.0;

cfg.a_min = 0.0;
cfg.a_max = 8.0;
cfg.fixed_a = 2.0;

cfg.delta = 0.5;
cfg.local_no_prior_lb = 3.5;
cfg.local_no_prior_ub = 4.5;
cfg.local_center = 4.0;

cfg.local_particles = 8;
cfg.local_iterations = 8;
cfg.global_particles = 30;
cfg.global_iterations = 50;

cfg.w_start = 0.9;
cfg.w_end = 0.4;
cfg.c1 = 2.0;
cfg.c2 = 2.0;

cfg.rk4_h = 0.01;
cfg.t_end = 1.0;

cfg.search_size = 100;
cfg.rng_seed = 1;
end
