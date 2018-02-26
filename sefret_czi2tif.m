function sefret_czi2tif()
% sefret_czi2tif() takes the input CZI files from the user's specified FRET
% analysis folder and converts the files into single-plane TIF files that
% will then be analyzed by the FRET algorithm.
% No explicit inputs/outputs - the function creates TIF files in the folder
%   where the CZI files are located.
% Written by Javier Manzella-Lapeira for the LIG Imaging Core, 2017
% NIAID/NIH

global fret_data_folder

check_se = exist([fret_data_folder,'/1'],'dir');
if check_se == 7
    string1 = 'Files have already been sorted. Click ''OK'' to continue.';
    uiwait(msgbox(string1));
    return
end

DOdir = dir([fret_data_folder,'/c*a*.czi']);
DOnum = length(DOdir);
AOdir = dir([fret_data_folder,'/v*.czi']);
AOnum = length(AOdir);
DAdir = dir([fret_data_folder,'/c*v*.czi']);
DAnum = length(DAdir);

% Loop through donor-only, DO 
mkdir(fret_data_folder,'Donor');
for i = 1:DOnum
    do_stack = DOdir(i).name;
    DO_stack_data = bfopen([fret_data_folder,'/',do_stack]);
    DO_matrix = DO_stack_data{1,1};
    DOframe1 = [fret_data_folder,'/Donor/',num2str(i),'DO_D.tif'];
    DOframe2 = [fret_data_folder,'/Donor/',num2str(i),'DO_F.tif'];
    imwrite(DO_matrix{1,1},DOframe1)
    imwrite(DO_matrix{2,1},DOframe2)
end
% Loop through acceptor-only, AO
mkdir(fret_data_folder,'Acceptor');
for i = 1:AOnum
    ao_stack = AOdir(i).name;
    AO_stack_data = bfopen([fret_data_folder,'/',ao_stack]);
    AO_matrix = AO_stack_data{1,1};
    AOframe2 = [fret_data_folder,'/Acceptor/',num2str(i),'AO_F.tif'];
    AOframe3 = [fret_data_folder,'/Acceptor/',num2str(i),'AO_A.tif'];
    imwrite(AO_matrix{2,1},AOframe2)
    imwrite(AO_matrix{3,1},AOframe3)
end
% Loop through donor-acceptor pair, DA
for i = 1:DAnum
    da_stack = DAdir(i).name;
    da_stack_data = bfopen([fret_data_folder,'/',da_stack]);
    da_matrix = da_stack_data{1,1};
    Aframe1 = [fret_data_folder,'/',num2str(i),'/DA_D.tif'];
    Aframe2 = [fret_data_folder,'/',num2str(i),'/DA_F.tif'];
    Aframe3 = [fret_data_folder,'/',num2str(i),'/DA_A.tif'];
    df = num2str(i);
    mkdir(fret_data_folder,df);
    imwrite(da_matrix{1,1},Aframe1)
    imwrite(da_matrix{2,1},Aframe2)
    imwrite(da_matrix{3,1},Aframe3)
end

msgbox('TIFF files have been written from CZI stacks.')

end