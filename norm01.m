function [N] = norm01(A)
A = double(A);
N = mat2gray(A, [min(A(:)) max(A(:))]);