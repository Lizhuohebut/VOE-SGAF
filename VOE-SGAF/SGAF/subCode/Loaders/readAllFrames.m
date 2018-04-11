function  [oframes,frames, names, height,width,nframe ] = readAllFrames(options)

    frameFiles = imdir(fullfile(options.infolder));
    nframe = length( frameFiles);
    frames = cell( nframe, 1 );
    oframes = cell( nframe, 1 );
    names = cell( nframe, 1 );
    for index = 1: nframe 
        [~, frameName] = fileparts(frameFiles(index).name);
        if exist(fullfile(options.infolder, [frameName '.png']),'file')
            frame = imread(fullfile(options.infolder, [frameName '.png']));
        elseif exist(fullfile(options.infolder, [frameName '.jpg']),'file')
            frame = imread(fullfile(options.infolder, [frameName '.jpg']));
        elseif exist(fullfile(options.infolder, [frameName '.bmp']),'file')
            frame = imread(fullfile(options.infolder, [frameName '.bmp']));
        end
        oframes{index}=frame;
        %图像平滑
        frame=imfilter(frame,fspecial('gaussian',7,1.5),'same','replicate');
        %frame输入图像，fspecial('gaussian',7,1.5)滤波掩膜，same输出图像的大小与输入图像的大小相同,tereplica图像大小通过复制外边界的值来扩展
        %7表示模板尺寸7*7,1.5为滤波器的标准值，单位为像素
        frames{ index } = double(frame);
        names{ index } =  frameName;
    end
    [ height,width ] = size(frame(:,:,1));
end
