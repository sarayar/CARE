% This can be called after you have run 'T_splitting.m' from the
clear;  clc; close all,


biopsy_patches_directory = 'F:\NewBatch2022\CACHE_R01_FR_Controls_Tiles\toMask'; % path to biopsy patches directories
mex colour_deconvolution.c
%% Create staining method - PLEASE DO NOT CHANGE THIS
StainingMethod.MODx_0 = 0.644211;
StainingMethod.MODy_0 = 0.716556;
StainingMethod.MODz_0 = 0.266844;
StainingMethod.MODx_1 = 0.092789;
StainingMethod.MODy_1 = 0.954111;
StainingMethod.MODz_1 = 0.283111;
StainingMethod.MODx_2 = 0.0;
StainingMethod.MODy_2 = 0.0;
StainingMethod.MODz_2 = 0.0;

dirim = dir(biopsy_patches_directory); % Get directory information (all biopsy patch directories)
for j = 1:length(dirim)
    sprintf('Creating mask of lymphocytes nuclei for %s %s',dirim(j).name);
    patient_folder = fullfile(biopsy_patches_directory,dirim(j).name); % actually the biopsy folder
    patches = dir([patient_folder '\*.png']); % Get all '.png' extensions
    for i = 1:length(patches)
        if length(patches(i).name)<3
            continue
        end
        if regexp(patches(i).name,'lymph_patch')%Don't touch
            continue
        end
        if regexp(patches(i).name,'_mask')%Don't touch
            continue
        end
        if regexp(patches(i).name,'_maask')%Don't touch
            continue
        end
        img_path = fullfile(patient_folder, patches(i).name);
        [~,patch_id,~] = fileparts(img_path);
        save_lymph_path = fullfile(patient_folder, [patch_id '_maask.png']);
        save_mask=fullfile(patient_folder, ['maask_' patch_id '.png']);
        im = imread(img_path);
        [out1, out2, out3] = colour_deconvolution(im, StainingMethod); % Extract the Red channel
        sprintf('Processing slide %s',img_path)
        %% Detecting Lympocyte
        pthr = multithresh(out1,4); % Create threshold values using otsu's method to bin pixels
        lymph = out1<pthr(2);
        se = strel('disk',2); % a structuring element for morphological dilation
        %% Dilation
        dilated = imdilate(lymph,se); % Dilation: expand boundaries of blobs. If too many objects are touching, reduce the radius of the structuring element
        imwrite(lymph, save_lymph_path);
    end
end
