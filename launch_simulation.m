
clearvars;
close all;

mdl = 'MZexample';
open_system(mdl);

is_model_open = bdIsLoaded(mdl);

num_sims = 500; % NUMBER OF SIMULATIONS

model_workspace= get_param(mdl, 'ModelWorkspace');

input_dim = model_workspace.getVariable('input_dim');
sample_time = model_workspace.getVariable('sample_time');
V_pi = model_workspace.getVariable('V_pi');
bit_sample = model_workspace.getVariable('bit_sample');

in(num_sims) = Simulink.SimulationInput(mdl);

for j= 1:num_sims
    in(j) = Simulink.SimulationInput(mdl);
    in(j) = in(j).setModelParameter('SimulationMode', 'rapid-accelerator', ...
        'RapidAcceleratorUpToDateCheck', 'on');
    in(j).PreSimFcn = @(x) generate_input(sample_time, ...
        bit_sample, input_dim, V_pi, 0.01);
end

out = parsim(in, 'ShowProgress', 'on', 'ShowSimulationManager','on');

er = zeros(1, num_sims);
for j = 1:num_sims
    er(j) = extintion_rate(out(j), bit_sample);
end

m = mean(er);
s = std(er);

figure(Name='extinction rate')
yline(10, '-')
hold on
yline(m, '.')
scatter((1:num_sims), er, 'filled')

grid on

hold off
leg_string = "mean = " + m + ", std dev = " + s;
legend('String', leg_string )
if(~is_model_open)
    close_system(mdl, 0);
end



