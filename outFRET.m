function outFRET(data)
% outFRET() displays FRET data that is output from the analysis algorithms
% in a GUI window, allowing users to toggle between efficiency and ratio
% images or to select different sample ROIs

% Written by Javier Manzella-Lapeira for the LIG Imaging Core, 2017
% NIAID/NIH

f_outFRET = figure('Visible','off','Position',[360,500,450,285],...
    'NumberTitle','off');
f_outFRET.Name = 'FRET Data Output';

hEff = uicontrol('Style','pushbutton','String','Efficiency',...
    'Position',[315,180,70,25],'FontSize',12,'Callback',@effbutton_Callback);
hRat = uicontrol('Style','pushbutton','String','Ratios',...
    'Position',[315,135,70,25],'FontSize',12,'Callback',@ratbutton_Callback);
htext = uicontrol('Style','text','String','Select Data to Plot',...
    'Position',[305,210,120,50],'FontSize',14);
ha = axes('Units','Pixels','Position',[50,60,200,185]);
% determine number of steps for the slider
sz = size(data);
steps = sz(1);
hslider = uicontrol('Style','Slider','Value',1,'Min',1,'Max',steps,...
    'SliderStep',[1/(steps-1),1/(steps-1)],'Position',[50,40,200,20],...
    'Callback',@slider_Callback);

f_outFRET.Visible = 'on';
f_outFRET.Units = 'Normalized';
hEff.Units = 'Normalized';
hRat.Units = 'Normalized';
htext.Units = 'Normalized';
ha.Units = 'Normalized';
hslider.Units = 'Normalized';

frame = 1;
mode = '';

    function effbutton_Callback(source,eventdata)
       % This is what happens when 'Efficiency' button is clicked
       Eff_Image = data{frame,2};
       imshow(Eff_Image,[0 100],'Colormap',jet)
       c = colorbar;
       c.Label.String = '% FRET Efficiency';
       mode = 'efficiency';
    end

    function ratbutton_Callback(source,eventdata)
       % This is what happens when 'Ratio' button is clicked
       Rat_Image = data{frame,3};
       imshow(Rat_Image,[0 100],'Colormap',jet)
       c = colorbar;
       c.Label.String = 'Channel Ratios (Percentages)';
       mode = 'ratio';
    end

    function slider_Callback(hObj,~)
        % When the slider is used
        sample_num = get(hObj,'Value');
        %fprintf('Slider value is: %d\n', sample_num);
        frame = sample_num;
        switch mode
            case 'efficiency'
                effbutton_Callback()
            case 'ratio'
                ratbutton_Callback()
        end
    end

end