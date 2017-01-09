%% *GENERATION OF STRONG GROUND MOTION SIGNALS BY COUPLING PHYSICS-BASED ANALYSIS WITH ARTIFICIAL NEURAL NETWORKS*
% _Editor: Filippo Gatti
% CentraleSupélec - Laboratoire MSSMat
% DICA - Politecnico di Milano
% Copyright 2016_
%% *NOTES*
% _syn2ann_setup_: function to select the set of analyses to the 
% analyses to be run.
%% *N.B.*
% Need for:
% _ccc.m,syn2ann_case_list.m_

ccc;
fprintf('============================\n');
fprintf('----------0. SETUP----------\n');
fprintf('============================\n');

%% *DEFINE WORKDIR*
% % _main workdir_
wd = '/media/filippo/Data/Filippo/PHD_passing_through_polimi/syn2ann/database';
fprintf('Workdir: %s\n',wd);
% _save path_
sp = '/home/filippo/Scrivania/ann';

%% *LOAD ALL METADATA AVAILABLE*
syn2ann_case_list;
% _select analyses : selected_case = [a,b,...,d]_
selected_case = 1;

%% *DEFINE REAL RECORDS METADATA*
% _path to record files_
bhr.pt  = fullfile(wd,'records');
fprintf('--> Record Path: %s\n',bhr.pt);

bhr.ns = numel(selected_case);
ns = bhr.ns;
for m_ = 1:ns
    for n_ = 1:fnn.bhrr
        bhr.(fni.bhrr{n_}){m_} = bhrr.(fni.bhrr{n_}){selected_case(m_)};
    end
end

fprintf('--> N. Stations: %u\n',bhr.ns);
cellfun(@(y) structfun(@(x) fprintf('--> Station ID: %s\n',x{:}),y,'UniformOutput',0),bhr.st);
fprintf('---------------------------------------------------------------\n');

bhr.na = 0;
for i_ = 1:bhr.ns
    bhr.nd(i_) = numel(bhr.st{i_}.dv);
    bhr.na = bhr.na+bhr.nd(i_);
end

% _reference system_
bhr.rs = {'ew';'ns';'ud'};
bhr.cp = {'ud';'ew'};
bhr.nc = numel(bhr.cp);
[~,bhr.ci] = ismember(bhr.cp,bhr.rs);
fprintf('--> Reference system : ');
cellfun(@(x) fprintf('%s; ',x),bhr.rs);
fprintf('\n');
fprintf('--> Directions: ');
cellfun(@(x) fprintf('%s ',x),bhr.cp);
fprintf('\n');
% _motion components_
bhr.rc = {'a','v','d'};
bhr.nr = numel(bhr.rc);
fprintf('--> Components: ');
cellfun(@(x) fprintf('%s; ',x),bhr.rc);
fprintf('\n');
bhr.cp = bhr.cp(:);
bhr.ci = bhr.ci(:);
fprintf('---------------------------------------------------------------\n');

%% *DEFINE SPEED MONITORS METADATA*
% _path to monitor files_
mon.pt  = fullfile(wd,'monitors');
fprintf('--> Monitor Path: %s\n',mon.pt);
% _metadata filename_
mon.fnm  = fullfile(wd,'SM_Stations_Monitors.csv');
fprintf('--> Monitor File: %s\n',mon.fnm);
% _type of simulation_
mon.typ  = 'S';
fprintf('--> Type of Simulation: %s\n',mon.typ);
% _monitor identity_
mon.na = bhr.ns;
for m_ = 1:mon.na
    for n_ = 1:fnn.monn
        mon.(fni.monn{n_})(m_) = monn.(fni.monn{n_})(selected_case(m_));
    end
end

fprintf('--> N. Monitor: %u\n',mon.na);
arrayfun(@(x) fprintf('--> Monitor ID: %u \n',x),mon.id);
% _reference system_
mon.rs = bhr.rs;
mon.cp = bhr.cp;
mon.ci = bhr.ci;
mon.nc = numel(mon.cp);
fprintf('--> Directions: ');
cellfun(@(x) fprintf('%s ',x),mon.cp);
% _motion components_
mon.rc  = {'d'};
mon.nr  = numel(mon.rc);
fprintf('--> Components: ');
cellfun(@(x) fprintf('%s ',x),mon.rc);
fprintf('\n---------------------------------------------------------------\n');
mon.cp = mon.cp(:);
mon.ci = mon.ci(:);
mon.hyb = 'butter';

%% *DEFINE HYBRIDIZATION METADATA*
% number of iteration for hybrid selections
MAXIT = 10;
% _SP96 metadata_
hybrid_type='sp96';
mtd.sp96.na = mon.na;
for m_ = 1:mtd.sp96.na
    for n_ = 1:fnn.mtdd.sp96
        mtd.sp96.(fni.mtdd.sp96{n_})(m_) = mtdd.sp96.(fni.mtdd.sp96{n_})(selected_case(m_));
    end
end
% % _EXSIM metadata_
% mtd.exsim.na = mon.na;
% for m_ = 1:mtd.exsim.na
%     for n_ = 1:fnn.mtdd.exsim
%         mtd.exsim.(fni.mtdd.exsim{n_})(m_) = mtdd.exsim.(fni.mtdd.exsim{n_})(selected_case(m_));
%     end
% end
%% *DEFINE ANN METADATA*
% ANN vector follow the reference system mon.rs
% _site class considered : ALL,AB,CD_
ann.mtd.scl = {'ALL';'ALL';'ALL'};
% _corner period for each ANN_
ann.mtd.TnC = {0.75;0.75;0.75};
% _ANN motion component : gh,ud (geometric mean horizontal, updip)_
ann.mtd.cpn = {'gh';'gh';'ud'};
for i_ = 1:numel(ann.mtd.TnC)
    ann.mtd.nl(i_) = {sprintf('net_%u_%s_%s_new.mat',...
        round(ann.mtd.TnC{i_}*100),ann.mtd.scl{i_},ann.mtd.cpn{i_})};
    ann.mtd.tol(i_).low.psa = 0.15;
    ann.mtd.tol(i_).low.pga = 0.15;
    ann.mtd.tol(i_).hgh.psa = 0.15;
    ann.mtd.tol(i_).hgh.pga = 0.15;
end
% tolerances
ann.mtd.nit = [1000;1000;4000];