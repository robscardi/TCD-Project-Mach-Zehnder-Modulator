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
wavelength = 1550*nm; % LASER WAVELENGTH
frequency = (3e8)/wavelength;
time_period = 1/frequency;

%% SIMULATION VALUES
prop_factor = 10000000; % DO NOT TOUCH
adj_frequency = frequency/prop_factor; % DO NOT TOUCH
sample_frequency = adj_frequency*100; % DO NOT TOUCH
sample_time = 1/sample_frequency;
delay_factor = 1/(2*pi*adj_frequency);

%% WAVEGUIDE VALUES
kL_factor_s = pi/4; % COUPLING FACTOR SPLITTER
kL_factor_c = pi/4; % COUPLING FACTOR COMBINER

loss_1 = 0*dB/m; % ATTENUATION COEFFICIENT FIRST LINE
loss_2 = 0*dB/m; % ATTENUATION COEFFICIENT FIRST LINE

Length = 5*cm; % LINES LENGHT
gap = 6*um; % GAP BETWEEN DELAY LINE'S ELECTRODE

r33 = 30.8e-12; % LiNbO3 r33
n0 = 2.2111;    % LiNbO3 refractive index
confinment_factor = 0.32; % GUIDE'S CONFINMENT FACTOR

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
input_dim = 26; % NUMBER OF BIT

bit_time = sample_time*bit_sample;

total_time = input_dim*bit_time;





