% Step 2

% 生成 k-d tree
Mdl = KDTreeSearcher(ref_points);

nb_point_new = length(new_points);

input_correlation_new = new_points;
input_correlation_old = zeros(nb_point_new, 2);

iter_num = 100;
iter_thresh = 0.0001;

% figure;
% hold off;

% 这里仅仅规定了最大迭代数目
% 原来的程序还规定了：当前后两次的误差变化<阈值的时候，迭代退出
pre_err = realmax;

tic

for j=1:1:iter_num

    % 绘制当前ref和new
    plot(ref_points(:,1), ref_points(:,2), 'ob');
    hold on;
    plot(input_correlation_new(:,1), input_correlation_new(:,2), 'xr');
    axis equal
%     xlim([0,450]);
%     ylim([0,450]);
    pause(0.5)

    err = 0; % 为了引入迭代退出机制
    
    for i=1:1:nb_point_new
        % 注意，利用 k-d tree 进行搜索时，先给出来的是index
        res_index = knnsearch(Mdl, input_correlation_new(i,:));
        input_correlation_old(i,:) = ref_points(res_index, :); 
        % 统计目前的误差量
        err = err + sqrt(sum((input_correlation_new(i,:) - input_correlation_old(i,:)).^2));
        % 绘制最近邻点
        plot(input_correlation_old(i,1), input_correlation_old(i,2), '+b');
        plot([input_correlation_old(i,1), input_correlation_new(i,1)], [input_correlation_old(i,2), input_correlation_new(i,2)], '-b');
    end
    
    delta_err = abs(err - pre_err);
    if delta_err < iter_thresh
        j
        break;
    else
        pre_err = err;
    end
    
    % 展示0.5s最近邻点
    hold off;
    pause(0.5)
    
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
    plot(ref_points(:,1), ref_points(:,2), 'ob');
    hold on;
    plot(input_correlation_new(:,1), input_correlation_new(:,2), 'xr');
    hold off;
    
    axis equal
%     xlim([0,450]);
%     ylim([0,450]);
    
    pause(0.5);
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
