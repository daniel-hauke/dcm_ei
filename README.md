A Canonical Microcircuit for Estimating E/I Balance
===============
This code implements a new DCM model, which allows inferring E/I balance parameters from M/EEG data and also shows simulations highlighting the effects of changing these parameters.

Citing This Code
---------------
To cite this code please cite:
- Hauke, Rodriguez-Sanchez, Oloye, Berndt, Pinotsis, Friston, Mathalon, & Adams (2026). **A Canonical Microcircuit for Estimating Excitation/Inhibition (E/I) Balance**. *Translational Psychiatry*. https://doi.org/10.1038/s41398-026-04312-y

This code uses the spm12 and the TAPAS toolboxes. Please, also cite these resources:
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

Running the E/I model
---------------
This code was tested using MATLAB R2020b, spm12 (v7771) and TAPAS (v6.0.2).

Unfortunately, we cannot share the original data, but you can run the model on a publicly available example passive oddball (MMN) dataset by Garrido et al. (2007)
- Garrido, Kilner, Kiebel, Stephan, & Friston (2007). **Dynamic causal modelling of evoked potentials: a reproducibility study.** *NeuroImage*. https://doi.org/10.1016/j.neuroimage.2007.03.014
 
To get this data:
- go to: https://www.fil.ion.ucl.ac.uk/spm/data/eeg_mmn/
- download preproccessed MMN data: maeMdfspm8_subject1.zip and unzip 

To run the pipeline, follow these steps:
1. Open MATLAB and navigate to the code folder.
2. Run `'setup_paths.m'`
3. Update the paths to the maeMdfspm8_subject1.mat data file, the results folder and the prior file at the top of the `'run_model_example.m'`script
4. Run `'run_model_example.m'`

There are further instructions in the run_model_example script to run the model on the paired-click and active oddball (P300) paradigms.

The prior files from the grandmean healthy controls inversion reported in the paper can be found inside the code/priors folder. For analysis in healthy controls or  psychiatric conditions (other than schizophrenia) we recommend using these priors. If you are interested in priors that were enriched for psychosis risk you can download priors for the passive oddball (MMN) and active oddball (P300) paradigms from this paper applying the model to data from individuals at clinical high risk for psychosis here:
- Rodriguez-Sanchez*, Hauke*, et al. (2026). **Biophysical Modeling of Excitation/Inhibition Balance and Conversion to Psychosis in the Clinical High Risk Syndrome.** *Biological Psychiatry*. https://doi.org/10.1016/j.biopsych.2026.04.007


Replicating the paper analysis
---------------
This code was tested using MATLAB R2020b, spm12 (v7771) and TAPAS (v6.0.2).

To run the pipeline, follow these steps:
1. Open MATLAB and navigate to the code folder.
2. Run `'setup_paths.m'`
3. Run `'run_paper_analysis.m'`


Members of the project
---------------
- Supervision: Rick Adams, Daniel J. Hauke
- Sponsor: Rick Adams
- Contributors: Julia Rodriguez-Sanchez, Hope Oloye, Lioba Berndt, Dimitris Pinotsis, Karl Friston, Daniel Mathalon



