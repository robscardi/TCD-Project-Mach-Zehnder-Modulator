
clearvars
close all

%UNIT MEASURE
m = 1;
cm = 1e-2;
um = 1e-6;
nm = 1e-9;
pm = 1e-12;
v = 1;
dB = 1;


%LASER VALUES
wavelenght = 1550*nm;
frequency = (3e8)/wavelenght;
time_period = 1/frequency;
prop_factor = 10000000;
adj_frequency = frequency/prop_factor;
sample_frequency = adj_frequency*100;
sample_time = 1/sample_frequency;

delay_factor = 1/(2*pi*adj_frequency);

%WAVEGUIDE VALUES
kL_factor = pi/4;
loss = 0*dB/m;
Length = 5*cm;
gap = 6*um;

r33 = 30.8e-12;
n0 = 2.2111;  
confinment_factor = 0.32;
    
V_pi = (wavelenght*gap)/((n0^3)*confinment_factor*r33*Length);

loss_factor = exp(-(loss/8.6860000037)*Length);

%# Utility constant
pi_half_delay = time_delay(-pi/2, delay_factor);
pi_half_delay_sample = discrete_sample_delay(-pi/2, delay_factor, sample_time);

%#Utility Functions
function t = time_delay(phi, delay_factor) 
    p = wrapTo2Pi(phi);
    t = p*delay_factor;
end
