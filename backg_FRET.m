function [donor_channel, fret_channel, acceptor_channel] = backg_FRET(sample)
%backg_FR removes the background from FRET images based on user-defined
% areas
% Input: prefix initials of sample stack analyzed: DA, D, or A
% Outputs: background subtracted images of the corresponding sample
% (control donor/acceptor of FRET pair)

global fret_data_folder mode method

if strcmp(mode,'PFRET') == 1 && strcmp(method,'se') == 1
    if numel(sample) == 5
            fret_pics_path = [fret_data_folder,'/',sample];
            listDO = dir([fret_pics_path,'/*.tif']);
            nDO = (length(listDO))/2;
            gDO_D = cell(nDO,1);
            gDO_F = cell(nDO,1);
            for i = 1:nDO
                DO_D = imread([fret_pics_path,'/',num2str(i),'DO_D.tif']);
                DO_F = imread([fret_pics_path,'/',num2str(i),'DO_F.tif']);
                f1 = figure('Name','Donor Only','NumberTitle','off');
                [~,roi_DO] = imcrop(imadjust(DO_D));
                close(f1), clear f1
                bDO_D = mean(mean(imcrop(DO_D,roi_DO)));
                bDO_F = mean(mean(imcrop(DO_F,roi_DO)));
                [r,c]=size(DO_D);
                bc_DO_D = uint16(zeros(r,c));
                bc_DO_F = uint16(zeros(r,c));
                for j = 1:r
                    for k = 1:c
                        bc_DO_D(j,k) = DO_D(j,k) - bDO_D;
                        bc_DO_F(j,k) = DO_F(j,k) - bDO_F;
                        if bc_DO_D(j,k) < 0
                            bc_DO_D(j,k) = 0;
                        elseif bc_DO_F(j,k) < 0
                            bc_DO_F(j,k) = 0;
                        end
                    end
                end
                gDO_D{i} = bc_DO_D;
                gDO_F{i} = bc_DO_F;
            end
            donor_channel = gDO_D;
            fret_channel = gDO_F;
            acceptor_channel = 0;
    elseif numel(sample) == 8
            fret_pics_path = [fret_data_folder,'/',sample];
            listAO = dir([fret_pics_path,'/*.tif']);
            nAO = (length(listAO))/2;
            gAO_F = cell(nAO,1);
            gAO_A = cell(nAO,1);
            for i = 1:nAO
                AO_A = imread([fret_pics_path,'/',num2str(i),'AO_A.tif']);
                AO_F = imread([fret_pics_path,'/',num2str(i),'AO_F.tif']);
                f1 = figure('Name','Acceptor Only','NumberTitle','off');
                [~,roi_AO] = imcrop(imadjust(AO_A));
                close(f1), clear f1
                bAO_A = mean(mean(imcrop(AO_A,roi_AO)));
                bAO_F = mean(mean(imcrop(AO_F,roi_AO)));
                [r,c]=size(AO_A);
                bc_AO_A = uint16(zeros(r,c));
                bc_AO_F = uint16(zeros(r,c));
                for j = 1:r
                    for k = 1:c
                        bc_AO_A(j,k) = AO_A(j,k) - bAO_A;
                        bc_AO_F(j,k) = AO_F(j,k) - bAO_F;
                        if bc_AO_A(j,k) < 0
                            bc_AO_A(j,k) = 0;
                        elseif bc_AO_F(j,k) < 0
                            bc_AO_F(j,k) = 0;
                        end
                    end
                end
                gAO_A{i} = bc_AO_A;
                gAO_F{i} = bc_AO_F;
            end
            donor_channel = 0;
            fret_channel = gAO_F;
            acceptor_channel = gAO_A;
    else
        fret_pics_path = sample;
        DA_F = imread([fret_pics_path,'/DA_F.tif']);
        DA_D = imread([fret_pics_path,'/DA_D.tif']);
        DA_A = imread([fret_pics_path,'/DA_A.tif']);
        string1 = 'Select background ROI for the following image. Click ''OK'' to continue.';
        uiwait(msgbox(string1));
        f3 = figure('Name','FRET sample','NumberTitle','off');
        [~,roi_DA] = imcrop(imadjust(DA_F));
        close(f3), clear f3
        bDA_F = mean(mean(imcrop(DA_F,roi_DA)));
        bDA_D = mean(mean(imcrop(DA_D,roi_DA)));
        bDA_A = mean(mean(imcrop(DA_A,roi_DA)));
        [r,c] = size(DA_F);
        back_corr = uint16(zeros(r,c,3));
        back_mat = [bDA_F bDA_D bDA_A];
        pics = {DA_F,DA_D,DA_A};
        for n = 1:3
            pic = pics{n};
            avg_backg = back_mat(n);
            for j = 1:r
                for k = 1:c
                    back_corr(j,k,n) = pic(j,k) - avg_backg;
                    if back_corr(j,k,n) < 0
                        back_corr(j,k) = 0;
                    end
                end
            end
        end
    
        donor_channel = 0;
        fret_channel = back_corr; % all three images for DA
        acceptor_channel = 0;
    end
elseif strcmp(mode,'ZEN') == 1 && strcmp(method,'se') == 1
    fret_pics_path = fret_data_folder;
    AO_A = imread([fret_pics_path,'/AO_A.tif']);
    [r,c] = size(AO_A);
    AO_F = imread([fret_pics_path,'/AO_F.tif']);
    string1 = 'Please select background for the following images. Click ''OK'' to continue.';
    uiwait(msgbox(string1));
    f1 = figure('Name','Acceptor Only','NumberTitle','off');
    [~,roi_AO] = imcrop(imadjust(AO_A));
    close(f1), clear f1
    bAO_A = mean(mean(imcrop(AO_A,roi_AO)));
    bAO_F = mean(mean(imcrop(AO_F,roi_AO)));
    
    DO_D = imread([fret_pics_path,'/DO_D.tif']);
    DO_F = imread([fret_pics_path,'/DO_F.tif']);
    f2 = figure('Name','Donor Only','NumberTitle','off');
    [~,roi_DO] = imcrop(imadjust(DO_D));
    close(f2), clear f2
    bDO_D = mean(mean(imcrop(DO_D,roi_DO)));
    bDO_F = mean(mean(imcrop(DO_F,roi_DO)));
    
    DA_F = imread([fret_pics_path,'/DA_F.tif']);
    DA_D = imread([fret_pics_path,'/DA_D.tif']);
    DA_A = imread([fret_pics_path,'/DA_A.tif']);
    f3 = figure('Name','FRET sample','NumberTitle','off');
    [~,roi_DA] = imcrop(imadjust(DA_F));
    close(f3), clear f3
    bDA_F = mean(mean(imcrop(DA_F,roi_DA)));
    bDA_D = mean(mean(imcrop(DA_D,roi_DA)));
    bDA_A = mean(mean(imcrop(DA_A,roi_DA)));
    if size(AO_A) == size(DO_D)
        back_corr = uint16(zeros(r,c,7));
        back_mat = [bAO_A bAO_F bDO_D bDO_F bDA_F bDA_D bDA_A];
        pics = {AO_A,AO_F,DO_D,DO_F,DA_F,DA_D,DA_A};
        for n = 1:7
            pic = pics{n};
            avg_backg = back_mat(n);
            for j = 1:r
                for k = 1:c
                    back_corr(j,k,n) = pic(j,k) - avg_backg;
                    if back_corr(j,k,n) < 0
                        back_corr(j,k) = 0;
                    end
                end
            end
        end
    end
    donor_channel = back_corr(:,:,3:4); % images for DO
    fret_channel = back_corr(:,:,5:7); % images for DA
    acceptor_channel = back_corr(:,:,1:2); % images for AO
elseif strcmp(method,'ap') == 1
    if nargin > 0
        fret_pics_path = sample;
    else
        fret_pics_path = fret_data_folder;
    end
    Dpre = imread([fret_pics_path,'/Dpre.tif']);
    [r,c] = size(Dpre);
    Dpost = imread([fret_pics_path,'/Dpost.tif']);
    Apre = imread([fret_pics_path,'/Apre.tif']);
    Apost = imread([fret_pics_path,'/Apost.tif']);
    string1 = 'Please select background for the following images. Click ''OK'' to continue.';
    uiwait(msgbox(string1));
    f1 = figure('Name','AP FRET sample','NumberTitle','off');
    [~,roi_DA] = imcrop(imadjust(Dpre));
    close(f1), clear f1
    bDpre = mean(mean(imcrop(Dpre,roi_DA)));
    bDpost = mean(mean(imcrop(Dpost,roi_DA)));
    bApre = mean(mean(imcrop(Apre,roi_DA)));
    bApost = mean(mean(imcrop(Apost,roi_DA)));
    if size(Apre) == size(Apost)
        back_corr = uint16(zeros(r,c,4));
        back_mat = [bDpre bDpost bApre bApost];
        pics = {Dpre,Dpost,Apre,Apost};
        for n = 1:4
            pic = pics{n};
            avg_backg = back_mat(n);
            for j = 1:r
                for k = 1:c
                    back_corr(j,k,n) = pic(j,k) - avg_backg;
                    if back_corr(j,k,n) < 0
                        back_corr(j,k) = 0;
                    end
                end
            end
        end
    end
    donor_channel = back_corr(:,:,1:2);
    fret_channel = 0;
    acceptor_channel = back_corr(:,:,3:4);
end
end

