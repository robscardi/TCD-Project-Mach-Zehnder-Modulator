

%% GENERATE INPUT

function [noise_ts, unalt_ts ] = generate_input(sample_time, bit_sample, input_dim, V_pi)

% Generate random input with sample time (sample_time), bit time in number of
% sample(bit_sample), number of bit (input_dim), pi-voltage (V_pi) 

standard_deviation = 0.1;
noise = randn(1, input_dim).*standard_deviation;
data = round(rand(1, input_dim))*V_pi;

time = sample_time.*([0:input_dim*bit_sample-1]);

d = repelem(data, bit_sample);
n = repelem(noise, bit_sample);
ts = timeseries(d+n,time);
save("input.mat", "ts", "-v7.3")
noise_ts = ts;
unalt_ts = timeseries(d, time);

end