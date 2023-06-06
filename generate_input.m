

%% GENERATE INPUT

function generate_input(sample_time, bit_sample, input_dim, V_pi)

standard_deviation = 0.1;
data = round(rand(1, input_dim))*V_pi + randn(1, input_dim).*standard_deviation;

time = sample_time.*([0:input_dim*bit_sample-1]);

d = repelem(data, bit_sample);
ts = timeseries(d,time);
save("input.mat", "ts", "-v7.3")


