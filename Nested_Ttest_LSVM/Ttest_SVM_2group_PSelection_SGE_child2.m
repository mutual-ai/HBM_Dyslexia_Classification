function Accuracy = Ttest_SVM_2group_PSelection_SGE_child2(ResultantFolder, Subjects_Label)
%
% Copyright(c) 2016
% State Key Laboratory of Cognitive Neuroscience and Learning, Beijing Normal University
%    Written by <a href="zaixucui@gmail.com">Zaixu Cui</a>
%    Mail to Author:  <a href="zaixucui@gmail.com">zaixucui@gmail.com</a>
%
% Subjects_Label:
%                n * 1 vector, each element is 1 or -1
%

for i = 1:length(Subjects_Label)
    tmp = load([ResultantFolder filesep 'predicted_labels_' num2str(i) '.mat']);
    predicted_labels(i) = tmp.predicted_label;
    tmp = load([ResultantFolder filesep 'decision_values_' num2str(i) '.mat']);
    decision_values(i) = tmp.decision_value;
    tmp = load([ResultantFolder filesep 'RetainID_' num2str(i) '.mat']);
    RetainID_save{i} = tmp.RetainID;
    tmp = load([ResultantFolder filesep 'w_' num2str(i) '.mat']);
    w{i} = tmp.w;
end

predicted_labels(find(predicted_labels == 0)) = -1;
Subjects_Quantity = length(Subjects_Label);

Group1_Index = find(Subjects_Label == 1);
Group0_Index = find(Subjects_Label == -1);
Category_group1 = predicted_labels(Group1_Index);
Y_group1 = decision_values(Group1_Index);
Category_group0 = predicted_labels(Group0_Index);
Y_group0 = decision_values(Group0_Index);

save([ResultantFolder filesep 'Y.mat'], 'Y_group1', 'Y_group0');
save([ResultantFolder filesep 'Category.mat'], 'Category_group1', 'Category_group0');

group0_Wrong_ID = find(Category_group0 == 1);
group0_Wrong_Quantity = length(group0_Wrong_ID);
group1_Wrong_ID = find(Category_group1 == -1);
group1_Wrong_Quantity = length(group1_Wrong_ID);
disp(['group0: ' num2str(group0_Wrong_Quantity) ' subjects are wrong ' mat2str(group0_Wrong_ID) ]);
disp(['group1: ' num2str(group1_Wrong_Quantity) ' subjects are wrong ' mat2str(group1_Wrong_ID) ]);
save([ResultantFolder filesep 'WrongInfo.mat'], 'group0_Wrong_Quantity', 'group0_Wrong_ID', 'group1_Wrong_Quantity', 'group1_Wrong_ID');
Accuracy = (Subjects_Quantity - group0_Wrong_Quantity - group1_Wrong_Quantity) / Subjects_Quantity;
disp(['Accuracy is ' num2str(Accuracy) ' !']);
save([ResultantFolder filesep 'Accuracy.mat'], 'Accuracy');
group0_Quantity = length(find(Subjects_Label == -1));
group1_Quantity = length(find(Subjects_Label == 1));
Sensitivity = (group0_Quantity - group0_Wrong_Quantity) / group0_Quantity;
disp(['Sensitivity is ' num2str(Sensitivity) ' !']);
save([ResultantFolder filesep 'Sensitivity.mat'], 'Sensitivity');
Specificity = (group1_Quantity - group1_Wrong_Quantity) / group1_Quantity;
disp(['Specificity is ' num2str(Specificity) ' !']);
save([ResultantFolder filesep 'Specificity.mat'], 'Specificity');
PPV = length(find(Category_group0 == -1)) / length(find([Category_group0 Category_group1] == -1));
disp(['PPV is ' num2str(PPV) ' !']);
save([ResultantFolder filesep 'PPV.mat'], 'PPV');
NPV = length(find(Category_group1 == 1)) / length(find([Category_group0 Category_group1] == 1));
disp(['NPV is ' num2str(NPV) ' !']);
save([ResultantFolder filesep 'NPV.mat'], 'NPV');
[AUC, CutPoint_Accuracy] = AUC_Calculate_ROC_Draw([Y_group0 Y_group1]', Subjects_Label, 0);
save([ResultantFolder filesep 'AUC.mat'], 'AUC');
save([ResultantFolder filesep 'ROC_CutPoint.mat'], 'CutPoint_Accuracy');

% Calculating weight
RetainID_all = [];
w_all = [];
for i = 1:length(RetainID_save)
    RetainID_all = [RetainID_all RetainID_save{i}];
    w_all = [w_all w{i}];
end
Feature_selected_unique = unique(RetainID_all);
for i = 1:length(Feature_selected_unique)
    index = find(RetainID_all == Feature_selected_unique(i));
    Feature_selected(i).ID = Feature_selected_unique(i);
    Feature_selected(i).frequency = length(index);
    Feature_selected(i).averageW = mean(w_all(index));
end
save([ResultantFolder filesep 'Feature_selected.mat'], 'Feature_selected');

ID_All = [Feature_selected.ID];
Frequency_All = [Feature_selected.frequency];
Weight_All = [Feature_selected.averageW];

% Select features appearing in any folder (61 folders in sum)
Index = find(Frequency_All >= Subjects_Quantity);
ID_All_2 = ID_All(Index);
Frequency_All_2 = Frequency_All(Index);
Weight_All_2 = Weight_All(Index);

[sort_weight, sort_ind] = sort(abs(Weight_All_2), 2);
ID_All_3 = ID_All_2(sort_ind);
Weight_All_3 = Weight_All_2(sort_ind);

ID_Final = ID_All_3;
Weight_Final = Weight_All_3;

save([ResultantFolder filesep 'ID_Final.mat'], 'ID_Final');
save([ResultantFolder filesep 'Weight_Final.mat'], 'Weight_Final');

