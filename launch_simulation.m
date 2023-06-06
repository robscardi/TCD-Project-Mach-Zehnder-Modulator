
clearvars;
close all;

mdl = 'MZexample';
open_system(mdl);

is_model_open = bdIsLoaded(mdl);

num_sims = 500;

model_workspace= get_param(mdl, 'ModelWorkspace');

input_dim = model_workspace.getVariable('input_dim');
sample_time = model_workspace.getVariable('sample_time');
V_pi = model_workspace.getVariable('V_pi');
bit_sample = model_workspace.getVariable('bit_sample');


for j= 1:num_sims
    in(j) = Simulink.SimulationInput(mdl);
    in(j) = in(j).setModelParameter('SimulationMode', 'rapid-accelerator', ...
        'RapidAcceleratorUpToDateCheck', 'on');
    in(j).PreSimFcn = @(x) generate_input(sample_time, ...
        bit_sample, input_dim, V_pi);
    
end

out = parsim(in, 'ShowProgress', 'on');


figure(Name='extinction rate')
yline(10, '-')
hold on
grid on
for j = 1:num_sims
    o = out(j);
    logs = get(o, 'logsout');
    d = get(logs, 'OUT2').Values;
    er = extintion_rate(d, bit_sample);
    scatter(j, er)
end
hold off

if(~is_model_open)
    close_system(mdl, 0);
end
delete(gcp('nocreate'));



