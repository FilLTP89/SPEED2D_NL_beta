%% *Improved converter of utm coordinates to longitude/latitude*
% _Editor: Filippo Gatti
% CentraleSupélec - Laboratoire MSSMat
% DICA - Politecnico di Milano
% Copyright 2016_
% _super_utm2wgs_ : Function to convert lat/lon vectors into UTM coordinates (WGS84).
%% INPUT
% * _E_UTM (utm easting coordinate)_
% * _N_UTM (utm northing coordinate)_
% * _ZONE_UTM (utm geozone)_
%% OUTPUT
% * _LON (vector of longitude coordinates in decimal degrees)_
% * _LAT (vector of latitude  coordinates in decimal degrees)_
%% N.B.
% * negative latitudes refer to south hemisphere
% [LON,LAT] = super_utm2wgs(E_UTM,N_UTM,ZONE_UTM)
%% REFERENCES:
% Source: DMA Technical Manual 8358.2, Fairfax, VA
% Krueger series: Wikipedia
% utm reference: http://www.dmap.co.uk/utmworld.htm (based on north
% hemisphere)
function [varargout] = super_utm2wgs(varargin)
    
    %% *SETUP*
    narginchk(3,5);         % 3 arguments are required
    E_UTM = varargin{1};
    N_UTM = varargin{2};
    ZONE_UTM = varargin{3};
    
    nE=length(E_UTM);
    nN=length(N_UTM);
    n3=size(ZONE_UTM,1);
    if (nE~=nN || nE~=n3)
        error('x, y and ZONE_UTM vectors should have the same number or rows');
    end
    c=size(ZONE_UTM,2);
    if (c~=3)
        error('ZONE_UTM should be a vector of strings like "30T"');
    end
    % check ellipsoid values
    try narginchk(3,3)
        % default wgs84
        sa = 6378137.000000;   % major semi-axis of reference ellipsoid
        sb = 6356752.31424518; % minor semi-axis of reference ellipsoid
    catch
        sa = varargin{3};
        sb = varargin{4};
    end
    
    %% *ELLIPSOID*
    Eccentricity = sqrt(sa^2-sb^2)/sa;
    SquareEccentricity = Eccentricity^2;
    c = (sa^2)/sb;
    Flattening = (sa-sb)/sa;
    InverseFlattening = 1/Flattening;
    k0=0.9996;
    n=0.00167419;
    rm=sqrt(sa*sb);
    AA=(sa/(1+n))*(1+(1/4)*n^2+(1/64)*n^4+(1/256)*n^6+(25/16384)*n^8+(49/65536)*n^10);
    
    %% *SERIES EXPANSION*
    % _Kruger Series coefficients_
    % alphas
    alpha1=(1/2)*n-(2/3)*n^2+(5/16)*n^3+(41/180)*n^4-(127/288)*n^5+(7891/37800)*n^6+(72161/387072)*n^7-(18975107/50803200)*n^8+(60193001/290304000)*n^9+(134592031/1026432000)*n^10;
    alpha2=(13/48)*n^2-(3/5)*n^3+(557/1440)*n^4+(281/630)*n^5-(1983433/1935360)*n^6+(13769/28800)*n^7+(148003883/174182400)*n^8-(705286231/465696000)*n^9+(1703267974087/3218890752000)*n^10;
    alpha3=(61/240)*n^3-(103/140)*n^4+(15061/26880)*n^5+(167603/181440)*n^6-(67102379/29030400)*n^7+(79682431/79833600)*n^8+(6304945039/2128896000)*n^9-(6601904925257/1307674368000)*n^10;
    alpha4=(49561/161280)*n^4-(179/168)*n^5+(6601661/7257600)*n^6+(97445/49896)*n^7-(40176129013/7664025600)*n^8+(138471097/66528000)*n^9+(48087451385201/5230697472000)*n^10;
    alpha5=(34729/80640)*n^5-(3418889/1995840)*n^6+(14644087/9123840)*n^7+(2605413599/622702080)*n^8-(31015475399/2583060480)*n^9+(5820486440369/1307674368000)*n^10;
    alpha6=(212378941/319334400)*n^6-(30705481/10378368)*n^7+(175214326799/58118860800)*n^8+(870492877/96096000)*n^9-(1.328004581729E+015/47823519744000)*n^10;
    alpha7=(1522256789/1383782400)*n^7-(16759934899/3113510400)*n^8+(1315149374443/221405184000)*n^9+(71809987837451/3629463552000)*n^10;
    alpha8=(1424729850961/743921418240)*n^8-(256783708069/25204608000)*n^9+(2.46874929298989E+015/203249958912000)*n^10;
    alpha9=(21091646195357/6080126976000)*n^9-(6.71961821383558E+016/3.379030566912E+015)*n^10;
    alpha10=(7.79115156232328E+016/1.2014330904576E+016)*n^10;
    % betas
    beta1=(1/2)*n-(2/3)*n^2+(37/96)*n^3-(1/360)*n^4-(81/512)*n^5+(96199/604800)*n^6-(5406467/38707200)*n^7+(7944359/67737600)*n^8-(7378753979/97542144000)*n^9+(25123531261/804722688000)*n^10;
    beta2=(1/48)*n^2+(1/15)*n^3-(437/1440)*n^4+(46/105)*n^5-(1118711/3870720)*n^6+(51841/1209600)*n^7+(24749483/348364800)*n^8-(115295683/1397088000)*n^9+(5487737251099/51502252032000)*n^10;
    beta3=(17/480)*n^3-(37/840)*n^4-(209/4480)*n^5+(5569/90720)*n^6+(9261899/58060800)*n^7-(6457463/17740800)*n^8+(2473691167/9289728000)*n^9-(852549456029/20922789888000)*n^10;
    beta4=(4397/161280)*n^4-(11/504)*n^5-(830251/7257600)*n^6+(466511/2494800)*n^7+(324154477/7664025600)*n^8-(937932223/3891888000)*n^9-(89112264211/5230697472000)*n^10;
    beta5=(4583/161280)*n^5-(108847/3991680)*n^6-(8005831/63866880)*n^7+(22894433/124540416)*n^8+(112731569449/557941063680)*n^9-(5391039814733/10461394944000)*n^10;
    beta6=(20648693/638668800)*n^6-(16363163/518918400)*n^7-(2204645983/12915302400)*n^8+(4543317553/18162144000)*n^9+(54894890298749/167382319104000)*n^10;
    beta7=(219941297/5535129600)*n^7-(497323811/12454041600)*n^8-(79431132943/332107776000)*n^9+(4346429528407/12703122432000)*n^10;
    beta8=(191773887257/3719607091200)*n^8-(17822319343/336825216000)*n^9-(497155444501631/1.422749712384E+015)*n^10;
    beta9=(11025641854267/158083301376000)*n^9-(492293158444691/6.758061133824E+015)*n^10;
    beta10=(7.02850453042962E+015/7.2085985427456E+016)*n^10;
    % deltas
    delta1=2*n-2/3*n^2-2*n^3;
    delta2=7/3*n^2-8/5*n^3;
    delta3=56/15*n^3;
    % all coefficients
    ALPHA=[alpha1;alpha2;alpha3;alpha4;alpha5;alpha6;alpha7;alpha8;alpha9;alpha10];
    BETA=[beta1;beta2;beta3;beta4;beta5;beta6;beta7;beta8;beta9;beta10];
    DELTA=[delta1;delta2;delta3];
    
    E0 = 5e5;
    N0 = 1e7;
    
    %% *LAT/LON COORDINATES*
    LON = -999*ones(nE,1);
    LAT = -999*ones(nE,1);
    
    for i=1:nE
        
        x = E_UTM(i);
        y = N_UTM(i);
        geozone = str2double(ZONE_UTM(i,1:2));
        Smeridian=((geozone*6)-183);
        
        if (ZONE_UTM(i,end)>'X' || ZONE_UTM(i,end)<'C')
            fprintf('utm2wgs: Warning you cannot use lowercase letters in UTM geozone\n');
        end
        
        if (ZONE_UTM(i,end)>'M')
            flag_hemis='N';    % Northern hemisphere
        else
            keyboard
            flag_hemis='S';    % Southern hemisphere
        end
        
        eta = (x - E0)/k0/AA;
        if strcmpi(flag_hemis,'S')
            csi = (y-N0)/k0/AA;
        else
            csi = y/k0/AA;
        end
        
        csi1 = csi; 
        eta1 = eta;
        sigma1 = 1;
        tau1   = 0;
        for ij=1:3
            csi1 = csi1     - BETA(ij)*sin(2*ij*csi)*cosh(2*ij*eta);
            eta1 = eta1     - BETA(ij)*cos(2*ij*csi)*sinh(2*ij*eta);
            sigma1 = sigma1 - 2*ij*BETA(ij)*cos(2*ij*csi)*cosh(2*ij*eta);
            tau1   = tau1   + 2*ij*BETA(ij)*sin(2*ij*csi)*sinh(2*ij*eta);
        end
        
        chi = 180*asin(sin(csi1)/cosh(eta1))/pi;
        
        Latitude = chi;
        for ij=1:3
            Latitude = Latitude + 180*DELTA(ij)*sin(2*ij*chi)/pi;
        end
        Longitude = Smeridian + 180*atan2(sinh(eta1),cos(csi1))/pi;
        
        LON(i) = Longitude;
        LAT(i) = Latitude;
%         
%         
%         
%         lat=Y/(6366197.724*0.9996);
%         v=(c/((1+(SquareEccentricity*(cos(lat))^2)))^0.5)*0.9996;
%         a=X/v;
%         a1=sin(2*lat);
%         a2=a1*(cos(lat))^2;
%         j2=lat+(a1/2);
%         j4=((3*j2)+a2)/4;
%         j6=((5*j4)+(a2*(cos(lat))^2))/3;
%         alpha=(3/4)*SquareEccentricity;
%         beta=(5/3)*alpha^2;
%         gamma=(35/27)*alpha^3;
%         Bm=0.9996*c*(lat-alpha*j2+beta*j4-gamma*j6);
%         b=(Y-Bm)/v;
%         Epsi=((SquareEccentricity*a^2)/2)*(cos(lat))^2;
%         Eps=a*(1-(Epsi/3));
%         nab=(b*(1-Epsi))+lat;
%         senoheps=(exp(Eps)-exp(-Eps))/2;
%         Delta=atan(senoheps/(cos(nab)));
%         TaO=atan(cos(Delta)*tan(nab));
%         LON(i,1)=(Delta*(180/pi))+Smeridian;
%         LAT(i,1)=(lat+(1+SquareEccentricity*(cos(lat)^2)-(3/2)*SquareEccentricity*sin(lat)*...
%             cos(lat)*(TaO-lat))*(TaO-lat))*(180/pi);
        
    end
    
    %% *OUTPUT*
    varargout{1} = LON;
    varargout{2} = LAT;
    return
end