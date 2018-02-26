function sort_files(analysis_type,fret_method)
%SORT_FILES(analysis_type,fret_method) sorts FRET data files into  
% folders/subfolders depending on the analysis technique. Part of the FRET
% analysis package.
% Inputs: ***leave empty to run by itself (without the FRET GUI)
%           analysis_type - mode; either 'PFRET' or 'ZEN'
%           fret_method - method; either 'se' for sensitized emission 
%                           or 'ap' for acceptor photobleaching
% Written by Javier Manzella-Lapeira on 11/2016 for the LIG Imaging Core
% NIAID/NIH

global fret_data_folder method mode sub_dir
% fret_data_folder: folder that contains all FRET images
% sub_dir_type: specifies whether you have seFRET or apFRET files
% mode: analysis mode based on input

% IF THE PROGRAM IS RUN BY ITSELF, INCLUDE THE FOLLOWING SECTION
if nargin > 0
    % ask the user to select the folder where the data files are
    folder_name = uigetdir;
    % declare global variables
    fret_data_folder = folder_name;
    method = fret_method;
    mode = analysis_type;
end

% IF FILES ARE ALREADY SORTED
check_se = exist([fret_data_folder,'/DA_Dex_Aem'],'dir');
check_ap = exist([fret_data_folder,'/DA_Aex_Aem_A'],'dir');
if check_se == 7 || check_ap == 7
    string2 = 'Files have already been sorted. Click ''OK'' to continue.';
    uiwait(msgbox(string2));
    return
end

% BEGIN sort_files()
switch mode
    case('PFRET')
        % create folders in the main fret_data_folder specified by user
        if strcmp(method,'se') == 1
            % Sensitized emission case
            sub_dir = {'A_Aex_Aem','A_Dex_Aem','A_Dex_Dem',...
                'D_Aex_Aem','D_Dex_Aem','D_Dex_Dem',...
                'DA_Aex_Aem','DA_Dex_Aem','DA_Dex_Dem'};
        elseif strcmp(method,'ap') == 1
            mkdir(fret_data_folder,'ROI');
            % Acceptor photobleaching case
            sub_dir = {'DA_Dex_Dem_A','DA_Dex_Dem_P','DA_Aex_Aem_A','DA_Aex_Aem_P'};
        end
        n = numel(sub_dir);
        wildcard_sub_dir = cell(1,n);
        for d = 1:n
            df = sub_dir{d};
            mkdir(fret_data_folder,df);
            if numel(df) == 9 || numel(df) == 11
                no_number = [df(1),'*',df(2:end),'.tif']; % put * and .tif to sort files
            elseif numel(df) == 10 || numel(df) == 12
                no_number = [df(1:2),'*',df(3:end),'.tif'];
            end
            wildcard_sub_dir{d} = no_number;
            clear df
            clear no_number
        end
        % sort files and put them in their respective folders
        % count number of files in the main directory
        fDir = dir([fret_data_folder,'/','*.tif']);
        num_frets = length(fDir);
        for m = 1:num_frets
            file = fDir(m).name;
            file_no_digs = file(regexp(file,'\D'));
            file_dir = file_no_digs(1:end-4);
            movefile([fret_data_folder,'/',file],[fret_data_folder,'/',file_dir])
        end

    case('ZEN') % update the for loop with real number of czi files in the folder
        for files = 1:num_files

        end
end

% Message to communicate user of successful data re-arrangement
string1 = 'Files have been sorted. Click ''OK'' to continue.';
uiwait(msgbox(string1));

end