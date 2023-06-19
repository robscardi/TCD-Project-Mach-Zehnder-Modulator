
clearvars;
close all;

mdl = 'MZexample';
open_system(mdl);

is_model_open = bdIsLoaded(mdl);

num_sims = 500; % NUMBER OF RUNS

model_workspace = get_param(mdl, 'ModelWorkspace');

input_dim   = model_workspace.getVariable('input_dim');
sample_time = model_workspace.getVariable('sample_time');
V_pi        = model_workspace.getVariable('V_pi');
bit_sample  = model_workspace.getVariable('bit_sample');

in(num_sims) = Simulink.SimulationInput(mdl);

bit_time    = sample_time*bit_sample;
total_time  = input_dim*bit_time;

unalts(num_sims) = timeseries();

for j= 1:num_sims
    in(j) = Simulink.SimulationInput(mdl);
    in(j) = in(j).setModelParameter('SimulationMode', 'rapid-accelerator', ...
        'RapidAcceleratorUpToDateCheck', 'on');
    in(j) = in(j).setModelParameter(StartTime="0", StopTime=string(total_time));
    
    [noise_ts, unalt_ts] = generate_input(sample_time, bit_sample, input_dim, V_pi, 0.1);
    unalts(j) = unalt_ts;
    in(j) = in(j).setVariable("noise_ts", noise_ts, "Workspace",mdl);
end

out = parsim(in, 'ShowProgress', 'on', 'ShowSimulationManager','on');

er = zeros(1, num_sims);
bit_error = zeros(1, num_sims);
for j = 1:num_sims
    er(j) = extintion_rate(out(j), bit_sample);
    bit_error(j) = error_bit(out(j), bit_sample, unalts(j), V_pi/2);
end

m_er = mean(er);
s_er = std(er);
m_eb = mean(bit_error./input_dim);
s_eb = std(bit_error_rate./input_dim);


figure(Name='extinction rate')
yline(10, '-', 'label', "ER = 10[dB")
yline(40, '-', 'label', "ER = 40[dB")
hold on
yline(m_er, '.', 'LineWidth', 1.5, 'Color','black', 'Label',  "Average Extinction Rate")
scatter((1:num_sims), er, 'red', 'o', 'filled')
scatter((1:num_sims), bit_error, 'black')
ylabel("Extinction Rate [dB]"),
xlabel("# Run")
grid on

hold off
leg_string_ER = "Ext.Rate : mean = " + m_er + ", std dev = " + s_er;
leg_string_BE = "Err.Rate : mean = " + m_eb + ", std dev = " + s_eb;
legend('String', leg_string_ER + newline + leg_string_BE )
if(~is_model_open)
    close_system(mdl, 0);
end



