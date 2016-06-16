function [] = GUI_nn_setup()
    %% ANN - DATABASE
    global mon ann Sann
    Sann.flag=0;
    Sann.fn={'...';'...';'...'};
    Sann.fh(1) = figure('units','pixels',...
        'position',[0 500 305 355],...
        'menubar','none',...
        'name','ARTIFICIAL NEURAL NETWORK',...
        'numbertitle','off',...
        'resize','off');
    % _WORKDIR_
    uicontrol(Sann.fh(1),'style','text','units','pix','position',[5 225 295 25],...
        'string','ANN-FILE');
    Sann.lb(1) = uicontrol(Sann.fh(1),'style','list',...
        'units','pix','max',3,'min',1,...
        'position',[5 200 295 25],...
        'string','ANN file...');
    
    % _DIRECTIONS_
    Sann.bg(1) = uibuttongroup(Sann.fh(1),'units','pix',...
        'pos',[5 300 295 50],'Title','Direction');
    Sann.rd(1) = uicontrol(Sann.bg(1),...
        'style','checkbox',...
        'unit','pix',...
        'position',[15 5 90 40],...
        'string','X','callback',{@tp_call,Sann});
    Sann.rd(2) = uicontrol(Sann.bg(1),...
        'style','checkbox',...
        'unit','pix',...
        'position',[105 5 90 40],...
        'string','Y','callback',{@tp_call,Sann});
    Sann.rd(3) = uicontrol(Sann.bg(1),...
        'style','checkbox',...
        'unit','pix',...
        'position',[200 5 90 40],...
        'string','Z','callback',{@tp_call,Sann});
    %%
    Sann.pb(1) = uicontrol(Sann.fh(1),'style','push',...
        'units','pix',...
        'position',[105 5 95 25],...
        'string','OK','callback',{@pb_call,Sann});
    
    uiwait(Sann.fh(1)) % Wait for continue or stop button.
    
    return
end

function [] = tp_call(varargin)
    global mon ann Sann
    % hObject    handle to edit1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    hob = varargin{1};
    hnd = varargin{3};
    switch hob
        case Sann.rd(1)
            % _parse trained ANN network - x direction_
            if ismember({'x'},mon.cp)
                [fn,pt] = uigetfile('*.mat','Select ANN File: ',...
                    'MultiSelect','off');
                if ~strcmpi(pt(end),filesep)
                    Sann.fn{1}=fullfile(pt,filesep,fn);
                else
                    Sann.fn{1}=fullfile(pt,fn);
                end
                ann.status(1) = 1;
                TnC = GUI_13([500 500 305 255],'CORNER PERIOD',[.01 3],0.75);
                ann.x = nn_parser(TnC,Sann.fn{1});
                disp('-----> ANN(X): LOADED!');
            else
                warning('ERROR: X COMPONENT NOT SELECTED!');
            end
        case Sann.rd(2)
            % _parse trained ANN network - y direction_
            if ismember({'y'},mon.cp)
                [fn,pt] = uigetfile('*.mat','Select ANN File: ',...
                    'MultiSelect','off');
                if ~strcmpi(pt(end),filesep)
                    Sann.fn{2}=fullfile(pt,filesep,fn);
                else
                    Sann.fn{2}=fullfile(pt,fn);
                end
                ann.status(2) = 1;
                TnC = GUI_13([500 500 305 255],'CORNER PERIOD',[.01 3],0.75);
                ann.y = nn_parser(TnC,Sann.fn{2});
                disp('-----> ANN(Y): LOADED!');
            else
                warning('ERROR: Y COMPONENT NOT SELECTED!');
            end
        case Sann.rd(3)
            % _parse trained ANN network - z direction_
            if ismember({'z'},mon.cp)
                [fn,pt] = uigetfile('*.mat','Select ANN File: ',...
                    'MultiSelect','off');
                if ~strcmpi(pt(end),filesep)
                    Sann.fn{3}=fullfile(pt,filesep,fn);
                else
                    Sann.fn{3}=fullfile(pt,fn);
                end
                ann.status(3) = 1;
                TnC = GUI_13([500 500 305 255],'CORNER PERIOD',[.01 3],0.75);
                ann.z = nn_parser(TnC,Sann.fn{3});
                disp('-----> ANN(Z): LOADED!');
            else
                warning('ERROR: Z COMPONENT NOT SELECTED!');
            end
    end
    [outstring,newpos] = textwrap(Sann.lb(1),Sann.fn);
    oldpos=get(Sann.lb(1),'pos');
    oldpos(end)=newpos(end);
    set(Sann.lb(1),'String',outstring,'Position',oldpos);
    return
end

function [] = pb_call(varargin)
    global Sann ann
    % Callback for pushbutton.
    if varargin{1} == Sann.pb(1)
        %%
        % _exit_
        if any(ann.status)
            ann.cp = fieldnames(ann);
            close(Sann.fh(1))  % Found the one we are looking for.
        end
    end
    return
end