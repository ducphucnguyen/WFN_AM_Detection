# WFN_AM_Detection
Detection of wind farm noise amplitude modulation using Random Forest


To run the code: >>MainAMdetection

-----------------------------------
FFeature.m

SFeature.m

TFeature.m

TFeature_unweighted.m

a1_AM_detection_10sec.m

a2_AM_detection_10sec.m

a3_AM_detection_10sec.m

MainAMdetection.m

Mdl_best.mat

These are the MATLAB code files (.m) for Audio Feature extraction and AM prediction in: 

Nguyen et al. A machine learning based for detecting wind farm noise amplitude modulation, 2020

These files can be opened with a text editor to view, but require MATLAB software to run (http://www.mathworks.com/products/matlab/)


Note that: The predictive model may need to train to get the best results!


# FreeRay

[![Build Status](https://travis-ci.com/ducphucnguyen/FreeRay.jl.svg?branch=master)](https://travis-ci.com/ducphucnguyen/FreeRay.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/github/ducphucnguyen/FreeRay.jl?svg=true)](https://ci.appveyor.com/project/ducphucnguyen/FreeRay-jl)
[![Coverage](https://codecov.io/gh/ducphucnguyen/FreeRay.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/ducphucnguyen/FreeRay.jl)
[![Coverage](https://coveralls.io/repos/github/ducphucnguyen/FreeRay.jl/badge.svg?branch=master)](https://coveralls.io/github/ducphucnguyen/FreeRay.jl?branch=master)

[![Latest Docs](https://img.shields.io/badge/docs-latest-blue.svg)](https://ducphucnguyen.github.io/FreeRay.jl/build/)

# FreeRay : Bellhop for Outdoor Sound Propagation

FreeRay.jl is a library for outdoor noise propagation. Numerical ray tracing models are implemented using Bellhop ray tracing program written in Fortran by Michael Porter. FreeRay.jl provides utilities for

1. Prepare input files, run Bellhop and plot output.
2. Run Bellhop parallel.

## Installation
### FreeRay.jl package

Download [Julia 1.5](https://julialang.org/) or later.

FreeRay.jl is under development and thus is not registered. To install it simply open a julia REPL and do

```Julia
`] add https://github.com/ducphucnguyen/FreeRay.jl.git`.
```

### Installation Bellhop
Before we can use FreeRay, we need to install Bellhop first. The source code can be download from this website [Bellhop](http://oalib.hlsresearch.com/AcousticsToolbox/). installation details are provided in the website. If you have no experience with programming languages such as C or Fortran, it will take sometime to install Bellhop!

To check if Bellhop is successfully installed, we run this command in Julia REPL. If we can see the bellow error, this means that we successfully install Bellhop.  Congratulation!

```julia
run(`bellhop`)

STOP Fatal Error: Check the print file for details
Process(`bellhop`, ProcessExited(0))
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
send a pull request or create a [GitHub issue](https://github.com/ducphucnguyen/FreeRay.jl/issues) for
bug reports. If you are submitting a pull request make sure to follow the official
[Julia Style Guide](https://docs.julialang.org/en/v1/manual/style-guide/index.html) and please use
4 spaces and NOT tabs.


## CURRENT ROADMAP

These are not listed in any particular order

- [X] Run most of outdoor sound propagation problems
- [X] Plot output: ray, transmission loss
- [ ] Upgrade for 3D ray tracing using Bellhop3D
- [ ] Test parallel running

