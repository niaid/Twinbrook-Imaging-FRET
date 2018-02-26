function ROIs = ROI_selector(imagesD, imagesF, imagesA)
% ROI_selector(imagesD,imagesF,imagesA) takes cell matrices with FRET
% images and lets the user select any number of ROIs within each one of 
% the images.
%
% Inputs:    imagesD, F, or A - one or more cell matrices containinig FRET
%               images. The D, F, and A initials refer to the acquired 
%               channel; donor, fret, or acceptor.
% Outputs: ROIs - cell matrix with the ROI image data for each user-defined
%               ROI in each sample.
% Written by Javier Manzella-Lapeira for the LIG Imaging Core, 2017
% NIAID/NIH

samples = numel(imagesF);
ROIs = cell(samples,3);

for s = 1:samples
    k = 1;
    % Message to communicate user of ROI selection steps
    string1 = 'Select an ROI to be analyzed. Click ''OK'' to continue.';
    uiwait(msgbox(string1));
    
    VisualIm = imadjust(imagesF(s));
    [~,perim] = imcrop(VisualIm);
    
    ROI_f{k} = imcrop(imagesF(s),perim);
    ROI_d{k} = imcrop(imagesD(s),perim);
    ROI_a{k} = imcrop(imagesA(s),perim);
    
    goAgain = questdlg('Do you want to select another ROI?');

    while strcmp(goAgain,'Yes') == 1
        k = k + 1;
        [~,perim] = imcrop(VisualIm);
        ROI_d{k} = imcrop(imagesD(s),perim);
        ROI_f{k} = imcrop(imagesF(s),perim);
        ROI_a{k} = imcrop(imagesA(s),perim);
        goAgain = questdlg('Do you want to select another ROI?');
    end
    ROIs{s,1} = ROI_d;
    ROIs{s,2} = ROI_f;
    ROIs{s,3} = ROI_a;
end