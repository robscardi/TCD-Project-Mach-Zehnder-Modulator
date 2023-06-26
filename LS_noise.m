
clearvars;
close all;

mdl = 'MZexample';
open_system(mdl);

is_model_open = bdIsLoaded(mdl);

d_noise = linspace(0.01, 0.2);
num_sims = numel(d_noise);

model_workspace= get_param(mdl, 'ModelWorkspace');

sample_time = model_workspace.getVariable('sample_time');
V_pi        = model_workspace.getVariable('V_pi');
bit_sample  = model_workspace.getVariable('bit_sample');

%% ASSIGNING INPUT DIMENSION
input_dim   = 500;
bit_time    = sample_time*bit_sample;
total_time  = input_dim*bit_time;

model_workspace.assignin('total_time', total_time);
model_workspace.assignin('input_dim', input_dim);

%% RETRIEVING MODEL PARAMETERS 

alpha_1 = model_workspace.getVariable('loss_1');
alpha_2 = model_workspace.getVariable('loss_2');

kL_factor_s = model_workspace.getVariable('kL_factor_s');
kL_factor_c = model_workspace.getVariable('kL_factor_c');

%% SIMULATION

in(num_sims) = Simulink.SimulationInput(mdl);
for j= 1 :num_sims
    in(j) = Simulink.SimulationInput(mdl);
    in(j) = in(j).setModelParameter('SimulationMode', 'accelerator');
    in(j) = in(j).setModelParameter(StartTime="0", StopTime=string(total_time));
    
    [noise_ts, unalt_ts] = generate_input(sample_time, bit_sample, input_dim, V_pi, d_noise(j));
    in(j) = in(j).setVariable("noise_ts", noise_ts, "Workspace",mdl);
end

out = parsim(in, 'ShowProgress', 'on', 'ShowSimulationManager','on');

er = zeros(1, num_sims);


for j = 1:num_sims
    er(j) = extintion_rate(out(j), bit_sample);

end

%% PLOT
figure(Name='extinction rate')
yline(10, '-')
hold on
scatter(d_noise, er, 'filled')
xlabel("Noise standard deviation")
ylabel("Extintion Rate [dB]")

leg_string_modulator_parms = "$\alpha_1$ =  " + alpha_1 + ' (dB/cm)'+ newline + '$\alpha_2$ = ' + alpha_2 + ' (dB/cm)'+ newline + "kL factor splitter = " + kL_factor_s/pi + 'pi' + newline + 'kL factor combiner = ' + kL_factor_c/pi + 'pi';
legend('String', leg_string_modulator_parms, 'Interpreter','latex' )
xlim([0.01, 0.2])
grid on

hold off
if(~is_model_open)
    close_system(mdl, 0);
end
delete(gcp('nocreate'));

