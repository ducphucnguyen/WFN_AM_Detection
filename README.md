# AM detection

[![Build Status](https://travis-ci.com/ducphucnguyen/FreeRay.jl.svg?branch=master)](https://travis-ci.com/ducphucnguyen/FreeRay.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/ducphucnguyen/FreeRay.jl?svg=true)](https://ci.appveyor.com/project/ducphucnguyen/FreeRay-jl)
[![Coverage](https://codecov.io/gh/ducphucnguyen/FreeRay.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ducphucnguyen/FreeRay.jl)
[![Coverage](https://coveralls.io/repos/github/ducphucnguyen/FreeRay.jl/badge.svg?branch=master)](https://coveralls.io/github/ducphucnguyen/FreeRay.jl?branch=master)


# AM detection : Random Forest for wind farm noise AM detection

WFN_AM_Detection is a library for detecting AM in wind farm noise. The source code is implemented in Matlab. The classifier may need to retrain with suitable data to get a better performance. This source code provides utilities for

1. Extract acoustics features
2. Detect AM for 10-sec audio files (sampling frequency = 8192 Hz)

## Installation and run example
### Installation

To clone this repository: Please see instruction in [this link](https://au.mathworks.com/help/matlab/matlab_prog/clone-from-git-repository.html).


### Run example
There are two audio files with AM ('AM.wav') and without AM ('NoAM'). The output is probability of AM or not AM.

```Matlab
clc,clear all, close all
% This code is used to extract and predic AM
% Implemented by Phuc NGUYEN, May 2020
%==========================================================================

% input audio file
% filename = 'AM.wav';
filename = 'NoAM.wav';
[x,Fs] = audioread(filename); % read audio files

%% Feature Extraction
% frequency features (Feature 1-13)
TF = FFeature(x,Fs);

% Sound indicator features (Features 14-17)
TS = SFeature(x,Fs);

% time domain features (Features 18-21)
TT = TFeature(x,Fs);

% time domain features unweighted (Feature 22-27)
Tex = TFeature_unweighted(x,Fs);

% IOA published features (Feature 28-29)
Output = [];
input_band = [50 200; 100 400; 200 800];

for j=1:3 % bandpass filter
    %y_band = bandpassedge(x,input_band(j,1), input_band(j,2),Fs);
    y_band = bandpass(x,[input_band(j,1) input_band(j,2)],Fs);
    [Output_bpass] = a1_AM_detection_10sec(y_band,Fs);
    
    if ~isempty(Output_bpass)
        idband = j;
        Output_bpass = [table(idband) Output_bpass];
    end
    
    Output = [Output;Output_bpass];
end

if ~isempty(Output)
    [PR,idx] = max(Output.C);
    Fo = Output.Fo_fundamental(idx);
else
    PR = 0;
    Fo = 0;
end

clear Output Output_bpass

% AMfactor features (Feature 30)
output = a2_AM_detection_10sec(x,Fs);
AMfactor = output.AMfactor;
clear output

% DAM features (Feature 31)
DAM = a3_AM_detection_10sec(x,Fs);

% combined all publshed feature
TP = table(PR,Fo,AMfactor,DAM);

%% Combine 31 features
Tall = [TF TS TT TP Tex];

%% Model Prediction
load('Mdl_best.mat') % load the predictive model

% class 1 is "AM", class 0 is "NoAM", score(1) is probability of "NoAM" and
% score(2) is probability of "AM"
[class,score] = predict(Mdl_best,Tall);

Prob_AM = score(2);
Prob_NoAM = score(1);

table(Prob_AM,Prob_NoAM)



```


## Supporting and Citing

This software was developed as part of academic research. If you would like to help support it, please star the repository. If you use this software as part of your research, teaching, or other activities, we would be grateful if you could cite:

```
@article{nguyen2020machine,
  title={A machine learning approach for detecting wind farm noise amplitude modulation},
  author={Nguyen, Duc Phuc and Hansen, Kristy and Lechat, Bastien and Catcheside, Peter and Zajamsek, Branko},
  year={2020},
  publisher={Preprints}
}
```

## Contribution Guidelines

This package is written and maintained by [Duc Phuc Nguyen](https://github.com/ducphucnguyen). Please fork and
send a pull request or create a [GitHub issue](https://github.com/ducphucnguyen/WFN_AM_Detection/issues) for
bug reports.


## CURRENT ROADMAP

These are not listed in any particular order

- [X] Extract important acoustics features
- [X] Detect AM at distances greater than 1 km in outdoor noise
- [ ] Develop a model which can detect AM at different conditions
- [ ] Towards an universal feature extraction rather than handcrafted-features

