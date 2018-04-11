function [count] = GetRgbHist(filename)
%GetRgbHist---��ȡͼ��ֱ��ͼ
%filename-----ͼ���ļ�����ͼ�����·��
%count--------ͼ��ֱ��ͼ

% info = imfinfo(filename);
%  I = imread(filename);
[N1,N2] = size(filename);
%info.BitDepth=24ʱ�������RGBͼ�񣬷����ǻҶ�ͼ��
% if info.BitDepth == 24 
    [count1,x] = imhist(filename(:,:,1));  %����Rͨ����ֱ��ͼ
    [count2,x] = imhist(filename(:,:,2));  %����Gͨ����ֱ��ͼ
    [count3,x] = imhist(filename(:,:,3));  %����Bͨ����ֱ��ͼ
    %��������תΪһά��ֱ��ͼ
    count = [count1,count2,count3]; 
    count = reshape(count,256*3,1);
%  else
%      count = imhist(I);
%  end

count = count/(N1*N2);  %��һ��������ͼ���������⡣
end

