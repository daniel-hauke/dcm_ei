A Canonical Microcircuit for Estimating E/I Balance
===============
This code implements a new DCM model, which allows inferring E/I balance parameters from M/EEG data and also shows simulations highlighting the effects of changing these parameters.

Citing this code
---------------
To cite this code please cite:
tbd

This code uses the spm12 and the TAPAS toolboxes. Please, also cite these ressources:
SPM12
- Friston et al. (1994). **Statistical parametric maps in functional imaging: A general linear approach**. *Human Brain Mapping*. https://doi.org/10.1002/hbm.460020402

TAPAS:
- Frässle et al. (2021). **TAPAS: An Open-Source Software Package for Translational Neuromodeling and Computational Psychiatry**. *Frontiers in Psychiatry*. https://doi.org/10.3389/fpsyt.2021.680811

TAPAS euler integrator code:
- Schöbi  et al (2021). **A fast and robust integrator of delay differential equations in DCM for electrophysiological data**. *NeuroImage*. https://doi.org/10.1016/j.neuroimage.2021.118567

Important Information
---------------
Running the `'setup_paths'` command for the first time will modify the spm12 and tapas code to make sure the new model runs. This can cause problems with running other analyses using the spm12 version stored with this project. The modified functions and backed-up original functions can be found in the code/toolboxes subfolder).


Getting Started
---------------
Using the github command window:
Clone this repository **recursively(!)**. Otherwise, you will not have all the necessary toolboxes to run the code. You can do so using the following command:
```
git clone --recursive https://github.com/daniel-hauke/dcm_ei.git
```

Or if you are unfamiliar with the github command window, you can:
1. Download the code by pressing on the 'code' button and select 'Download ZIP'.
2. You will then need to manually download SPM12 from here: https://www.fil.ion.ucl.ac.uk/spm/software/spm12/ and save it in the code/toolboxes folder
3. Now download TAPAS from here: https://translationalneuromodeling.github.io/tapas/ and save it in the code/toolboxes folder


Running The Code
---------------
This code was tested using MATLAB R2020b, spm12 (v7771) and TAPAS (v6.0.2).

To run the pipeline, follow these steps:
1. Open MATLAB and navigate to the code folder.
2. Run `'setup_paths'`
3. Run `'run_analysis'`


Members of the project
---------------
- Supervision: Rick Adams, Daniel J. Hauke
- Sponsor: Rick Adams
- Contributions: Julia Rodriguez-Sanchez, Hope Oloye
- Tester for Reproducible Research: Tbd



