function [SamplestoIgnore, SamplestoFlip] = SpecifySampleAction(StageNames,NDistinctStages)

prompt={};
defaultans = {};

for nstages = 1:NDistinctStages
    
    prompt{2*nstages-1} = strcat('Samples to ignore at Stage ', num2str(StageNames(nstages)));
    prompt{2*nstages} = strcat('Samples to flip at Stage ', num2str(StageNames(nstages)));
    defaultans{2*nstages-1} = '[0,0]';
    defaultans{2*nstages} = '[0,0]';
    
end

prompt_title = 'Specify actions for samples';
num_lines = 1;
options.Interpreter = 'tex';
answer2 = inputdlg(prompt,prompt_title,num_lines,defaultans,options);


VectorLengthforSamplestoIgnore = 0;
VectorLengthforSamplestoFlip = 0;

for nstages = 1:NDistinctStages  
    VectorLengthforSamplestoIgnore = max(VectorLengthforSamplestoIgnore, length(str2num(answer2{2*nstages-1})));
    VectorLengthforSamplestoFlip = max(VectorLengthforSamplestoFlip, length(str2num(answer2{2*nstages})));    
end

SamplestoIgnore = zeros(NDistinctStages,VectorLengthforSamplestoIgnore);
SamplestoFlip = zeros(NDistinctStages,VectorLengthforSamplestoFlip);

clear VectorLengthforSamplestoIgnore
clear VectorLengthforSamplestoFlip

for nstages = 1:NDistinctStages 
    
    SamplestoIgnore(nstages, 1:length(str2num(answer2{2*nstages-1}))) = str2num(answer2{2*nstages-1});
    SamplestoFlip(nstages, 1:length(str2num(answer2{2*nstages}))) = str2num(answer2{2*nstages});
end



end



