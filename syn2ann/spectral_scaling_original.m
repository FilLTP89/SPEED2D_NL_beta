function [varargout] = spectral_scaling_original(varargin)
    %% *SET-UP*
    inp_dtm = varargin{1};
    inp_tha = varargin{2}(:);
    tar_vTn = varargin{3}(:);
    tar_psa = varargin{4}(:);
    tar_pga = tar_psa(1);     % target pga
    tar_nT  = numel(tar_vTn);
    %
    % _spectral matching set up_
    %
    zeta = 0.05;                 % damping coefficient
    fac  = 1;                    % resampling factor
    scl  = 1;                    % scaling factor
    ni   = 10;                   % number of iterations
    %
    % _resampling and correcting_
    %
    [obj_dtm,obj_tha,obj_ntm,~] = seismo_rsmpl(inp_dtm,inp_tha,fac,scl);

    %
    % _HF refining_
    %
    vTn_cor = [2*obj_dtm,0.05];                     % upper period of refinement
    nc      = 10;                                     % number of refinement points
    idxn    = find(tar_vTn(tar_vTn~=0) < vTn_cor(2)); % indexes
    
    if logical(isempty(idxn))
        idx_save_org(:,1)    = find(tar_vTn>vTn_cor(2));
        idx_save_new         = idx_save_org+(nc-idx_save_org(1)+1);
        %
        % _new vector of natural period_
        %
        dTn_cor              = (log10(vTn_cor(2))-log10(vTn_cor(1)))/(nc-1);
        tar_vTn_new(1:nc,1)  = (log10(vTn_cor(1)):dTn_cor:log10(vTn_cor(2)))';
        tar_vTn_new(1:nc,1)  = 10.^tar_vTn_new(1:nc,1);
        tar_vTn_new(idx_save_new,1) = tar_vTn(idx_save_org,1);
        tar_vTn_new          = [0;tar_vTn_new];
        %
        % _new vector of psa_
        %
        tar_psa_new          = interp1(tar_vTn,tar_psa,tar_vTn_new,'linear');
        tar_vTn = tar_vTn_new;
        tar_psa = tar_psa_new;
    end
    tar_nT  = numel(tar_vTn);
    
    %
    % _frequency response_
    %
%     ig=0;
%     while (2^ig<=obj_ntm);
%         ig=ig+1;
%     end
%     inp_nfr = 2^ig;
    inp_nfr = 2^nextpow2(obj_ntm);
    inp_dfr = 1/(inp_nfr-1)/obj_dtm;
    inp_vfr = (0:inp_dfr:0.5/obj_dtm)';
    inp_nfr = numel(inp_vfr);
    obj_vfr = [0;flip(1./tar_vTn(2:end));0.5/obj_dtm];
    %
    % _pad time-histories_
    %
    obj_tha(obj_ntm+1:inp_nfr)=0;
    obj_ntm = inp_nfr;
    obj_vtm = obj_dtm*(0:obj_ntm-1)';
    inp_fsa = super_fft(obj_dtm,obj_tha,0,4);
    %
    % _pseudo-spectral acceleration_
    %
    obj_psa = SDOF_response(obj_tha,obj_dtm,tar_vTn,zeta);
    
    for i_ = 2:tar_nT
        rra_in(tar_nT-i_+2) = obj_psa(i_)/tar_psa(i_);
    end
    rra_in(tar_nT+1) = obj_psa(1)/tar_psa(1);
    rra_in(1)=1;
    rra = interp1(obj_vfr,rra_in,inp_vfr,'linear');
    
    f_amax=40;
    for i_=1:ni
        obj_fsa=fft(obj_tha);
        for m_=1:inp_nfr
            obj_fsa(m_) = obj_fsa(m_)/rra(m_);
        end
        obj_fsa(inp_nfr+1) = 0;
        for m_ = inp_nfr+2:2*inp_nfr
            obj_fsa(m_) = conj(obj_fsa(2*inp_nfr-m_+2));
        end
        
        obj_tha=real(ifft(obj_fsa));
        
        obj_tha=detrend(obj_tha,'constant');
        
        % response spectrum of corrected waveform
        psa_pro = SDOF_response(obj_tha,obj_dtm,tar_vTn,zeta,1);
        
        for j_=1:tar_nT
            rra_pro(tar_nT-j_+2)=psa_pro(j_)/tar_psa(j_);
        end
        rra_pro(1)=1;
        rra = interp1(obj_vfr,rra_pro,inp_vfr,'linear');
        
        for j_=1:inp_nfr
            if (inp_vfr(j_)>f_amax)
                rra(j_)=psa_pro(1)/tar_psa(1);
            end
        end
        
    end
    [bfb,bfa,~] = create_butter_filter(3,0.05,[],0.5/obj_dtm);
    obj_tha = detrend(obj_tha);
    obj_tha = filtfilt(bfb,bfa,obj_tha);
    
    obj_thv = cumsum(obj_tha)*obj_dtm;
    obj_thv = detrend(obj_thv,'linear');
    obj_thd = cumsum(obj_thv)*obj_dtm;
    obj_thd = detrend(obj_thd,'linear');
    obj_thd = taper_fun(obj_thd,10,1,1);
    %
    % _correct PGA on time history_
    %
    [pga,ipga] = max(abs(obj_tha));
    dt_cor = 0.05;
    npun_cor = round(dt_cor./(obj_vtm(2)-obj_vtm(1)));
    if mod(npun_cor,2)==0
        npun_cor = npun_cor+1;
    end
    x = [ obj_vtm(ipga-(npun_cor-1)/2),obj_vtm(ipga),obj_vtm(ipga+(npun_cor-1)/2)];
    y = [obj_tha(ipga-(npun_cor-1)/2),tar_pga.*sign(obj_tha(ipga)),...
        obj_tha(ipga+(npun_cor-1)/2)];
    xi = obj_vtm(ipga-npun_cor/2:ipga+npun_cor/2-1);
    yi_c = interp1(x,y,xi,'pchip');
    obj_tha(ipga-(npun_cor-1)/2:ipga+(npun_cor-1)/2) = ...
        yi_c;
    if (max(abs(obj_tha))-tar_pga)>1e-3
        [pga,ipga] = max(abs(obj_tha));
        x = [ obj_vtm(ipga-(npun_cor-1)/2),obj_vtm(ipga),obj_vtm(ipga+(npun_cor-1)/2)];
        y = [obj_tha(ipga-(npun_cor-1)/2),tar_pga.*sign(obj_tha(ipga)),...
            obj_tha(ipga+(npun_cor-1)/2)];
        xi = obj_vtm(ipga-npun_cor/2:ipga+npun_cor/2-1);
        yi_c = interp1(x,y,xi,'pchip');
        obj_tha(ipga-(npun_cor-1)/2:ipga+(npun_cor-1)/2) = ...
            yi_c;
    end
    
    % check final PGA
    if abs((max(abs(obj_tha))-tar_pga)/(tar_pga))>5e-2
        disp('Check PGA adjustment!');
    end
    
    % response spectral parameters
    dTn = 0.05;
    Tmax = 5;
    Tn = (0:dTn:Tmax)';
    psa_tha_pro = SDOF_response(obj_tha',obj_dtm,Tn,zeta,1);
    
    %% *OUTPUT*
    varargout{1} = obj_dtm;
    varargout{2} = obj_tha;
    varargout{3} = Tn;
    varargout{4} = psa_tha_pro;
    varargout{5} = obj_thv;
    varargout{6} = obj_thd;
    return
end