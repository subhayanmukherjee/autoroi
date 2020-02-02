% Please cite our IEEE ICIP 2016 conference paper: (Questions? subhayan001@gmail.com)
% "Highlighting Objects of Interest in an Image by integrating Saliency and Depth"

addpath(genpath(pwd));                              % dependencies should be placed under folder containing icipsal.m

I = imread('ttg01.png');                            % supplied image
D = imread('ttg02.png');                            % supplied image's depth map

% I = imresize(I, 1.2);                             % to test quickly if image is too big
% D = imresize(D, 1.2);                             % to test quickly if image is too big

% D = double(rgb2ind(D, jet(256)));                 % if supplied depth map is in jet color scheme
D = double(255 - D);                                % if disparity map supplied instead of depth map
% D = double(D);                                    % if depth map has been supplied

map = gbvs(I);                                      % famous GBVS saliency
ROI = ROI_saliency_map(map.master_map_resized);     % obtaining ROI

imshow(heatmap_overlay(I, ROI));                    % ROIs marked on image
% figure;                                           % Next, we filter these
% imshow(D);                                        % ROIs based on depth
tic;
F = double(unique(D(ROI)));                         % in-focus depths (sorted)

% Define focus boundary
Fd = diff(F);
Fdn = norm01(Fd);
level = graythresh(Fdn);                            % Ostu's method
p = find(Fdn > level, 1);
F = F(1) : F(p);                                    % volumetric focus

R = size(I, 1);
C = size(I, 2);
B = zeros(R, C);                                    % blur-level map
for i = 1:R
    for j = 1:C
        B(i, j) = min(abs(F - D(i, j)));            % see paper to understand
    end
end

Bp = B > 0;
S = unique(B(Bp));                                  % blur-levels

N = sum(Bp(:));
a = 0;
for i = 1:length(S)
    Bp = (B == S(i));
    a = a + (sum(Bp(:)) / N) * S(i);                % blur adjustment
end
a = a / 255;                                        % normalized "Alpha"
toc;
G = cell(1, max(S));
for i = 1:length(S)
    if a < 0.2                                      % "Beta"
        G{S(i)} = imgaussfilt(I, a * S(i));
    else
        G{S(i)} = imgaussfilt(I, a * S(i) / 5.0);   % "Gamma"
    end
end

O = I;                                              % output image
for i = 1:R
    for j = 1:C
        if B(i, j) > 0
            O(i, j, :) = G{B(i, j)}(i, j, :);
        end
    end
end

figure; imshow(O);