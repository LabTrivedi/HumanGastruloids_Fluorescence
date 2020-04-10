# Human_Gastruloids_Fluorescence

This is a MATLAB code, the purspose of which is to read a .tif file containing multi-channel 2D image from gastruloid samples and quantify the intesnity profile along the long axis. 

The code requires the user to 
(1) Specify Input and output folder paths

(2) Specify the order and identity of channels (specifically for the Bright field image in the .tif file)

(3) Core of the filenames to be used for output

(4) When prompted, select a background and signal region for one example image



Once the code running completed the user can expect the following output files in the output folder specified

(1) Raw intensity profiles in both _.pdf_ and _.fig_ formats

(2) Normalized intensity profiles in both _.pdf_ and _.fig_ formats

(3) Normalized intensity profiles with normalized axes lengths in both _.pdf_ and _.fig_ formats

(4) A merged profile for all conditions or stages (if they exist) in both _.pdf_ and _.fig_ formats

(5) A _.mat_ file (with suffix _CorrectedResampledNormalizedProfiles_AllStages.mat_) containing raw data points in an array _NormalizedIntensityrange_lengthwise_resampled_all_.

(6) The option to convert _.mat_ files into _.xls_ files using the code _Gastruloids_LengthAnalysis_XLSfromMatfile.m_.
