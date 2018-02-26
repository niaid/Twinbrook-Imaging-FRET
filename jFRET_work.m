function out = jFRET_work(method,mode)
% jFRET_work() is a function from the FRET module that processes the data
% with the adequate algorithm and outputs the FRET efficiencies for the
% user-defined ROIs and as a pixel-by-pixel manner.
% Written by Javier Manzella-Lapeira for the LIG Imaging Core, 2017
% NIAID/NIH

global fret_data_folder Gfactor coloc r_thresh mlimits ap

ap = str2double(ap); % acceptor photobleaching threshold
switch mode
    case 'PFRET' %multiple files
        if strcmp(method,'se') == 1
            % sort files
            nDA = dir([fret_data_folder,'/c*v*.czi']);
            sefret_czi2tif();
            nDA = length(nDA);
            grouped = cell(nDA,3);
            % Remove background from donor & acceptor
            string1 = 'Please select background for the Donor images. Click ''OK'' to continue.';
            uiwait(msgbox(string1));
            [DO_D, DO_F, ~] = backg_FRET('Donor');
            string2 = 'Please select background for the Acceptor images. Click ''OK'' to continue.';
            uiwait(msgbox(string2));
            [~, AO_F, AO_A] = backg_FRET('Acceptor');
            % Calculate donor bleedthrough
            nDO = numel(DO_D);
            DSBT_m = zeros(nDO,1);
            string3 = 'Please select Donor Only ROIs. Click ''OK'' to continue.';
            uiwait(msgbox(string3));
            for d = 1:nDO
                f1 = figure('Name','Donor Only','NumberTitle','off');
                [~,roi_DO] = imcrop(imadjust(DO_D{d}));
                close(f1), clear f1
                DO_Dm = double(imcrop(DO_D{d},roi_DO));
                DO_Fm = double(imcrop(DO_F{d},roi_DO));
                DSBT_m(d) = mean(mean(DO_Fm./DO_Dm));
            end
            DSBT = mean(DSBT_m);
            % Calculate acceptor bleedthrough
            nAO = numel(AO_A);
            ASBT_m = zeros(nAO,1);
            string4 = 'Please select Acceptor Only ROI. Click ''OK'' to continue.';
            uiwait(msgbox(string4));
            for a = 1:nAO
                f1 = figure('Name','Acceptor Only','NumberTitle','off');
                [~,roi_AO] = imcrop(imadjust(AO_A{a}));
                close(f1), clear f1
                AO_Am = double(imcrop(AO_A{a},roi_AO));
                AO_Fm = double(imcrop(AO_F{a},roi_AO));
                ASBT_m(d) = mean(mean(AO_Fm./AO_Am));
            end
            ASBT = mean(ASBT_m);
            % Work with FRET samples
            string5 = 'Please select FRET Sample ROI. Click ''OK'' to continue.';
            for k = 1:nDA
                subfolder = [fret_data_folder, '/',num2str(k)];
                [~, DA, ~] = backg_FRET(subfolder);
                [r,c,~] = size(DA);
                DA_F = double(DA(:,:,1));
                DA_D = double(DA(:,:,2));
                DA_A = double(DA(:,:,3));
                Eff = zeros(r,c);
                DAratio = zeros(r,c);
                for i = 1:r
                    for j = 1:c
                        if DA_F(i,j)<250
                            Eff(i,j) = 0;
                            DAratio(i,j) = 0;
                        else
                            Eff(i,j) = seFRETmath(Gfactor,DSBT,ASBT,[DA_F(i,j) DA_D(i,j) DA_A(i,j)]);
                            DAratio(i,j) = DA_A(i,j)/DA_D(i,j);
                        end
                    end
                end
                DAratioPre = DAratio;
                if coloc
                    vDA_D = reshape(DA_D,numel(DA_D),1);
                    vDA_A = reshape(DA_A,numel(DA_A),1);
                    f4 = figure('Name','Colocalization Scatter');
                    if mlimits
                        hold on, scatter(vDA_D,vDA_A,'xlabel','Donor Channel','ylabel','Acceptor Channel')
                        xlim([0 max(vDA_D)+100]), yim([0 max(vDA_A)+100])
                        p = polyfit(vDA_D,vDA_A,1);
                        px = linspace(1,max(vDA_D));
                        py = p(1).*px + P(2); plot(px,py,'r','LineWidth',4),
                        [x,y] = getpts(f4); % rect = getrect(f4);
                        for i = 1:r
                            for j = 1:c
                                if DA_D(i,j) < min(x) || DA_A(i,j) < min(y)
                                    DAratio(i,j) = 0;
                                elseif DA_D(i,j) > max(x) || DA_A(i,j) > max(y)
                                    DAratio(i,j) = 0;
                                else
                                    DAratio(i,j) = 1;
                                end
                            end
                        end
                        Eff = Eff.*DAratio;
                        DA_F = DA_F.*DAratio;
                        DA_D = DA_D.*DAratio;
                        DA_A = DA_A.*DAratio;
                    else
                        cf = fit(vDA_D,vDA_A,'poly1');
                        plot(cf,vDA_D,vDA_A)
                        coeffs = coeffvalues(cf);
                        mean_slope = coeffs(1);
                        ranges = confint(cf);
                        half_int = (ranges(2,1)-ranges(1,1))/2;
                        sDev = half_int*sqrt(numel(vDA_D))/1.96; % 1.96 is the z value for 95% confidence interval of normal distribution
                        Rrange = [(mean_slope-sDev) (mean_slope+sDev)];
                        DAratio(DAratio<Rrange(1)) = 0;
                        DAratio((DAratio>Rrange(1))&(DAratio<Rrange(2))) = 1;
                        DAratio(DAratio>Rrange(2)) = 0;
                        Eff = Eff.*DAratio;
                        DA_F = DA_F.*DAratio;
                        DA_D = DA_D.*DAratio;
                        DA_A = DA_A.*DAratio;
                    end
                end
                uiwait(msgbox(string5));
                f3 = figure('Name','FRET sample','NumberTitle','off');
                [~,roi_DA] = imcrop(imadjust(DA(:,:,1)));
                close(f3), clear f3
                % Pixel by pixel
                Eroi = imcrop(Eff,roi_DA);
                meanE = mean(Eroi(Eroi>0.05));
                % ROI averaged E
                DA_Froi = imcrop(DA_F,roi_DA);
                DA_Droi = imcrop(DA_D,roi_DA);
                DA_Aroi = imcrop(DA_A,roi_DA);
                mDA_Froi = mean(DA_Froi(DA_Froi>250));
                mDA_Droi = mean(DA_Droi(DA_Droi>250));
                mDA_Aroi = mean(DA_Aroi(DA_Aroi>250));
                EffROI = seFRETmath(Gfactor,DSBT,ASBT,[mDA_Froi mDA_Droi mDA_Aroi]);
                % Whole cell
                fullE = mean(Eff(Eff>0.05));
                Eff = Eff.*100;
                meanEs = [meanE EffROI fullE];
                grouped{k,1} = meanEs;
                grouped{k,2} = Eff;
                grouped{k,3} = DAratioPre;
            end
            out = grouped;
        elseif strcmp(method,'ap') == 1
            % Sort files into subfolders
            n = dir([fret_data_folder,'/*.czi']);
            n = (length(n))/2;
            apfret_czi2tif();
            grouped = cell(n,3);
            for k = 1:n
                sub_folder = [fret_data_folder, '/',num2str(k)];
                % Background noise removal
                [D, ~, A] = backg_FRET(sub_folder);
                [r,c,~] = size(D);
                Dpre = double(D(:,:,1));
                Dpost = double(D(:,:,2));
                Apre = double(A(:,:,1));
                Apost = double(A(:,:,2));
                Eff = zeros(r,c);
                Aratio = zeros(r,c);
                for i = 1:r
                    for j = 1:c
                        if Dpre(i,j)<250
                            Eff(i,j) = 0;
                            Aratio(i,j) = 0;
                        else
                            Eff(i,j) = 1 - Dpre(i,j)/Dpost(i,j);
                            Aratio(i,j) = 1 - Apost(i,j)/Apre(i,j);
                        end
                    end
                end
                Ebleach = Aratio;
                % Automatic ROI calculation (no user interference)
                bDpre = imbinarize(Dpre);
                s1 = strel('diamond',10);
                bDpre = imerode(bDpre,s1);
                fDpre = bDpre.*Dpre;
                fApre = bDpre.*Apre;
                mbDpre = mean(fDpre(fDpre>250));
                bDpos = imbinarize(Dpost);
                bDpos = imerode(bDpos,s1);
                fDpos = bDpos.*Dpost;
                fApos = bDpos.*Apost;
                mbDpos = mean(fDpos(fDpos>250));
                Eauto = 1 - mbDpre/mbDpos;
                mbApre = mean(mean(fApre));
                mbApos = mean(mean(fApos));
                mAr = 1 - mbApos/mbApre;
                if r_thresh
                    Aratio(Aratio<ap)=0;
                    Aratio(Aratio>ap)=1;
                    Eff = Eff.*Aratio;
                    Dpre = Dpre.*Aratio;
                    Dpost = Dpost.*Aratio;
                    if mAr < ap
                        Eauto = 0;
                    end
                end
                % Let user choose pre and post bleach ROIs
                string1 = 'Please select ROI for pre and post-bleach. Click ''OK'' to continue.';
                uiwait(msgbox(string1));
                f3 = figure('Name','Donor Pre-bleach','NumberTitle','off');
                [~,roi_D] = imcrop(imadjust(D(:,:,1)));
                close(f3), clear f3
                f4 = figure('Name','Donor Post-bleach','NumberTitle','off');
                [~,roiDpost] = imcrop(imadjust(D(:,:,2)));
                close(f4), clear f4
                %ROI averaged E
                DpreRoi = imcrop(Dpre,roi_D);
                mDpreRoi = mean(DpreRoi(DpreRoi>250));
                DpostRoi = imcrop(Dpost,roi_D);
                mDpostRoi = mean(DpostRoi(DpostRoi>250));
                meanEroi = 1 - mDpreRoi/mDpostRoi;
                Eroi = imcrop(Eff,roi_D);
                meanE = mean(Eroi(Eroi>0.05));
                % E with different ROIs for pre and post-bleach
                DpostRoi2 = imcrop(Dpost,roiDpost);
                mDpostRoi2 = mean(DpostRoi2(DpostRoi2>250));
                meanEroi2 = 1 - mDpreRoi/mDpostRoi2;
                Eff = Eff.*100;
                Ebleach = Ebleach.*100;
                meanEs = [meanE meanEroi meanEroi2 Eauto];
                grouped{k,1} = meanEs;
                grouped{k,2} = Eff;
                grouped{k,3} = Ebleach;
            end
            out = grouped;
        end
        fret_file = [fret_data_folder,'/Processed FRET.mat'];
        if exist(fret_file,'file') == 0
            save(fret_file, 'grouped')
        else
            mat_list = dir([fret_data_folder,'/Processed FRET*.mat']);
            num = numel(mat_list);
            num = num + 1;
            fret_file = [fret_data_folder,'/Processed FRET',num2str(num),'.mat'];
            save(fret_file, 'grouped')
        end  
    case 'ZEN' % The Zen mode refers to single experiments
        if strcmp(method,'se') == 1
            % SORT DATA IF FILES ARE CZI - STOP if no CZI or TIF in folder
            lczi = dir([fret_data_folder,'/*.czi']);
            ltif = dir([fret_data_folder,'/*.tif']);
            if ~isempty(lczi) && isempty(ltif)
                oneExCzi2tif();
            elseif isempty(lczi) && isempty(ltif)
                uiwait(msgbox('Folder doesn''t have any CZI or TIF files. Try again. Click ''OK'' to continue.'));
                return
            end
            % Remove background noise
            [DO, DA, AO]= backg_FRET();
            % Bleethrough ratio calculations
            % Donor
            string1 = 'Please select Donor Only ROI. Click ''OK'' to continue.';
            uiwait(msgbox(string1));
            f1 = figure('Name','Donor Only','NumberTitle','off');
            [~,roi_DO] = imcrop(imadjust(DO(:,:,1)));
            close(f1), clear f1
            DO_D = double(imcrop(DO(:,:,1),roi_DO));
            DO_F = double(imcrop(DO(:,:,2),roi_DO));
            DSBT = mean(mean(DO_F./DO_D));
            % Acceptor
            string2 = 'Please select Acceptor Only ROI. Click ''OK'' to continue.';
            uiwait(msgbox(string2));
            f2 = figure('Name','Acceptor Only','NumberTitle','off');
            [~,roi_AO] = imcrop(imadjust(AO(:,:,1)));
            close(f2), clear f2
            AO_A = double(imcrop(AO(:,:,1),roi_AO));
            AO_F = double(imcrop(AO(:,:,2),roi_AO));
            ASBT = mean(mean(AO_F./AO_A));
            % FRET calculations
            [r,c,~] = size(DA);
            DA_F = double(DA(:,:,1));
            DA_D = double(DA(:,:,2));
            DA_A = double(DA(:,:,3));
            Eff = zeros(r,c);
            DAratio = zeros(r,c);
            for i = 1:r
                for j = 1:c
                    if DA_F(i,j)<250
                        Eff(i,j) = 0;
                        DAratio(i,j) = 0;
                    else
                        Eff(i,j) = seFRETmath(Gfactor,DSBT,ASBT,[DA_F(i,j) DA_D(i,j) DA_A(i,j)]);
                        DAratio(i,j) = DA_A(i,j)/DA_D(i,j);
                    end
                end
            end
            DAratioPre = DAratio;
            if coloc
                vDA_D = reshape(DA_D,numel(DA_D),1);
                vDA_A = reshape(DA_A,numel(DA_A),1);
                f4 = figure('Name','Colocalization Scatter');
                if mlimits
                    hold on, scatter(vDA_D,vDA_A,'xlabel','Donor Channel','ylabel','Acceptor Channel')
                    xlim([0 max(vDA_D)+100]), yim([0 max(vDA_A)+100])
                    p = polyfit(vDA_D,vDA_A,1,'.b');
                    px = linspace(1,max(vDA_D));
                    py = p(1).*px + P(2); plot(px,py,'r','LineWidth',4),
                    [x,y] = getpts(f4); % rect = getrect(f4);
                    for i = 1:r
                        for j = 1:c
                            if DA_D(i,j) < min(x) || DA_A(i,j) < min(y)
                                DAratio(i,j) = 0;
                            elseif DA_D(i,j) > max(x) || DA_A(i,j) > max(y)
                                DAratio(i,j) = 0;
                            else
                                DAratio(i,j) = 1;
                            end
                        end
                    end
                    Eff = Eff.*DAratio;
                    DA_F = DA_F.*DAratio;
                    DA_D = DA_D.*DAratio;
                    DA_A = DA_A.*DAratio;
                else
                    cf = fit(vDA_D,vDA_A,'poly1');
                    plot(cf,vDA_D,vDA_A)
                    coeffs = coeffvalues(cf);
                    mean_slope = coeffs(1);
                    ranges = confint(cf);
                    half_int = (ranges(2,1)-ranges(1,1))/2;
                    sDev = half_int*sqrt(numel(vDA_D))/1.96; % 1.96 is the z value for 95% confidence interval of normal distribution
                    Rrange = [(mean_slope-sDev) (mean_slope+sDev)];
                    DAratio(DAratio<Rrange(1)) = 0;
                    DAratio((DAratio>Rrange(1))&(DAratio<Rrange(2))) = 1;
                    DAratio(DAratio>Rrange(2)) = 0;
                    Eff = Eff.*DAratio;
                    DA_F = DA_F.*DAratio;
                    DA_D = DA_D.*DAratio;
                    DA_A = DA_A.*DAratio;
                end
            end
            f3 = figure('Name','FRET sample','NumberTitle','off');
            [~,roi_DA] = imcrop(imadjust(DA(:,:,1)));
            close(f3), clear f3
            % pixel by pixel average E
            Eroi = imcrop(Eff,roi_DA);
            meanE = mean(Eroi(Eroi>0.05));
            % ROI averaged E
            DA_Froi = imcrop(DA_F,roi_DA);
            DA_Droi = imcrop(DA_D,roi_DA);
            DA_Aroi = imcrop(DA_A,roi_DA);
            mDA_Froi = mean(DA_Froi(DA_Froi>250));
            mDA_Droi = mean(DA_Droi(DA_Droi>250));
            mDA_Aroi = mean(DA_Aroi(DA_Aroi>250));
            EffROI = seFRETmath(Gfactor,DSBT,ASBT,[mDA_Froi mDA_Droi mDA_Aroi]);
            % Whole cell
            fullE = mean(Eff(Eff>0.05));
            Eff = Eff.*100;
            Eff2 = uint8(Eff);
            meanEper = meanE*100;
            figure('Name',['FRET Efficiency, Mean E = ',num2str(meanEper),'%'],'NumberTitle','off');
            imshow(Eff2,[0 100],'Colormap',jet)
            c = colorbar;
            c.Label.String = '% FRET Efficiency';
            meanEs = [meanE EffROI fullE];
            out{1} = meanEs;
            out{2} = Eff;
            out{3} = DAratioPre;
            fret_file = [fret_data_folder,'/Processed FRET.mat'];
            if exist(fret_file,'file') == 0
                save(fret_file, 'out')
            else
                mat_list = dir([fret_data_folder,'/Processed FRET*.mat']);
                num = numel(mat_list);
                num = num + 1;
                fret_file = [fret_data_folder,'/Processed FRET',num2str(num),'.mat'];
                save(fret_file, 'out')
            end
        elseif strcmp(method,'ap') == 1
            lczi = dir([fret_data_folder,'/*.czi']);
            if ~isempty(lczi)
                oneExCzi2tif()
            end
            ltif = dir([fret_data_folder,'/*.tif']);
            lentif = length(ltif);
            rem = lentif/4;
            if lentif>4
                apfret_czi2tif()
                ltif2 = dir([fret_data_folder,'/*.tif']);
                lentif2 = length(ltif2);
                secfolder = [fret_data_folder,'/1'];
                check = exist(secfolder,'dir');
                if check == 7
                    uiwait(msgbox('Please select the ''Multiple/Grouped'' option. Click ''OK'' to continue.'));
                    out = 'No data';
                    return
                elseif lentif2 ~= 4
                    uiwait(msgbox('Error! Check the files in your folder, then try again. Click ''OK'' to continue.'));
                    out = 'No data';
                    return
                end
            elseif rem ~= 1
                uiwait(msgbox('You need at least 4 images: pre-bleach/post-bleach for donor and acceptor channels.'));
                out = 'No data';
                return
            end
            % Background noise removal
            [D, ~, A] = backg_FRET();
            [r,c,~] = size(D);
            Dpre = double(D(:,:,1));
            Dpost = double(D(:,:,2));
            Apre = double(A(:,:,1));
            Apost = double(A(:,:,2));
            Eff = zeros(r,c);
            Aratio = zeros(r,c);
            for i = 1:r
                for j = 1:c
                    if Dpre(i,j)<250 || Dpre(i,j)>3750
                        Eff(i,j) = 0;
                        Aratio(i,j) = 0;
                    else
                        Eff(i,j) = 1 - Dpre(i,j)/Dpost(i,j);
                        Aratio(i,j) = 1 - Apost(i,j)/Apre(i,j);
                    end
                end
            end
            Ebleach = Aratio;
            % Automatic ROI calculation (no user interference)
            bDpre = imbinarize(Dpre);
            s1 = strel('diamond',10);
            bDpre = imerode(bDpre,s1);
            fDpre = bDpre.*Dpre;
            fApre = bDpre.*Apre;
            mbDpre = mean(fDpre(fDpre>250));
            bDpos = imbinarize(Dpost);
            bDpos = imerode(bDpos,s1);
            fDpos = bDpos.*Dpost;
            fApos = bDpos.*Apost;
            mbDpos = mean(fDpos(fDpos>250));
            Eauto = 1 - mbDpre/mbDpos;
            mbApre = mean(mean(fApre));
            mbApos = mean(mean(fApos));
            mAr = 1 - mbApos/mbApre;
            if r_thresh
                Aratio(Aratio<ap)=0;
                Aratio(Aratio>ap)=1;
                Eff = Eff.*Aratio;
                Dpre = Dpre.*Aratio;
                Dpost = Dpost.*Aratio;
                if mAr < ap
                    Eauto = 0;
                end
            end
            % Let user choose pre and post bleach ROIs
            f3 = figure('Name','Donor Pre-bleach','NumberTitle','off');
            [~,roi_D] = imcrop(imadjust(D(:,:,1)));
            close(f3), clear f3
            f4 = figure('Name','Donor Post-bleach','NumberTitle','off');
            [~,roiDpost] = imcrop(imadjust(D(:,:,2)));
            close(f4), clear f4
            %pixel by pixel average E
            Eroi = imcrop(Eff,roi_D);
            meanE = mean(Eroi(Eroi>0.05));
            %ROI averaged E
            DpreRoi = imcrop(Dpre,roi_D);
            mDpreRoi = mean(DpreRoi(DpreRoi>250));
            DpostRoi = imcrop(Dpost,roi_D);
            mDpostRoi = mean(DpostRoi(DpostRoi>250));
            meanEroi = 1 - mDpreRoi/mDpostRoi;
            % E with different ROIs for pre and post-bleach
            DpostRoi2 = imcrop(Dpost,roiDpost);
            mDpostRoi2 = mean(DpostRoi2(DpostRoi2>250));
            meanEroi2 = 1 - mDpreRoi/mDpostRoi2;
            % Final calculations and figure to be displayed
            Eff = Eff.*100;
            Ebleach = Ebleach.*100;
            Eff2 = uint8(Eff);
            meanEper = meanE*100;
            figure('Name',['FRET Efficiency, Mean E = ',num2str(meanEper),'%'],'NumberTitle','off');
            imshow(Eff2,[0 100],'Colormap',jet)
            c = colorbar;
            c.Label.String = '% FRET Efficiency';
            meanEs = [meanE meanEroi meanEroi2 Eauto];
            out{1} = meanEs;
            out{2} = Eff;
            out{3} = Ebleach;
            fret_file = [fret_data_folder,'/Processed FRET.mat'];
            if exist(fret_file,'file') == 0
                save(fret_file, 'out')
            else
                mat_list = dir([fret_data_folder,'/Processed FRET*.mat']);
                num = numel(mat_list);
                num = num + 1;
                fret_file = [fret_data_folder,'/Processed FRET',num2str(num),'.mat'];
                save(fret_file, 'out')
            end
        end            
end
end