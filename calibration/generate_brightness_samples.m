function sample_table = generate_brightness_samples(input_files, alpha_values, output_dir)
% GENERATE_BRIGHTNESS_SAMPLES
% Implements the controlled brightness-scaling procedure used for
% brightness calibration.
%
% Each source image is converted to HSV, and its value component is scaled as
%
%     V_alpha(x,y) = alpha * V(x,y)
%
% while the hue and saturation components are retained. The image-level
% brightness statistic is then calculated as
%
%     Lavg = mean(V_alpha(:)).
%
% Inputs
%   input_files  : cell array or string array containing source-image paths
%   alpha_values : vector of brightness-scaling factors, one per source image
%   output_dir   : optional folder for saving generated samples
%
% Output
%   sample_table : table containing SampleID, Alpha, and Lavg
%
% Notes
%   - Source images should be selected from non-test data.
%   - This utility implements the calibration-sample construction procedure.
%   - The calibration pairs used for regression fitting are released
%     separately in brightness_calibration_pairs.csv.

    if nargin < 2
        error('input_files and alpha_values are required.');
    end

    if nargin < 3
        output_dir = '';
    end

    if isstring(input_files)
        input_files = cellstr(input_files);
    end

    if ~iscell(input_files)
        error('input_files must be a cell array or string array.');
    end

    alpha_values = alpha_values(:);

    if numel(input_files) ~= numel(alpha_values)
        error('input_files and alpha_values must have the same number of elements.');
    end

    if any(alpha_values <= 0 | alpha_values > 1)
        error('All alpha values must satisfy 0 < alpha <= 1.');
    end

    save_samples = ~isempty(output_dir);
    if save_samples && ~exist(output_dir, 'dir')
        mkdir(output_dir);
    end

    n = numel(input_files);
    sample_id = strings(n,1);
    alpha_out = zeros(n,1);
    lavg_out = zeros(n,1);

    for k = 1:n
        img_path = input_files{k};

        if ~isfile(img_path)
            error('Input image not found: %s', img_path);
        end

        rgb = im2double(imread(img_path));

        if ndims(rgb) == 2
            rgb = repmat(rgb, [1,1,3]);
        elseif size(rgb,3) > 3
            rgb = rgb(:,:,1:3);
        end

        hsv_img = rgb2hsv(rgb);
        H = hsv_img(:,:,1);
        S = hsv_img(:,:,2);
        V = hsv_img(:,:,3);

        alpha = alpha_values(k);
        V_alpha = alpha .* V;
        V_alpha = max(0, min(1, V_alpha));

        Lavg = mean(V_alpha(:));
        rgb_alpha = hsv2rgb(cat(3, H, S, V_alpha));
        rgb_alpha = max(0, min(1, rgb_alpha));

        sample_id(k) = sprintf('sample_%03d', k);
        alpha_out(k) = alpha;
        lavg_out(k) = Lavg;

        if save_samples
            out_name = sprintf('sample_%03d_alpha_%.3f.png', k, alpha);
            imwrite(rgb_alpha, fullfile(output_dir, out_name));
        end
    end

    sample_table = table(sample_id, alpha_out, lavg_out, ...
        'VariableNames', {'SampleID','Alpha','Lavg'});
end
