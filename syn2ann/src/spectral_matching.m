%Programma per accelerogrammi spettro-compatibili da accelerogrammi reali%
function [varargout] = spectral_matching(varargin)
    %% *SET-UP*
    dt    = varargin{1};
    acc1  = varargin{2};
    T_in  = varargin{3};
    Sp_in = varargin{4};
    
    %% *PRELIMINARY ACC CORRECTION*
    scala=1;
    dt1=dt;
    fac=1;
    npun1=length(acc1);
    npun2=fac*length(acc1);
    t1=[0:dt1:(npun1-1)*dt1];
    dt=dt1/fac;
    t=[0:dt:(npun2-1)*dt];
%     acc = interp1(t1,acc1,t,'spline');
    acc = acc1';
    acc=acc*scala;
    npun=length(acc);
    
    %Butterworth acausal filter parameter
    Fc=0.05; Fh=40; Nbut=2;
    % Wn=[Fc Fh];
    Wn=Fh;
    fnyq=1/2/dt;
    [BuB,BuA]=butter(Nbut,Wn./fnyq,'low');
    
    % End input parameters
    
    % baseline correction
    %% >>>>>>>> FG FIX
%     acc=detrend(acc,'linear');
    %% <<<<<<<< FG FIX
    acc=filtfilt(BuB,BuA,acc);
    amax=max(abs(acc));
    
    %Calcolo della FFT dell'accelerogramma %
    ig=0;
    while (2^ig<=npun);
        ig=ig+1;
    end
    Nfft=2^ig; %numero di punti su cui viene calcolata la FFT%
    durata=(Nfft-1).*dt; %durata del segnale che include anche i punti introdotti per il calcolo della FFT%
    df=1/durata;
    freq=0:df:1/2/dt;
    
    acc(npun+1:Nfft)=0;
    vel=cumsum(acc).*dt;
    dis=cumsum(vel).*dt;
    npun=Nfft;
    t=[0:dt:(npun-1)*dt];
    ACC=dt*fft(acc,Nfft);
    
    ACC=fft(acc);
    
    for i=2:length(T_in),
        Sp_acc(i)=4*pi^2*disp_spectra(acc,dt,T_in(i),0.05)./T_in(i)^2;
    end
    Sp_acc(1)=max(abs(acc));
    
    % compute the ratio of the inpute PSA vs the target PSA
    
    for i=2:length(T_in),
        freq_in(length(T_in)-i+2)=1/T_in(i);
        Rapp_spe_in(length(T_in)-i+2)=Sp_acc(i)/Sp_in(i);
    end
    freq_in(length(T_in)+1)=1/2/dt;
    Rapp_spe_in(length(T_in)+1)=Sp_acc(1)/Sp_in(1);
    freq_in(1)=0;
    Rapp_spe_in(1)=1;
    Rapp_spe = interp1(freq_in,Rapp_spe_in,freq,'linear');
    nfreq=length(freq);

    %% >>>>>>>> FG FIX
    pf_val = -imag(ACC(1:nfreq))./pi./freq;
    pf_val = pf_val(2:end);
    
    %         thv = avd_diff(dt,acc_pro);
    %         pf_val = -2*real(fft(thv(:)',numel(freq)));
    pf_pos = find(pf_val>=0);
    pf_neg = find(pf_val<0);
    
    rapp_spe = Rapp_spe(2:end);
    A2 = sum(rapp_spe(pf_pos).*pf_val(pf_pos));
    A1 = -sum(pf_val);
    A0 = sum(rapp_spe(pf_neg).*pf_val(pf_neg));
    qf = roots([A2,A1,A0]);
    
    qf = qf(qf>0);
    
    rapp_spe(pf_pos) = qf.*rapp_spe(pf_pos);
    rapp_spe(pf_neg) = (1./qf).*rapp_spe(pf_neg);
    Rapp_spe(2:end) = rapp_spe;
    %% <<<<<<<< FG FIX

    niter=5; % number of iterations
    
    acc_pro=acc;
    ACC_PRO=fft(acc_pro);
    for k=1:niter
        
        for m=1:nfreq
            ACC_PRO(m)=ACC_PRO(m)/Rapp_spe(m);
        end
        ACC_PRO(nfreq+1)=0;
        for m=nfreq+2:2*nfreq
            ACC_PRO(m)=conj(ACC_PRO(2*nfreq-m+2));
        end
        
        acc_pro=real(ifft(ACC_PRO));
        %% >>>>>>>> FG FIX
%         acc_pro=detrend(acc_pro,'linear');
        %% <<<<<<<< FG FIX
        ACC_PRO = fft(acc_pro);

        %% >>>>>>>> FG FIX
        pf_val = -imag(ACC_PRO(1:nfreq))./pi./freq;
        pf_val = pf_val(2:end);
        
        %         thv = avd_diff(dt,acc_pro);
        %         pf_val = -2*real(fft(thv(:)',numel(freq)));
        pf_pos = find(pf_val>=0);
        pf_neg = find(pf_val<0);
        %% <<<<<<<< FG FIX

        % response spectrum of corrected waveform
        for i=2:length(T_in)
            Sp_acc_pro(i)=4*pi^2*disp_spectra(acc_pro,dt,T_in(i),0.05)./T_in(i)^2;
        end
        Sp_acc_pro(1)=max(abs(acc_pro));
        
        for i=1:length(T_in)
            Rapp_spe_pro(length(T_in)-i+2)=Sp_acc_pro(i)/Sp_in(i);
        end
        Rapp_spe_pro(1)=1;
        Rapp_spe = interp1(freq_in,Rapp_spe_pro,freq,'linear');
        f_amax=40;
        for i=1:length(freq)
            if (freq(i)>f_amax)
                Rapp_spe(i)=Sp_acc_pro(1)/Sp_in(1);
            end
        end
	%% >>>>>>>> FG FIX
        rapp_spe = Rapp_spe(2:end);
        A2 = sum(rapp_spe(pf_pos).*pf_val(pf_pos));
        A1 = -sum(pf_val);
        A0 = sum(rapp_spe(pf_neg).*pf_val(pf_neg));
        qf = roots([A2,A1,A0]);
        
        qf = qf(qf>0);
        
        rapp_spe(pf_pos) = qf.*rapp_spe(pf_pos);
        rapp_spe(pf_neg) = (1./qf).*rapp_spe(pf_neg);
        Rapp_spe(2:end) = rapp_spe;
        %% <<<<<<<< FG FIX
    end
    %% >>>>>>>> FG FIX
    % final correction for compatibility
    % Band-pass acausal Butterworth filter
    %     acc_pro=filtfilt(BuB,BuA,acc_pro);
    
    %     vel_pro=cumsum(acc_pro)*dt;
    %     vel_pro=detrend(vel_pro,'linear');
    %     dis_pro=cumsum(vel_pro)*dt;
    %     dis_pro=detrend(dis_pro,'linear');
    [~,vel_pro,dis_pro] = idc_tha(dt,acc_pro);
    %     frac=5; %% taper
    %     dis_pro = taper_fun(dis_pro,frac,1,1);
    %
    %     vel_pro=diff(dis_pro)/dt;vel_pro(length(t))=0;
    %     acc_pro=diff(vel_pro)/dt;acc_pro(length(t))=0;
    %% <<<<<<<< FG FIX
    T_out= T_in;%[0.01, 0.03:0.01:3];
    for i=2:length(T_out)
        Sp_acc_pro(i)=4*pi^2*disp_spectra(acc_pro,dt,T_out(i),0.05)./T_out(i)^2;
    end
    Sp_acc_pro(1)=max(abs(acc_pro));
    
    %% *OUTPUT*
    varargout{1} = dt;
    varargout{2} = acc_pro(:);
    varargout{3} = T_out(:);
    varargout{4} = Sp_acc_pro(:);
    varargout{5} = vel_pro(:);
    varargout{6} = dis_pro(:);
    return
end
