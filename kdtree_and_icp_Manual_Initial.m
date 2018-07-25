% 针对激光所QC项目容易陷入局部极小的问题
% 本版本增设人工输入初值的功能

% Step 2

% 生成 k-d tree
Mdl = KDTreeSearcher(ref_points);

nb_point_new = length(new_points);

input_correlation_new = new_points;
input_correlation_old = zeros(nb_point_new, 2);

iter_num = 100;
iter_thresh = 0.0001;

if_draw = false;

% 当前情况
figure
plot(ref_points(:,1), ref_points(:,2), '.b');
hold on;
plot(input_correlation_new(:,1), input_correlation_new(:,2), '.r');
hold off;
axis equal


% 死循环进行旋转角度确定
while true
    rot_angle = input('输入旋转角度：');
    rot_angle = rot_angle * pi/180;
    
    R = [cos(rot_angle), sin(rot_angle);
        -sin(rot_angle), cos(rot_angle)]; % 这里和转坐标轴的符号是反的，因为感觉是转点不是转坐标轴
    
    input_new_temp = (R * input_correlation_new')';
    
    close all;
    plot(ref_points(:,1), ref_points(:,2), '.b');
    hold on;
    plot(input_new_temp(:,1), input_new_temp(:,2), '.r');
    hold off;
    axis equal;
    
    if_ok = input('是否满意？(1-是；0-否)');
    
    if 1 == if_ok
        break;
    end
end

input_correlation_new = input_new_temp;

% 死循环确定平移量
while true
    trans_x = input('输入x方向平移量：');
    trans_y = input('输入y方向平移量：');
    
    t = [trans_x; trans_y];
    
    input_new_temp = (input_correlation_new' + t)';
    
    close all;
    plot(ref_points(:,1), ref_points(:,2), '.b');
    hold on;
    plot(input_new_temp(:,1), input_new_temp(:,2), '.r');
    hold off;
    axis equal;
    
    if_ok = input('是否满意？(1-是；0-否)');
    
    if 1 == if_ok
        break;
    end
end

input_correlation_new = input_new_temp;

% figure;
% hold off;

% 这里仅仅规定了最大迭代数目
% 原来的程序还规定了：当前后两次的误差变化<阈值的时候，迭代退出
pre_err = realmax;

tic

for j=1:1:iter_num

    % 绘制当前ref和new
    if if_draw
        plot(ref_points(:,1), ref_points(:,2), 'ob');
        hold on;
        plot(input_correlation_new(:,1), input_correlation_new(:,2), 'xr');
        axis equal
    %     xlim([0,450]);
    %     ylim([0,450]);
        pause(0.5);
    end

    err = 0; % 为了引入迭代退出机制
    
    for i=1:1:nb_point_new
        % 注意，利用 k-d tree 进行搜索时，先给出来的是index
        res_index = knnsearch(Mdl, input_correlation_new(i,:));
        input_correlation_old(i,:) = ref_points(res_index, :); 
        % 统计目前的误差量
        err = err + sqrt(sum((input_correlation_new(i,:) - input_correlation_old(i,:)).^2));
        % 绘制最近邻点
        if if_draw
            plot(input_correlation_old(i,1), input_correlation_old(i,2), '+b');
            plot([input_correlation_old(i,1), input_correlation_new(i,1)], [input_correlation_old(i,2), input_correlation_new(i,2)], '-b');
        end
    end
    
    delta_err = abs(err - pre_err);
    if delta_err < iter_thresh
        j
        break;
    else
        pre_err = err;
    end
    
    % 展示0.5s最近邻点
    if if_draw
        hold off;
        pause(0.5)
    end
    
    % 求出旋转R 平移t 分量
    mean_new = mean(input_correlation_new);
    mean_old = mean(input_correlation_old);

    AXY = input_correlation_new - mean_new;
    BXY = input_correlation_old - mean_old;

    H = AXY' * BXY;
    [U,S,V] = svd(H);
    R = V*[1,0;0,det(V*U')]*U';
    t = mean_old' - R * mean_new';

    input_correlation_new = (R*input_correlation_new' + t)';

    
    % 绘制更新
    if if_draw
        plot(ref_points(:,1), ref_points(:,2), 'ob');
        hold on;
        plot(input_correlation_new(:,1), input_correlation_new(:,2), 'xr');
        hold off;

        axis equal
    %     xlim([0,450]);
    %     ylim([0,450]);

        pause(0.5);
    end
end

toc

% 初始状况 - New point 和 自己的初始状况的对比
figure
plot(new_points(:,1), new_points(:,2), '.r');
hold on;
plot(input_correlation_new(:,1), input_correlation_new(:,2), '.r');
hold off;
axis equal;

% 最终状况 - 匹配效果
figure
plot(ref_points(:,1), ref_points(:,2), '.b');
hold on;
plot(input_correlation_new(:,1), input_correlation_new(:,2), '.r');
hold off;

axis equal
% xlim([0,450]);
% ylim([0,450]);

% 重新求一遍R_res, t_res
% 这样设置变量，求出的R和t能够作用在new，让new移动到old
mean_new = mean(new_points);
mean_old = mean(input_correlation_new);
AXY = new_points - mean_new;
BXY = input_correlation_new - mean_old;
H = AXY' * BXY;
[U,S,V] = svd(H);
R = V*[1,0;0,det(V*U')]*U';
t = mean_old' - R * mean_new';
