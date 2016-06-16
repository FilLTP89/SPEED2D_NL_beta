function [] = GUI_synthetics2ann_matchup()
    %% GLOBAL
    global mon nss sps hbs ann smr out S data
    %% SET-UP
    mon.status = 0;
    plot_set_up;
    S.bcc = [0.94 0.94 0.94];
    S.acc = [0.92 0.92 0.92];
    S.rcc = [1.00 0.60 0.60];
    
    %% MAIN GUIDE
    S.fh = figure('units','pixels',...
        'position',[375 600 976 60],...
        'menubar','none',...
        'name','MAIN MENU',...
        'numbertitle','off',...
        'resize','off');
    
    S.pb(1) = uicontrol(S.fh,...
        'style','push',...
        'unit','pix',...
        'position',[5 5 156 50],...
        'string','MONITOR',...
        'callback',{@pb_call});
    
    S.pb(2) = uicontrol(S.fh,...
        'style','push',...
        'unit','pix',...
        'position',[166 5 156 50],...
        'string','SIMULATION',...
        'callback',{@pb_call});
    
    S.pb(3) = uicontrol(S.fh,...
        'style','push',...
        'unit','pix',...
        'position',[327 5 156 50],...
        'string','S&P96',...
        'callback',{@pb_call});
    
    S.pb(4) = uicontrol(S.fh,...
        'style','push',...
        'unit','pix',...
        'position',[488 5 156 50],...
        'string','LF*HF=BB',...
        'callback',{@pb_call});
    
    S.pb(5) = uicontrol(S.fh,...
        'style','push',...
        'unit','pix',...
        'position',[649 5 156 50],...
        'string','ANN',...
        'callback',{@pb_call});
    
    S.pb(6) = uicontrol(S.fh,...
        'style','push',...
        'unit','pix',...
        'position',[810 5 156 50],...
        'string','MATCHUP',...
        'callback',{@pb_call});
    
    uiwait(S.fh);
    
    return
end

function [] = pb_call(varargin)
    global mon nss sps hbs ann smr S
    % hObject    handle to edit1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Callback for pushbutton.
    hob = varargin{1};
    hnd = varargin{2}.Source;
    press_button(hob);
    
    % Get the structure.
    switch hob
        case S.pb(1)
            %% DEFINE MONITOR STRUCTURE
            mon.status(1)=0;
            GUI_define_monitors;
            disp('-----> METADATA FILES : OK!');
            set(S.pb(1),'str','OK!','backg',S.acc);
        case S.pb(2)
            %% NUMERICAL SIMULATIONS: PARSE AND COMPUTE SPECTRA
            if all(mon.status)
                nss.status=0;
                GUI_ns_setup;
                disp('-----> NUMERICAL SIMULATIONS : OK!');
                set(S.pb(2),'str','LOADED','backg',S.acc);
            else
                disp('      ERROR: FIRST DEFINE MONITORS!');
            end
        case S.pb(3)
            %% GENERATE SABETTA PUGLIESE SYNTHETICS
            if all(mon.status)
                sps.status=0;
                GUI_sp_setup;
                disp('-----> SABETTA-PUGLIESE SYNTHETICS: GENERATED!');
                set(S.pb(3),'str','OK!','backg',S.acc)
            else
                disp('      ERROR: FIRST DEFINE MONITORS!');
            end
        case S.pb(4)
            %% HYBRIDIZE SYNTHETICS
            if all(mon.status)&&nss.status&&sps.status
                hbs.status=0;
                GUI_hb_setup;
                disp('-----> HYBRIDIZATION: DONE!');
                set(S.pb(4),'str','OK!','backg',S.acc);
            else
                disp('      ERROR: FIRST DEFINE MONITORS!');
            end
        case S.pb(5)
            %% LOAD TRAINED ANN
            ann.status=zeros(2,1);
            GUI_nn_setup;
            disp('-----> ANN : LOADED!');
            set(S.pb(5),'str','LOADED','backg',S.acc);
        case S.pb(6)
            %% SPECTRAL MATCHING
            if all(mon.status)&&hbs.status&&any(ann.status)
                disp('5.     APPLY ANN: ');
                [~,~,ib] = intersect(hbs.mon.cp,ann.cp,'stable');
                ann.cp = ann.cp(ib);
                trs = ann2hbs_train(hbs,ann);
                disp('-----> ANN : APPLIED!');
                disp('5.     SPECTRAL MATCHING: ');
                out=synthetics2ann_spectral_matching(hbs,trs);
                save(fullfile(wd,'out.mat'),out);
                disp('-----> SPECTRA : MATCHED!');
                set(S.pb(6),'str','OK!','backg',S.acc);
                disp('6. ANALYSIS: COMPLETED!');
                pause(0.01);
                disp('GOODBYE!')
                close(S.fh);
            end
    end
    press_button(hob,'OK!');
    return
end