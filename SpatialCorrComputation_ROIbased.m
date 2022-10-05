%% ------------------------------------------------------------
%@Name: Spacial Correlation & FDR Correction
%@Author: Yiru, Yang., Shaokun Zhao
%@Date: 09/27/2022
%@Description: This program is used to calculate the spatial correlation 
%   pattern of the point-to-point ROI signal and perform FDR correction on 
%   the results.
%% ------------------------------------------------------------
clc;clear;
root = ''; % root directory
table_GMN = '';% ROIs signals of GMN, xlsx file
table_WMN = '';% ROIs signals of WMN, xlsx file
sig_thre = .05; %FDR correction threshold

[~,~,raw_GM] = xlsread(fullfile(root,table_GMN));
[~,~,raw_WM] = xlsread(fullfile(root,table_WMN));
for j = 1:numel(raw_GM(1,:))
    if sum(cell2mat(raw_GM(:,j)))~=0
        [r, p] = corr(cell2mat(raw_WM(2:end,j+4)), cell2mat(raw_GM(:,j)));
        table_r(1,j) = r;
        table_p(1,j) = p;
    else
        table_r(1,j) = 0;
        table_p(1,j) = 0;
    end
end

xlswrite(['Result_Allsubs_SpacialCorr_r_',table_GMN(33:35),'.xlsx'],table_r);
xlswrite(['Result_Allsubs_SpacialCorr_p_',table_GMN(33:35),'.xlsx'],table_p);

% FDR correction
temptable = table_p';
ind = find(temptable~=0);
table_p_tem = temptable(ind);
[~,rank] = sort(table_p_tem,'descend');
FDRp = table_p_tem.*numel(table_p_tem)./rank;
temptable(ind) = FDRp;
table_p = temptable';

table_r_thre = table_r;
for i = 1:numel(table_r(1,:))
    for j = 1:numel(table_r(:,1))
        if table_p(j,i)>=sig_thre || table_p(j,i)==0 
            table_r_thre(j,i) = 0;
        else
            continue
        end
    end
end

xlswrite(['Result_Allsubs_SpacialCorr_r_threFDR.05_',table_GMN(33:35),'.xlsx'],table_r_thre);
xlswrite(['Result_Allsubs_SpacialCorr_FDRp_',table_GMN(33:35),'.xlsx'],table_p);

disp('Done');
