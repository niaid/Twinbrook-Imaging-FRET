function fret_czi2tif(sample_name,wavelength,end_folder)
% FRET_CZI2TIF() opens the czi files from FRET experiments and saves
% individual channels in the format required for the pFRET analysis.
% Written by Javier Manzella-Lapeira for the LIG Imaging Core, 2017
% NIAID/NIH

seFRET_path = ['/Users/manzellalapeij/Documents/FRET data/Organized FRET data/seFRET/',sample_name,'/',wavelength,'/',end_folder];
pFRET_path = ['/Users/manzellalapeij/Documents/FRET data/Organized FRET data/pFRET/',sample_name,'/',wavelength];
% make new folder
mkdir(pFRET_path,end_folder);
% renane the path
pFRET_path = ['/Users/manzellalapeij/Documents/FRET data/Organized FRET data/pFRET/',sample_name,'/',wavelength,'/',end_folder];

% define parameters
list = dir([seFRET_path,'/*.czi']);
n_total = length(list);
aa = sample_name(2:end-1);
donor_list = dir([seFRET_path,'/*C',aa,'A*.czi']);
n_D = length(donor_list);
fret_list = dir([seFRET_path,'/*C',aa,'V*.czi']);
n_DA = length(fret_list);
n_A = n_total - n_D - n_DA;

% Loop through donor samples
for i = 1:n_D
    imageDname = donor_list(i).name;
    Dstack_data = bfopen([seFRET_path,'/',imageDname]);
    Dstack_planes = Dstack_data{1,1};
    Dframe1 = [pFRET_path,'/D',num2str(i),'_Dex_Dem.tif'];
    Dframe2 = [pFRET_path,'/D',num2str(i),'_Dex_Aem.tif'];
    Dframe3 = [pFRET_path,'/D',num2str(i),'_Aex_Aem.tif'];
    imwrite(Dstack_planes{1,1},Dframe1)
    imwrite(Dstack_planes{2,1},Dframe2)
    imwrite(Dstack_planes{3,1},Dframe3)
end
% Loop through fret samples
for j = 1:n_DA
    imageDAname = fret_list(j).name;
    DAstack_data = bfopen([seFRET_path,'/',imageDAname]);
    DAstack_planes = DAstack_data{1,1};
    DAframe1 = [pFRET_path,'/DA',num2str(j),'_Dex_Dem.tif'];
    DAframe2 = [pFRET_path,'/DA',num2str(j),'_Dex_Aem.tif'];
    DAframe3 = [pFRET_path,'/DA',num2str(j),'_Aex_Aem.tif'];
    [r,~] = size(DAstack_planes);
    if r == 12
        imwrite(DAstack_planes{4,1},DAframe1)
        imwrite(DAstack_planes{5,1},DAframe2)
        imwrite(DAstack_planes{6,1},DAframe3)
    else
        imwrite(DAstack_planes{1,1},DAframe1)
        imwrite(DAstack_planes{2,1},DAframe2)
        imwrite(DAstack_planes{3,1},DAframe3)
    end
end
% Loop through acceptor samples
for k = 1:n_A
    n = n_A - k;
    imageAname = list(n_total-n).name;
    Astack_data = bfopen([seFRET_path,'/',imageAname]);
    Astack_planes = Astack_data{1,1};
    Aframe1 = [pFRET_path,'/A',num2str(k),'_Dex_Dem.tif'];
    Aframe2 = [pFRET_path,'/A',num2str(k),'_Dex_Aem.tif'];
    Aframe3 = [pFRET_path,'/A',num2str(k),'_Aex_Aem.tif'];
    imwrite(Astack_planes{1,1},Aframe1)
    imwrite(Astack_planes{2,1},Aframe2)
    imwrite(Astack_planes{3,1},Aframe3)
end

msgbox('TIFF files have been written from CZI stacks.')

end