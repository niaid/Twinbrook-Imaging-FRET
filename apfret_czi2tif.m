function apfret_czi2tif()
% APFRET_CZI2TIF opens the czi files from FRET experiments and saves
% individual channels in the format required for the apFRET analysis.

global fret_data_folder

check_ap = exist([fret_data_folder,'/1'],'dir');
if check_ap == 7
    string1 = 'Files have already been sorted. Click ''OK'' to continue.';
    uiwait(msgbox(string1));
    return
end
ltif = dir([fret_data_folder,'/*.czi']);
lczi = dir([fret_data_folder,'/*.czi']);
if ~isempty(lczi)
    % sort pre-bleach (a) czi's from post-bleach (p) czi's
    a_list = dir([fret_data_folder,'/*a.czi']);
    n_a = length(a_list);
    p_list = dir([fret_data_folder,'/*p.czi']);
    n_p = length(p_list);

    % catch naming convention errors
    if isempty(a_list) || isempty(p_list)
        % either rename or have the user rename the czi files...
        prompt = {'Enter naming convention for pre-bleach files (EG ''/*pre.czi'', where ''pre'' are the characters all files in the group have in common:','Enter naming convention for post-bleach files:'};
    	dlg_title = 'CZI File match prompt';
        num_lines = 1;
        names = inputdlg(prompt,dlg_title,num_lines);
        % sort pre-bleach (a) czi's from post-bleach (p) czi's
        a_list = dir([fret_data_folder,names(1)]);
        n_a = length(a_list);
        p_list = dir([fret_data_folder,names(2)]);
        n_p = length(p_list);
    end
    % Catch pre/post inequality
    if n_a ~= n_p
        num = min([n_a, n_p]);
        n_a = num; n_p = num;
    end
    % Loop through both groups to extract the pre-bleach channels
    for i = 1:n_a
        a_stack = a_list(i).name;
        a_stack_data = bfopen([fret_data_folder,'/',a_stack]);
        a_matrix = a_stack_data{1,1};
        if n_a == 1
            Aframe1 = [fret_data_folder,'/Dpre.tif'];
            Aframe3 = [fret_data_folder,'/Apre.tif'];
        else
            Aframe1 = [fret_data_folder,'/',num2str(i),'/Dpre.tif'];
            Aframe3 = [fret_data_folder,'/',num2str(i),'/Apre.tif'];
            df = num2str(i);
        end
        mkdir(fret_data_folder,df);
        imwrite(a_matrix{1,1},Aframe1)
        imwrite(a_matrix{3,1},Aframe3)
    end
    % Loop through both groups to extract the post-bleach channels
    for j = 1:n_p
        p_stack = p_list(j).name;
        p_stack_data = bfopen([fret_data_folder,'/',p_stack]);
        p_matrix = p_stack_data{1,1};
        if n_p == 1
            Aframe1 = [fret_data_folder,'/Dpost.tif'];
            Aframe3 = [fret_data_folder,'/Apost.tif'];
        else
            Aframe1 = [fret_data_folder,'/',num2str(j),'/Dpost.tif'];
            Aframe3 = [fret_data_folder,'/',num2str(j),'/Apost.tif'];
        end
        imwrite(p_matrix{1,1},Aframe1)
        imwrite(p_matrix{3,1},Aframe3)
    end
    uiwait(msgbox('TIFF files have been written from CZI stacks.'))
else
    n_tif = length(ltif);
    rem_tif = rem(n_tif,2);
    if rem_tif == 0
        n_sa = n_tiff/2;
        for k = 1:n_sa
            
        end
    else
        return
    end
end
