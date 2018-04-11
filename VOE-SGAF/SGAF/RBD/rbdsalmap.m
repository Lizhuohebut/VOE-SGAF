%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This code is for [1], and can only be used for non-comercial purpose. If
% you use our code, please cite [1].
% 
% Code Author: Wangjiang Zhu
% Email: wangjiang88119@gmail.com
% Date: 3/24/2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This demo shows how to use Saliency Optimization[1], as well as
% Saliency Filter[2], Geodesic Saliency[3], and Manifold Ranking[4].

% [1] Wangjiang Zhu, Shuang Liang, Yichen Wei, and Jian Sun. Saliency
% Optimization from Robust Background Detection. In CVPR, 2014.

% [2] F. Perazzi, P. Krahenbuhl, Y. Pritch, and A. Hornung. Saliency
% filters: Contrast based filtering for salient region detection.
% In CVPR, 2012.

% [3] Y.Wei, F.Wen,W. Zhu, and J. Sun. Geodesic saliency using
% background priors. In ECCV, 2012.

% [4] C. Yang, L. Zhang, H. Lu, X. Ruan, and M.-H. Yang. Saliency
% detection via graph-based manifold ranking. In CVPR, 2013.

%%
function partialImg=rbdsalmap(srcImg,options,frameName)
% clear, clc, 
% close all
% addpath(genpath('Funcs'));

%% 1. Parameter Settings
doFrameRemoving = false;
useSP = true;           %You can set useSP = false to use regular grid for speed consideration
% doMAEEval = true;       %Evaluate MAE measure after saliency map calculation
% doPRCEval = true;       %Evaluate PR Curves after saliency map calculation

% SRC = 'Data\SRC';       %Path of input images
% BDCON = 'Data\BDCON';   %Path for saving bdCon feature image
% RES = 'Data\Res';       %Path for saving saliency maps
% srcSuffix = '.png';     %suffix for your input image

% if ~exist(BDCON, 'dir')
%     mkdir(BDCON);
% end
% if ~exist(RES, 'dir')
%     mkdir(RES);
% end

%% 2. Saliency Map Calculation
% files = dir(fullfile(SRC, strcat('*', srcSuffix)));
% % if matlabpool('size') <= 0
% %     matlabpool('open', 'local', 8);
% % end
% % parfor k=1:length(files)
% for k=1:length(files)
%     disp(k);
%     srcName = files(k).name;
%     noSuffixName = srcName(1:end-length(srcSuffix));
%     %% Pre-Processing: Remove Image Frames
%     srcImg = imread(fullfile(SRC, srcName));
    if doFrameRemoving
        [noFrameImg, frameRecord] = removeframe(srcImg, 'sobel');
        [h, w, chn] = size(noFrameImg);
    else
        noFrameImg = srcImg;
        [h, w, chn] = size(noFrameImg);
        frameRecord = [h, w, 1, h, 1, w];
    end
    %% Segment input rgb image into patches (SP/Grid)
    pixNumInSP = 600;                           %pixels in each superpixel
    spnumber = round( h * w / pixNumInSP );     %super-pixel number for current image
    
    if useSP
        [idxImg, adjcMatrix, pixelList] = SLIC_Split(noFrameImg, spnumber);
    else
        [idxImg, adjcMatrix, pixelList] = Grid_Split(noFrameImg, spnumber);        
    end
  
    %% Get super-pixel properties
    spNum = size(adjcMatrix, 1);
    meanRgbCol = GetMeanColor(noFrameImg, pixelList);
    meanLabCol = colorspace('Lab<-', double(meanRgbCol)/255);
    meanPos = GetNormedMeanPos(pixelList, h, w);
    bdIds = GetBndPatchIds(idxImg);
    colDistM = GetDistanceMatrix(meanLabCol);
    posDistM = GetDistanceMatrix(meanPos);
    [clipVal, geoSigma, neiSigma] = EstimateDynamicParas(adjcMatrix, colDistM);
    
    %% Saliency Optimization
    [bgProb, bdCon, bgWeight] = EstimateBgProb(colDistM, adjcMatrix, bdIds, clipVal, geoSigma);
    wCtr = CalWeightedContrast(colDistM, posDistM, bgProb);
    optwCtr = SaliencyOptimization(adjcMatrix, bdIds, colDistM, neiSigma, bgWeight, wCtr);
    if( ~exist( fullfile( options.outfolder, 'rbdsal'), 'dir' ) )
        mkdir(fullfile( options.outfolder, 'rbdsal'));
    end
    filepath=strcat(options.outfolder,'\rbdsal\');
    smapName=fullfile( filepath ,strcat(frameName ,'.bmp'));
%     smapName=fullfile(RES, strcat(noSuffixName, '_wCtr_Optimized.png'));
    partialImg=SaveSaliencyMap(optwCtr, pixelList, frameRecord, smapName, true);
    imwrite(partialImg, [filepath 'rbd_' frameName  '.bmp']);
end   