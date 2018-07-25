% 激光所QC项目 已知R和t的情况下算面积
% R
% t
% 都已知

I1_origin = imread([target_fold, ref_name, '.bmp']);
I2_origin = imread([target_fold, new_name, '.bmp']);

[row, col] = size(I1_origin);

I2_rotate = zeros(row, col);


I1_bw = imbinarize(I1_origin, 0.5);
I1_bw = 1 - I1_bw;

I2_bw = imbinarize(I2_origin, 0.5);
I2_bw = 1 - I2_bw;

% 这种方法有问题，具体什么问题请联想镜头畸变校正
% % 找到所有 I2_bw 中的 1 值点
% [knife_y, knife_x] = find(I2_bw == 1);
% 
% % 构造矩阵
% I2_points = [knife_x'; knife_y'];
% I2_points_match = R * I2_points + t;
% I2_points_match_round = round(I2_points_match);
% 
% plot(I2_points_match(1, :), -I2_points_match(2, :), '.b')
% hold on;
% plot(I2_points_match_round(1, :), -I2_points_match_round(2, :), '.r')
% pos_of_one = sub2ind([row, col], I2_points_match_round(2, :), I2_points_match_round(1, :));
% I2_rotate(pos_of_one) = 1;


for i=1:row
    for j=1:col
        im_x = j;
        im_y = i;
        trans_back = R'*([im_x;im_y] - t);
        target_x = round(trans_back(1));
        target_y = round(trans_back(2));
        if (target_x >= 1) && (target_x <= col)
            if (target_y >= 1) && (target_y <= row)
                I2_rotate(i,j) = I2_bw(target_y, target_x);
            end
        end
    end
end
%%


I2_bw_rotate = logical(I2_rotate);
Im_XOR_12 = xor(I1_bw, I2_bw_rotate);

% 二者不同的地方，包含熔覆厚度
imshow(Im_XOR_12)

% 对不同的地方直接做开运算
Im_XOR_open = bwmorph(Im_XOR_12, 'open');

% 开运算后画个图
figure;
imshow(Im_XOR_open);

% 统计连通域
[Im_Label_XOR, Im_Label_Num] = bwlabel(Im_XOR_open);

% 获取面积最大的连通域
max_num_pre = 0;
for i=1:Im_Label_Num
    sub_index = find(Im_Label_XOR == i);
    max_num = length(sub_index);
    if max_num > max_num_pre
        max_num_pre = max_num;
        max_index = i;
    end
end

sub_index = find(Im_Label_XOR == max_index);
I2_result = zeros(row, col);
I2_result(sub_index) = 1;
imshow(I2_result);