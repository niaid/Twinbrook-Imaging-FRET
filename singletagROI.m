function ROIs = singletagROI(name,imagesD,imagesF,imagesA)
% ROIs = singletagROI()
% singletagROI is part of the FRET module. This function lets the user pick
% out either the donor or the acceptor ROIs for each channel

initM = ['Please select the ROIs for the ',name,' images. Click OK to continue.'];
uiwait(msgbox(initM));

samples = numel(imagesF);
ROIs = cell(samples,3);

for s = 1:samples
    VisualIm = imadjust(imagesF(s));
    [~,perim] = imcrop(VisualIm);
    ROI_f = imcrop(imagesF(s),perim);
    ROI_d = imcrop(imagesD(s),perim);
    ROI_a = imcrop(imagesA(s),perim);

    ROIs{s,1} = ROI_d;
    ROIs{s,2} = ROI_f;
    ROIs{s,3} = ROI_a;
end

