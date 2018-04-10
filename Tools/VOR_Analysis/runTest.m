function runTest(params)
% This function takes in the information given to the UI and runs the 
% relavent test(s) on the data
%{
TODO
    - Second pass on the Desaccading fit
    - Print the Parameters in the results section (Test Summary document?)
    - VORsineFit --> eyevel2cycle. What is this used for? 
    - Take note of each filterin/smoothing that takes place
    - Eye Coil filtering? - Ask Hannah
    - Tool Tips
    - Seperate unique analysis to individual functions
    - Error Handling for bad information
    - Turn runVOR into function, not script
    - Single Analysis
    - Batch Anaylsis
    - Name of Sriram's Project
%}

% Run the proper test
switch params.analysis
    case 'original'
        fprintf("Running Original Test")
        VOR_original(params)
    case 'Sriram'
        fprintf('Running Sriram''s Analysis')
        VOR_Sriram(params)
    case 'Delta-7 Generalizaton'
        fprintf('Running Delta-7 Generalization')
        VOR_Delta7Gen(params)
end

        