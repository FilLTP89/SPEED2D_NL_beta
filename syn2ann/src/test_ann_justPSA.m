%% *GENERATION OF STRONG GROUND MOTION SIGNALS BY COUPLING PHYSICS-BASED ANALYSIS WITH ARTIFICIAL NEURAL NETWORKS*
% _Editor: Filippo Gatti
% CentraleSupélec - Laboratoire MSSMat
% DICA - Politecnico di Milano
% Copyright 2016_
%% *NOTES*
% _test_ann_justPSA_: function train ANN on PSA values
%% *N.B.*
% Need for:
% _trann_define_inout.m, trann_check_vTn.m, trann_tv_sets.m_
% _ANN MATLAB tool_
%% *REFERENCES*
function [varargout] = test_ann_justPSA(varargin)
    %% *SET-UP*
    ann = varargin{1};
    rec = varargin{2};
    
    inn = cell(rec.mon.nc,1);
    %
    % _define input/target natural periods_
    %
    [inp.vTn,tar.vTn,inp.nT,tar.nT] = trann_define_inout(ann.TnC);
    ann.mon.vTn = [tar.vTn(:);inp.vTn(:)];
    
    for i_=1:rec.mon.na
        %
        % _check input/target natural periods with database_
        %
        [inp.idx,tar.idx] = trann_check_vTn(inp,tar,rec.mon,1e-8);
        
        for j_ = 1:rec.mon.nc
            cpp.rec = rec.mon.cp{j_};
            cpp.ann = ann.cpp;
            
            flag.rec = seismo_dir_conversion(cpp.rec);
            flag.ann = seismo_dir_conversion(cpp.ann);
            
            if any(strcmpi(flag.rec,flag.ann))
                inp.psa = rec.syn{i_}.psa.(cpp.rec)(:);
                inp.psa = inp.psa(inp.idx,1);
                out.psa = 10.^(sim(ann.net,log10(inp.psa*100)));
                ann.syn{i_}.psa.(cpp.rec) = [out.psa(:)./100;inp.psa(:)];
            end
        end
    end
    
    %% *OUTPUT*
    varargout{1} = ann;
    
    return
end
