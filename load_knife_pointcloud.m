% Step1
clearvars
close all
% 载入刀具图片并处理成二维点云

ref_name = 'high4';
new_name = 'low2';

target_fold = '..\01-Image_Data\刀具检测图片0724\';

I1_canny = imread([target_fold, 'match_edge_', ref_name, '.bmp']);
I2_canny = imread([target_fold, 'match_edge_', new_name, '.bmp']);


% 密集点云 - match_edge_前缀的图片是 photoshop 输出的，虽然在图片查看器
% 中是黑底白色边缘，但是在MATLAB中却变成了白底黑色边缘。
% 所以此时找的是 ==0 的点，而非1
[idx1_y, idx1_x] = find(I1_canny == 0); % 这里行对应y，列对应x
[idx2_y, idx2_x] = find(I2_canny == 0);

% 稀疏点云
sample_step_ref = 5;
sample_step_new = 5;
spars_idx1_x = idx1_x(1:sample_step_ref:end);
spars_idx1_y = idx1_y(1:sample_step_ref:end);
spars_idx2_x = idx2_x(1:sample_step_new:end);
spars_idx2_y = idx2_y(1:sample_step_new:end);

ref_points = [spars_idx1_x, spars_idx1_y];
new_points = [spars_idx2_x, spars_idx2_y];

plot(idx1_x, idx1_y, 'b.');
hold on;
plot(idx2_x, idx2_y, 'r.');
axis equal;
