%% *SET-UP - EMILIA 2012 SIMULATIONS*
ccc;
fprintf('---------------------\n0. SETUP\n---------------------\n');

%% *WORKDIR*
wd = fullfile(filesep,'media','user','DATI','Filippo','PHD_heavyweight',...
    'EMILIA_2905');
% wd = fullfile(filesep,'media','filippo','Data','Filippo','PHD_heavyweight',...
%     'EMILIA_2905');
fprintf('Workdir: %s\n',wd);
% _save path_
sp = fullfile(filesep,'media','user','DATI','Filippo','PHD_heavyweight',...
    'heavy_images');
% eval(sprintf('!mkdir -p %s',sp));

%% *REAL RECORDS: METADATA*
% _path to record files_
% bhr.pt  = fullfile(wd,'records');
% fprintf('--> Record Path: %s\n',bhr.pt);
% _station identity_
% bhr.st{1}.id = {'MRN'};
% bhr.st{1}.ni = {'CIT';'HN'};
% bhr.st{2}.id = {'MIR'};
% bhr.st{2}.ni = {'TV';'HN'};
% bhr.st{3}.id = {'AQK'};
% bhr.st{3}.ni = {'IT';'HN'};
% bhr.st{4}.id = {'AQU'};
% bhr.st{4}.ni = {'MN';'HL'};
% bhr.ns = numel(bhr.st);
% fprintf('--> N. Stations: %u\n',bhr.ns);
% cellfun(@(y) structfun(@(x) fprintf('--> Station ID: %s\n',x{:}),y,'UniformOutput',0),bhr.st);
% fprintf('\n');
% _recorded events_
% bhr.st{1}.ev = {'20120529.070002'};
% bhr.st{2}.ev = {'20120529.070002'};
% bhr.st{3}.ev = {'20090406.013240'};
% bhr.st{4}.ev = {'20090406.013240'};
% _database_
% bhr.tp = {'itaca'};
% cellfun(@(x) fprintf('--> Database: %s',x),bhr.tp);
% fprintf('\n');
% _event label_
% bhr.lb = {'Main Shock'};
% _device list_
% bhr.st{1}.dv = {''};
% bhr.st{2}.dv = {'08'};
% bhr.st{3}.dv = {''};
% bhr.st{4}.dv = {''};
% bhr.na = 0;
% for i_ = 1:bhr.ns
%     bhr.nd(i_) = numel(bhr.st{i_}.dv);
%     bhr.na = bhr.na+bhr.nd(i_);
% end
% _reference system_
bhr.rs = {'e';'n';'z'};
bhr.cp = {'e';'n';'z'};
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

%% *MONITORS*
% _path to monitor files_
mon.pt  = fullfile(wd,'monitor');
fprintf('--> Monitor Path: %s\n',mon.pt);
% _metadata filename_
mon.fn  = fullfile(wd,'SM_Stations_Monitors.csv');
fprintf('--> Monitor File: %s\n',mon.fn);
% _type of simulation_
mon.tp  = 'S';
fprintf('--> Type of Simulation: %s\n',mon.tp);
% _monitor identity_
mon.id  = [16928,15045,18446,16294,5782];
mon.na  = numel(mon.id);
fprintf('--> N. Monitor: %u\n',mon.na);
arrayfun(@(x) fprintf('--> Monitor ID: %u \n',x),mon.id);
fprintf('\n');
% _reference system_
mon.rs = bhr.rs;
mon.cp = bhr.cp;
mon.ci = bhr.ci;
mon.nc = numel(mon.cp);
fprintf('--> Directions: ');
cellfun(@(x) fprintf('%s ',x),mon.cp);
fprintf('\n');
% _motion components_
mon.rc  = {'d'};
mon.nr  = numel(mon.rc);
fprintf('--> Components: ');
cellfun(@(x) fprintf('%s ',x),mon.rc);
fprintf('\n');
mon.cp = mon.cp(:);
mon.ci = mon.ci(:);

%% *HYBRIDIZATION METADATA*
% _SP96 metadata_
hybrid_type  = 'sp96';
mtd.mw       = 6*ones(mon.na,1);
mtd.dtm_sp96 = 0.01*ones(mon.na,1);
mtd.scc      = 2*ones(mon.na,1);
mtd.sst      = zeros(mon.na,1);
mtd.scl      = 0.01*ones(mon.na,1);

%% *PARSING EXTRA METADATA*
mon.fa = 1.3*ones(mon.na,1);
mon.fb = 1.5*ones(mon.na,1);

%% *ANN*
ann.mtd.scl = 'ALL';
ann.mtd.TnC = {0.75;0.75;0.75};
ann.mtd.cpn = {'gh';'gh';'ud'};
for i_ = 1:numel(ann.mtd.TnC)
    ann.mtd.nl(i_) = {sprintf('net_%u_%s_%s.mat',...
        round(ann.mtd.TnC{i_}*100),ann.mtd.scl,ann.mtd.cpn{i_})};
end