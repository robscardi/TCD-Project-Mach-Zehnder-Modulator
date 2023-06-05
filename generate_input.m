

%% GENERATE INPUT
period = 1/adj_frequency;
n_camp = 25*round(period/sample_time);

bit_sample = n_camp;
bit_time = sample_time*bit_sample;
input_dim = 26;

total_time = input_dim*bit_time;
standard_deviation = 0.1;
data = round(rand(1, input_dim))*V_pi + randn(1, input_dim).*standard_deviation;

time = sample_time.*([0:input_dim*bit_sample-1]);

d = repelem(data, bit_sample);
ts = timeseries(d,time);
save("input.mat", "ts", "-v7.3")


