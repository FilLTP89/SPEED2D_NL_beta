if hybrid_flag
    for i_ = 1:numel(mm_)
        st = bhr.nm{mm_(i_)};
        lfhf_filter_plot(hbs.mon.dtm(mm_(i_)),hbs.mon.vtm{mm_(i_)}(end),mon.fa(i_),mon.fb(i_),...
            fullfile(sp,'lfhf_filter'));
        fprintf('%s - PGV included\n',bhr.nm{mm_(i_)});
        for j_ = 1:numel(cpp)
            %% *POST-PROCESS - ORIGINAL VS FILTERED RECORDS*
            fn = fullfile(sp,sprintf('%s_rec_org_flt',st));
            syn2ann_plot_compare(ones(5,1),{rec.org},mm_(i_),{'ORIGINAL'},(cpp{j_}),fn,0);
            
            %% *POST-PROCESS - NUMERICAL SIMULATIONS VS RECORDS*
            fn = fullfile(sp,sprintf('%s_sim_rec_org',st));
            syn2ann_plot_compare(ones(5,1),{rec.org,nss.org},mm_(i_),...
                {'RECORDED';'SIMULATED'},(cpp{j_}),fn,[0,1]);
            
            %% *POST-PROCESS - BB HYBRIDIZATION*
            fn = fullfile(sp,sprintf('%s_sim_sp96_hyb',st));
            syn2ann_plot_compare([0 0 1 1 1],{nss.hyb;sps.hyb;hbs},mm_(i_),...
                {'SIMULATED';'SP96';'HYBRID'},(cpp{j_}),fn,ones(3,1));
            syn2ann_plot_compare([1 0 0 0 0],{nss.hyb;sps.hyb;hbs},mm_(i_),...
                {'SIMULATED';'SP96';'HYBRID'},(cpp{j_}),fn,ones(3,1));
            syn2ann_plot_compare([0 1 0 0 0],{nss.org;sps.org;nss.hyb;sps.hyb;hbs},mm_(i_),...
                {'';'';'SIMULATED';'SP96';'HYBRID'},(cpp{j_}),fn,ones(3,1),...
                {'none','none','none','none','none'},{'--','--','-','-','-'});
        end
    end
    
    %% WITH PGV
    for i_ = 1:numel(mm_)
        st = bhr.nm{mm_(i_)};
        fprintf('%s - no PGV included\n',bhr.nm{mm_(i_)});
        for j_ = 1:numel(cpp)
            %% *POST-PROCESS - HYBRIDS vs ANN*
            fn = fullfile(sp,sprintf('%s_hyb_ann_withPGV',st));
            syn2ann_plot_compare([1 0 0 0 0],{hbs;trs_noPGV.(cpp{j_});trs_withPGV.(cpp{j_})},mm_(i_),...
                {'HYBRID';'ANN (no PGV)';'ANN (PGV)'},(cpp{j_}),fn,[0,0],{'none';'o';'o'},{'-','none','none'});
            
            %% *POST-PROCESS - SPECTRAL MATCHING vs ANN*
            fn = fullfile(sp,sprintf('%s_spm_ann_withPGV',st));
            syn2ann_plot_compare([1 0 0 0 0],...
                {spm_noPGV.(cpp{j_});trs_noPGV.(cpp{j_});...
                spm_withPGV.(cpp{j_});trs_withPGV.(cpp{j_})},mm_(i_),...
                {'MATCHED (no PGV)';'ANN (no PGV)';'MATCHED (PGV)';'ANN (noPGV)'},...
                (cpp{j_}),fn,[0,0],{'none';'o';'none';'o'},{'-','none','-','none'});
            %
            %% *POST-PROCESS - SPECTRAL MATCHING vs RECORDS*
            fn = fullfile(sp,sprintf('%s_spm_rec_withPGV',st));
            syn2ann_plot_compare([1 1 1 1 1],{rec.org;spm_noPGV.(cpp{j_})},mm_(i_),...
                {'RECORDED';'MATCHED (no PGV)'},(cpp{j_}),fn,[0,1]);
        end
    end
else
    %% WITH PGV
    for i_ = 1:numel(mm_)
        st = bhr.nm{mm_(i_)};
        fprintf('%s - no PGV included\n',bhr.nm{mm_(i_)});
        for j_ = 1:numel(cpp)
            %% *POST-PROCESS - HYBRIDS vs ANN*
            fn = fullfile(sp,sprintf('%s_hyb_ann_withPGV_jn',st));
            syn2ann_plot_compare([1 0 0 0 0],{hbs;trs_noPGV.(cpp{j_});trs_withPGV.(cpp{j_})},mm_(i_),...
                {'HYBRID';'ANN (no PGV)';'ANN (PGV)'},(cpp{j_}),fn,[0,0],{'none';'o';'o'},{'-','none','none'});
            
            %% *POST-PROCESS - SPECTRAL MATCHING vs ANN*
            fn = fullfile(sp,sprintf('%s_spm_ann_withPGV_jn',st));
            syn2ann_plot_compare([1 0 0 0 0],...
                {spm_noPGV.(cpp{j_});trs_noPGV.(cpp{j_});...
                spm_withPGV.(cpp{j_});trs_withPGV.(cpp{j_})},mm_(i_),...
                {'MATCHED (no PGV)';'ANN (no PGV)';'MATCHED (PGV)';'ANN (noPGV)'},...
                (cpp{j_}),fn,[0,0],{'none';'o';'none';'o'},{'-','none','-','none'});
            %
            %% *POST-PROCESS - SPECTRAL MATCHING vs RECORDS*
            fn = fullfile(sp,sprintf('%s_spm_rec_withPGV_jn',st));
            syn2ann_plot_compare([1 1 1 1 1],{rec.org;spm_noPGV.(cpp{j_})},mm_(i_),...
                {'RECORDED';'MATCHED (no PGV)'},(cpp{j_}),fn,[0,1]);
        end
    end
end

% %% NO PGV
% for i_ = 1:numel(mm_)
%     st = bhr.nm{mm_(i_)};
%     fprintf('%s\n',bhr.nm{mm_(i_)});
%     for j_ = 1:numel(cpp)
% %         %% *POST-PROCESS - HYBRIDS vs ANN*
% %         fn = fullfile(sp,sprintf('%s_hyb_ann_noPGV',st));
% %         syn2ann_plot_compare([1 0 0 0 0],{hbs;trs_noPGV.(cpp{j_})},mm_(i_),...
% %             {'HYBRID';'ANN (PGV)'},(cpp{j_}),fn,[0,0],{'none';'o'},{'-','none'});
%
%         %% *POST-PROCESS - SPECTRAL MATCHING vs ANN*
%         fn = fullfile(sp,sprintf('%s_spm_ann_noPGV',st));
%         syn2ann_plot_compare([1 0 0 0 0],{spm_noPGV.(cpp{j_}),trs_noPGV.(cpp{j_})},mm_(i_),...
%             {'MATCHED';'ANN (PGV)'},(cpp{j_}),fn,[0,0],{'none';'o'},{'-','none'});
%
%         %% *POST-PROCESS - SPECTRAL MATCHING vs RECORDS*
%         fn = fullfile(sp,sprintf('%s_spm_rec_noPGV',st));
%         syn2ann_plot_compare([1 1 1 1 1],{rec.org,spm_noPGV.(cpp{j_})},mm_(i_),...
%             {'RECORDED';'MATCHED'},(cpp{j_}),fn,[0,1]);
%     end
% end