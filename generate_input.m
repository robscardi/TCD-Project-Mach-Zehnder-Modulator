
%% SAMPLE TIME

frequency = (3e8)/wavelenght;
time_period = 1/frequency;
prop_factor = 10000000;
adj_frequency = frequency/prop_factor;
sample_frequency = adj_frequency*100;
sample_time = 1/sample_frequency;


%% GENERATE INPUT
bit_sample = 100;
bit_time = sample_time*bit_sample;
input_dim = 1000;

total_time = input_dim*bit_time;
standard_deviation = 0.5;
data = zeros(input_dim);
for j =(1:input_dim)

    if(rand(1) <= 0.5)
        data(j) = randi()*standard_deviation;
    else
        data(j) = 1*V_pi + randi()*standard_deviation;
    end 
end
time = sample_time*[0:input_dim*bit_sample];
d = repelem(data, bit_sample);
ts = timeseries(d,time);
save("input.mat", "ts", "-v7.3")


