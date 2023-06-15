
clearvars;
close all;

mdl = 'MZexample';
open_system(mdl);

is_model_open = bdIsLoaded(mdl);

model_workspace= get_param(mdl, 'ModelWorkspace');


model_workspace.assignin("input_dim", 50);
bit_sample = model_workspace.getVariable('bit_sample');
sample_time = model_workspace.getVariable('sample_time');
input_dim = model_workspace.getVariable('input_dim');
prop_factor = model_workspace.getVariable('prop_factor');


bit_time = sample_time*bit_sample;
total_time = input_dim*bit_time;

model_workspace.assignin("total_time", total_time);

fs = model_workspace.getVariable('sample_frequency');

V_pi = model_workspace.getVariable('V_pi');

sim_input = Simulink.SimulationInput(mdl);
sim_input = sim_input.setModelParameter('SimulationMode', 'rapid-accelerator', ...
        'RapidAcceleratorUpToDateCheck', 'on');

ts = generate_input(sample_time, bit_sample, input_dim, V_pi);
in_d = squeeze(ts.Data);
in_n = length(in_d);
input_ft = fftshift(abs(fft(in_d, in_n)));
max_in = max(input_ft);

out = sim(sim_input, "ShowProgress","on");

f = (0:length(input_ft)-1)*fs/length(input_ft);
fshift_i = (-in_n/2:in_n/2-1)*(fs/in_n)*prop_factor;

logs = get(out, 'logsout');
out_ts = get(logs, 'OUT2').Values;

out_d = squeeze(out_ts.Data);
out_n = length(out_d);

out_ft = fftshift(abs(fft(out_d, out_n)));
max_out = max(out_ft);

fshift_o = (-out_n/2:out_n/2-1)*(fs/out_n)*prop_factor; 

figure(1)
tiledlayout(2,1)
nexttile
plot(fshift_i,(input_ft./max_in))
ylabel('Magnitude/Max')
xlabel('Frequency [Hz]')
xlim auto
ylim auto

nexttile
plot(fshift_o, (out_ft./max_out))
ylabel('Magnitude/Max')
xlabel('Frequency [Hz]')
xlim auto
ylim auto



