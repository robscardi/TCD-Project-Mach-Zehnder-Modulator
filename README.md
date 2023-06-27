# Transmission And Communication Devices - Project: Mach-Zehnder Modulator simulation and modeling
Final exam project for the Transmission and Communication Devices course @Polimi. Professor : Francesco Morichetti
# Contents
This repository contains several Matlab&copy; scripts that help with the analysis and study of the Mach-Zehnder Modulator and a Simulink&copy; <br />
  <br />
__MZS_ER_alpha.m__, __MZS_ER_kL.m__, __MZS_ER_RF.m__ <br />
These Matlab&copy; These scripts calculate and plot the extinction ratio and the intensity of the electric field for each output
of a Mach-Zehnder modulator sweeping over three groups of parameters: 
in order, the attenuation constant of the device's lines, the coupling factor of the splitter and combiner, and the value of the RF digital high input <br />
  <br />
__MZexample.slx__ <br />
The Simulink&copy; model of a Mach-Zehnder modulator, more information later. <br />
<br />
__Splitter_calculator.mlx__, __Intensity_calculator.mlx__, __Generate_input_script.mlx__ <br />
To simplify the analysis and the use of the model, three Matlab LiveScripts are provided. <br />
Generate_input_script.mlx can be used to visualize and directly set the model's input. <br />
Splitter_calculator.mlx calculates and visually represents the percentage ratio of output intensities from a splitter/combiner compared to the total intensity of the input. <br />
Intensity_calculator.mlx script provides similar functionality, allowing the user to visualize the ratio of output intensities for the entire modulator, considering appropriate parameters.
__LS_Base.m__, __LS_Fourier.m__, __LS_noise.m__ <br />
These scripts launch simulations with the MZexample.slx Simulink&copy; model. It is advised to install the Parallel Computing Toolbox&copy; to use them.
# How to use the model
  * Set the desired parameters inside the initial_value.m script 
  * Run the script: a values.mat file will be generated
  * In Simulink: Explore-> MZexample-> Model Workspace-> Reinitialize from Source 
  * Run the simulation
