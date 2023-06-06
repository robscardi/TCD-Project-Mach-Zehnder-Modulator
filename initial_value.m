clearvars
close all

%% UNIT MEASURE
m = 1;
cm = 1e-2;
um = 1e-6;
nm = 1e-9;
pm = 1e-12;
v = 1;
dB = 1;

%% LASER VALUES
wavelength = 1550*nm;
frequency = (3e8)/wavelength;
time_period = 1/frequency;
prop_factor = 10000000;
adj_frequency = frequency/prop_factor;
sample_frequency = adj_frequency*100;
sample_time = 1/sample_frequency;

delay_factor = 1/(2*pi*adj_frequency);

%% WAVEGUIDE VALUES
kL_factor_s = pi/4;
kL_factor_c = pi/4;

loss_1 = 0*dB/m;
loss_2 = 0*dB/m;
Length = 5*cm;
gap = 6*um;

r33 = 30.8e-12;
n0 = 2.2111;  
confinment_factor = 0.32;
    
V_pi = (wavelength*gap)/((n0^3)*confinment_factor*r33*Length);

loss_factor_1 = exp(-(loss_1/8.6860000037)*Length);
loss_factor_2 = exp(-(loss_2/8.6860000037)*Length);

%% Utility constant
pi_half_delay = time_delay(-pi/2, delay_factor);
maximun_time_delay = time_delay(2*pi, delay_factor);
pi_half_delay_sample = discrete_sample_delay(-pi/2, delay_factor, sample_time);

%% delay block parameter, do not decrease
initial_buffer = 1024*10;

%% SAMPLE AND SIMULTATION TIME
period = 1/adj_frequency;
n_camp = 25*round(period/sample_time);

bit_sample = n_camp;
input_dim = 26;

bit_time = sample_time*bit_sample;

total_time = input_dim*bit_time;





