clc
clear

addpath( genpath( '.' ) );
foldername = fileparts( mfilename( 'fullpath' ) );
% methodName = 'KCVDCA';
videoFiles = dir(fullfile(foldername, 'data', 'input'));
run('./SGAFsal.p');
