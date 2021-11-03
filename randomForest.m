





mushroomFile = readtable('trainingDataset.csv');
leafSizes = [1 5 10 15 20 25]; %find optimal number?
numTrees = 25; %find optimal number?
rng(9876, 'twister');
savedRng = rng; %why 9876?

Xcol = [mushroomFile.CAP_SHAPE mushroomFile.CAP_SURFACE mushroomFile.BRUISES mushroomFile.ODOR mushroomFile.GILL_ATTACHMENT mushroomFile.GILL_SPACING mushroomFile.GILL_SIZE mushroomFile.GILL_COLOR mushroomFile.STALK_SHAPE mushroomFile.STALK_ROOT mushroomFile.STALK_SURFACE_ABOVE_RING mushroomFile.STALK_SURFACE_BELOW_RING mushroomFile.STALK_COLOR_ABOVE_RING mushroomFile.STALK_COLOR_BELOW_RING mushroomFile.VEIL_TYPE mushroomFile.VEIL_COLOR mushroomFile.RING_NUMBER mushroomFile.RING_TYPE mushroomFile.SPORE_PRINT_COLOR mushroomFile.POPULATION mushroomFile.HABITAT];
%Xcol = ['CAP_SHAPE' 'CAP_SURFACE' 'BRUISES' 'ODOR' 'GILL_ATTACHMENT' 'GILL_SPACING' 'GILL_SIZE' 'GILL_COLOR' 'STALK_SHAPE' 'STALK_ROOT' ...
    %'STALK_SURFACE_ABOVE_RING' 'STALK_SURFACE_BELOW_RING' 'STALK_COLOR_ABOVE_RING' 'STALK_COLOR_BELOW_RING' 'VEIL_TYPE' 'VEIL_COLOR' ...
    %'RING_NUMBER' 'RING_TYPE' 'SPORE_PRINT_COLOR' 'POPULATION' 'HABITAT'];

Xcol = removevars(mushroomFile,{'CAN_EAT'});
Ycol = ordinal(mushroomFile.CAN_EAT);
'hi'
%Ycol = ordinal('CAN_EAT');



color = 'bgrcmy';
for ii = 1:length(leafSizes) %run through diff leaf sizes
    rng(savedRng)
    
    b = TreeBagger(numTrees,Xcol,Ycol, 'OOBPrediction', 'on', 'CategoricalPredictors', 22, ...
        'MinLeafSize', leafSizes(ii), 'Method', 'classification'); 
    
    %{
      Variables to review 
      NumPredictorsToSample
      Method (classification, right??)
      Number of Leaves (MinleafSize is 1, then 5, then 10.)
      Number of Trees
      **CategoricalPredictors, should be == num variables used to predict
      CAN_EAT?**
    %}
        
     plot(oobError(b),color(ii))
     hold on
    
    
end


xlabel('Number of grown trees')
ylabel('Out-of-Bag Classification Error')
legend({'1','5','10', '15', '20', '25'},'Location','NorthEast')
title('Classification Error for Different Leaf Sizes')
hold off

%%%%%% NESTED FOR LOOP TO PLOT NUMBER OF LEAFS AND NUMBER OF TREES TO
%%%%%% DETERMINE WHEN IT'S 'TOO MANY'. 

% numTrees = 40;
% numLeaf = 10;
% rng(savedRng);
% b = TreeBagger(numTrees, Xcol, Ycol, 'OOBPredictorImportance','on',...
%                           'CategoricalPredictors',22,...
%                           'MinLeafSize',numLeaf, 'Method', 'classification');
%                       
% bar(b.OOBPermutedPredictorDeltaError)
% xlabel('Feature number')
% ylabel('Out-of-bag feature importance')
% title('Feature importance results')










