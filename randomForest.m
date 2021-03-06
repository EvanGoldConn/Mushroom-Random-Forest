





mushroomFile = readtable('trainingDataset.csv');
leafSizes = [1 5 50]; %10 15 20 25 30 35 40 45 50 55 60 65 60 65 70 75 80 85 90 95 100]; %find optimal number?
FinalLeafSize = 5;
numTrees = 20; %find optimal number?
rng(9876, 'twister');
savedRng = rng; %why 9876?

% Xcol = [mushroomFile.CAP_SHAPE mushroomFile.CAP_SURFACE mushroomFile.BRUISES mushroomFile.ODOR mushroomFile.GILL_ATTACHMENT mushroomFile.GILL_SPACING mushroomFile.GILL_SIZE mushroomFile.GILL_COLOR mushroomFile.STALK_SHAPE mushroomFile.STALK_ROOT mushroomFile.STALK_SURFACE_ABOVE_RING mushroomFile.STALK_SURFACE_BELOW_RING mushroomFile.STALK_COLOR_ABOVE_RING mushroomFile.STALK_COLOR_BELOW_RING mushroomFile.VEIL_TYPE mushroomFile.VEIL_COLOR mushroomFile.RING_NUMBER mushroomFile.RING_TYPE mushroomFile.SPORE_PRINT_COLOR mushroomFile.POPULATION mushroomFile.HABITAT];


Xcol = removevars(mushroomFile,{'CAN_EAT'});
Ycol = ordinal(mushroomFile.CAN_EAT);

% ---------------------------------------- All Features ~ Different Leaf Sizes ---------------------------------------------------

% color = 'bgrcmy';
% for ii = 1:length(leafSizes) %run through diff leaf sizes
%     rng(savedRng)
%     
%     b = TreeBagger(numTrees,Xcol,Ycol, 'OOBPrediction', 'on', 'CategoricalPredictors', 22, ...
%         'MinLeafSize', leafSizes(ii), 'Method', 'classification'); 
%     
%     plot(oobError(b))%,color(ii))
%     hold on
%     
%     
% end
% 
% 
% xlabel('Number of grown trees')
% ylabel('Out-of-Bag Classification Error')
% legend({'1', '5', '50'},'Location','NorthEast')
% title('Classification Error for Different Leaf Sizes')
% hold off

% ----------------------------------------All Features w/ Best Leaf Size  ---------------------------------------------------
SpecificTree = TreeBagger(numTrees,Xcol,Ycol, 'OOBPrediction', 'on', 'CategoricalPredictors', 22, ...
         'MinLeafSize', FinalLeafSize, 'Method', 'classification'); 
     
 oobErrorXFull = oobError(SpecificTree);

% ----------------------------------------Important Features ---------------------------------------------------
% Tree = TreeBagger(numTrees,Xcol,Ycol, 'OOBPredictorImportance', 'on', 'OOBPrediction', 'on', 'CategoricalPredictors', 22, ...
%          'MinLeafSize', FinalLeafSize, 'Method', 'classification');
% 
% bar(Tree.OOBPermutedPredictorDeltaError)
% xlabel('Feature number')
% ylabel('Out-of-bag feature importance')
% title('Feature importance results')

%{

Important Features: 
1. #5 | Odor
2. #20 | Spore_Print_Color
3. #3 | Cap_Color
4. #8 | Gill_Size
5. #22 | Habitat

%}

% ---------------------------------------- Only Important Features ---------------------------------------------------

% NewXcol = [mushroomFile.ODOR mushroomFile.SPORE_PRINT_COLOR mushroomFile.CAP_COLOR mushroomFile.GILL_SIZE mushroomFile.HABITAT]; 
NewXcol = removevars(mushroomFile,{'CAN_EAT', 'CAP_SHAPE', 'CAP_SURFACE', 'BRUISES', 'GILL_ATTACHMENT', 'GILL_SPACING', 'GILL_COLOR', 'STALK_SHAPE', 'STALK_ROOT', 'STALK_SURFACE_ABOVE_RING', 'STALK_SURFACE_BELOW_RING', 'STALK_COLOR_ABOVE_RING', 'STALK_COLOR_BELOW_RING', 'VEIL_TYPE', 'VEIL_COLOR', 'RING_NUMBER', 'RING_TYPE', 'POPULATION'});
NewTree = TreeBagger(numTrees,NewXcol,Ycol, 'OOBPrediction', 'on', 'CategoricalPredictors', 5, ...
         'MinLeafSize', FinalLeafSize, 'Method', 'classification'); 
     
     
oobErrorNew = oobError(NewTree);

plot(oobErrorXFull, 'b')
hold on 
plot(oobErrorNew, 'r')
xlabel('Number of grown trees')
ylabel('Out-of-bag classification error')
legend({'All features', 'Features 5, 20, 3, 8, 22'},'Location','NorthEast')
title('Classification Error for Different Sets of Predictors')
hold off
 
 
compactFinalTree = compact(NewTree);

validationDS = readtable('/Users/evangoldsmith/Documents/GitHub/Mushroom-Random-Forest-/validationDataset.csv');
importantFeatures = removevars(validationDS,{'CAN_EAT', 'CAP_SHAPE', 'CAP_SURFACE', 'BRUISES', 'GILL_ATTACHMENT', 'GILL_SPACING', 'GILL_COLOR', 'STALK_SHAPE', 'STALK_ROOT', 'STALK_SURFACE_ABOVE_RING', 'STALK_SURFACE_BELOW_RING', 'STALK_COLOR_ABOVE_RING', 'STALK_COLOR_BELOW_RING', 'VEIL_TYPE', 'VEIL_COLOR', 'RING_NUMBER', 'RING_TYPE', 'POPULATION'});

[predictedClass, classificationScore] = predict(compactFinalTree, importantFeatures);



for i = 1:height(validationDS)
   fprintf('Mushroom %d:\n',i);
   fprintf(strcat('\tCan_Eat:\t', char(validationDS.CAN_EAT(i)), '\n'));
   fprintf(strcat('\tCap_Color:\t', char(validationDS.CAP_COLOR(i)), '\n'));
   fprintf(strcat('\tOdor:\t', char(validationDS.ODOR(i)), '\n'));
   fprintf(strcat('\tGill_Size:\t', char(validationDS.GILL_SIZE(i)), '\n'));
   fprintf(strcat('\tSpore_Print_Color:\t', char(validationDS.SPORE_PRINT_COLOR(i)), '\n'));
   fprintf(strcat('\tHabitat:\t', char(validationDS.HABITAT(i)), '\n'));
   fprintf(strcat('\tPredicted Rating:\t', char(predictedClass{i}), '\n'));
   fprintf('\tClassification score :\n');
   for j = 1:length(b.ClassNames)
      if (classificationScore(i,j)>0)
         fprintf('      \t\t%s : %5.4f \n',compactFinalTree.ClassNames{j},classificationScore(i,j));
      end
   end
end

