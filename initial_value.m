clearvars
close all

% Initialize the model's parameters
%% UNIT MEASURE
m   = 1;
cm  = 1e-2;
um  = 1e-6;
nm  = 1e-9;
pm  = 1e-12;
v   = 1;
dB  = 1;

%% LASER VALUES
wavelength  = 1550*nm;              % LASER WAVELENGTH
frequency   = (3e8)/wavelength;     % LASER FREQUENCY
time_period = 1/frequency;          % LASER PERIOD

%% SIMULATION VALUES (DO NOT MODIFY)
prop_factor         = 10000000;                 % FREQUENCY/SIMULATION FREQUENCY FACTOR
adj_frequency       = frequency/prop_factor;    % SIMULATION FREQUENCY 
sample_frequency    = adj_frequency*100;        % SAMPLE FREQUENCY
sample_time         = 1/sample_frequency;       % SAMPLE TIME
delay_factor        = 1/(2*pi*adj_frequency);   % COMMON USED VALUE 

%% WAVEGUIDE VALUES
kL_factor_s = pi/4; % COUPLING FACTOR SPLITTER
kL_factor_c = pi/4; % COUPLING FACTOR COMBINER

loss_1  = 0*dB/m; % ATTENUATION COEFFICIENT FIRST LINE
loss_2  = 0*dB/m; % ATTENUATION COEFFICIENT FIRST LINE

Length  = 5*cm; % LINES LENGHT
gap     = 6*um; % GAP BETWEEN DELAY LINE'S ELECTRODE

r33                 = 30.8e-12;     % LiNbO3 r33
n0                  = 2.2111;       % LiNbO3 ordinary refractive index
confinment_factor   = 0.32;         % GUIDE'S CONFINMENT FACTOR

V_pi = (wavelength*gap)/((n0^3)*confinment_factor*r33*Length); % PI VOLTAGE

loss_factor_1 = exp(-(loss_1/8.6860000037)*Length);
loss_factor_2 = exp(-(loss_2/8.6860000037)*Length);

%% Utility constant (DO NOT MODIFY)
pi_half_delay           = time_delay(-pi/2, delay_factor);
maximun_time_delay      = time_delay(2*pi, delay_factor);
pi_half_delay_sample    = discrete_sample_delay(-pi/2, delay_factor, sample_time);

%% delay block parameter, do not decrease
initial_buffer = 1024*100; % TIME DELAY BLOCK BUFFER

%% INPUT, SAMPLE AND SIMULTATION TIME
period      = 1/adj_frequency;  % ADJUSTED LASER PERIOD
n_camp      = 25*round(period/sample_time);  % NUMBER OF SAMPLE

bit_sample  = n_camp;                   % SAMPLE NUMBER PER BIT
input_dim   = 40;                       % INPUT'S BITS NUMBER
bit_time    = sample_time*bit_sample;   % BIT TIME
total_time  = input_dim*bit_time;       % TOTAL SIMULATION TIME

std_dev = 0.1;                          % NOISE STANDARD DEVIATION

[noise_ts, unalt_ts] = generate_input(sample_time, bit_sample, input_dim, V_pi, std_dev);

save("values")



