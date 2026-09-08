function output_signal = SR_System_RK4(input_signal, a, b, noise_D, h, t_end)
%SR_SYSTEM_RK4 Fourth-order Runge-Kutta solver for the bistable system.
%
%   output_signal = SR_System_RK4(input_signal, a, b, noise_D)
%   evolves each input element independently with x(0)=0.
%
% Inputs
%   input_signal : vectorized HSV value component in [0,1]
%   a, b         : bistable-system parameters
%   noise_D      : additional Gaussian perturbation intensity
%   h            : RK4 step size (optional, default 0.01)
%   t_end        : terminal integration time (optional, default 1.0)
%
% Output
%   output_signal: enhanced signal clipped to [0,1]

if nargin < 5 || isempty(h), h = 0.01; end
if nargin < 6 || isempty(t_end), t_end = 1.0; end

num_steps = ceil(t_end / h);
x = zeros(size(input_signal));

if noise_D > 0
    noise = sqrt(2 * noise_D) .* randn(size(input_signal));
else
    noise = 0;
end
S = input_signal + noise;

for k = 1:num_steps
    k1 = h .* (a .* x - b .* x.^3 + S);
    x1 = x + 0.5 .* k1;

    k2 = h .* (a .* x1 - b .* x1.^3 + S);
    x2 = x + 0.5 .* k2;

    k3 = h .* (a .* x2 - b .* x2.^3 + S);
    x3 = x + k3;

    k4 = h .* (a .* x3 - b .* x3.^3 + S);
    x = x + (k1 + 2 .* k2 + 2 .* k3 + k4) ./ 6;
end

output_signal = max(0, min(1, x));
end
