clearvars
% 预处理
% 找到一个文件夹下的所有bmp图片，进行边缘检测后，加edge_前缀输出，只执行一次就可以了
% 否则在原文件夹下会处理越来越多的文件，且有可能报错

image_dir = 'C:\Users\jiajun\Documents\MyNutCloud\008-LaserKnife\005-QC_Based_On_Image_Match\01-Image_Data\刀具检测图片0724';
image_files = dir([image_dir,'\*.bmp']);

file_num = length(image_files);

for i=1:file_num
    image = imread([image_dir,'\',image_files(i).name]);
    image_bw = imbinarize(image, 0.5);
    image_edge = edge(image_bw, 'Canny');
    imwrite(image_edge, [image_dir,'\','edge_',image_files(i).name]);
end