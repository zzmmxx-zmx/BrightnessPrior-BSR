function E = calc_entropy(img)
%CALC_ENTROPY Gray-level Shannon entropy of an image.

if size(img, 3) == 3
    img = rgb2gray(img);
end
if ~isa(img, 'uint8')
    img = im2uint8(img);
end

counts = imhist(img);
p = counts ./ sum(counts);
p(p == 0) = [];
E = -sum(p .* log2(p));
end
