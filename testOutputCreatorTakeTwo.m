clear;
clc;
data = randi([0 1],10,1);
trellis1 = poly2trellis([5 4],[23 35 0; 0 5 13]);
code1 = convenc(data,poly2trellis([5 4],[23 35 0; 0 5 13]));