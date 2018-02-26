function oneExCzi2tif()
% oneExCzi2tif() is used with the FRET analysis module. It inputs single 
% CZI files, sorts, then saves TIF images in the same folder.
% Written by Javier Manzella-Lapeira for the LIG Imaging Core, 2017
% NIAID/NIH

global fret_data_folder method

switch method
    case 'se'
        list = dir([fret_data_folder,'/*.czi']);
        n_total = length(list);
        if n_total ~= 3
            uiwait(msgbox('You need 3 czi images for ''Single Experiment''. Select ''Multiple/Grouped'' and try again.  Click ''OK'' to continue.'));
            return
        end
        try
            donor_list = dir([fret_data_folder,'/*C*A*.czi']);
        catch
            donor_list = dir([fret_data_folder,'/*c*a*.czi']);
        end
        try
            fret_list = dir([fret_data_folder,'/*C*V*.czi']);
        catch
            fret_list = dir([fret_data_folder,'/*c*v*.czi']);
        end
        % donor only tifs
        imageDname = donor_list(1).name;
        Dstack_data = bfopen([fret_data_folder,'/',imageDname]);
        Dstack_planes = Dstack_data{1,1};
        Dframe1 = [fret_data_folder,'/DO_D.tif'];
        Dframe2 = [fret_data_folder,'/DO_F.tif'];
        imwrite(Dstack_planes{1,1},Dframe1)
        imwrite(Dstack_planes{2,1},Dframe2)
        % donor-acceptor tifs
        imageDAname = fret_list(1).name;
        DAstack_data = bfopen([fret_data_folder,'/',imageDAname]);
        DAstack_planes = DAstack_data{1,1};
        DAframe1 = [fret_data_folder,'/DA_D.tif'];
        DAframe2 = [fret_data_folder,'/DA_F.tif'];
        DAframe3 = [fret_data_folder,'/DA_A.tif'];
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
        % acceptor only tifs
        imageAname = list(3).name;
        Astack_data = bfopen([fret_data_folder,'/',imageAname]);
        Astack_planes = Astack_data{1,1};
        Aframe2 = [fret_data_folder,'/AO_F.tif'];
        Aframe3 = [fret_data_folder,'/AO_A.tif'];
        imwrite(Astack_planes{2,1},Aframe2)
        imwrite(Astack_planes{3,1},Aframe3)
    case 'ap'
        list = dir([fret_data_folder,'/*.czi']);
        n_total = length(list);
        if n_total ~= 2
            uiwait(msgbox('Only 2 czi''s needed for ''Single Experiment''; pre and post bleach. Select ''Multiple/Grouped'' and try again.  Click ''OK'' to continue.'));
            return
        end
        % sort pre-bleach (a) czi's from post-bleach (p) czi's
        try
            a_list = dir([fret_data_folder,'/*a.czi']);
        catch
            a_list = dir([fret_data_folder,'/*A.czi']);
        end
        try
            p_list = dir([fret_data_folder,'/*p.czi']);
        catch
            p_list = dir([fret_data_folder,'/*P.czi']);
        end
        % pre-bleach tifs
        a_stack = a_list(1).name;
        a_stack_data = bfopen([fret_data_folder,'/',a_stack]);
        a_matrix = a_stack_data{1,1};
        Aframe1 = [fret_data_folder,'/Dpre.tif'];
        Aframe3 = [fret_data_folder,'/Apre.tif'];
        imwrite(a_matrix{1,1},Aframe1)
        imwrite(a_matrix{3,1},Aframe3)
        % post-bleach tifs
        p_stack = p_list(1).name;
        p_stack_data = bfopen([fret_data_folder,'/',p_stack]);
        p_matrix = p_stack_data{1,1};
        Aframe1 = [fret_data_folder,'/Dpost.tif'];
        Aframe3 = [fret_data_folder,'/Apost.tif'];
        imwrite(p_matrix{1,1},Aframe1)
        imwrite(p_matrix{3,1},Aframe3)
end