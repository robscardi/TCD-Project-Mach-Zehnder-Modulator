
clearvars;
close all;

mdl = 'MZexample';
open_system(mdl);

is_model_open = bdIsLoaded(mdl);

model_workspace= get_param(mdl, 'ModelWorkspace');


model_workspace.assignin("input_dim", 30);
bit_sample = model_workspace.getVariable('bit_sample');
sample_time = model_workspace.getVariable('sample_time');
input_dim = model_workspace.getVariable('input_dim');
prop_factor = model_workspace.getVariable('prop_factor');
laser_freq = model_workspace.getVariable('frequency');

bit_time = sample_time*bit_sample;
total_time = input_dim*bit_time;

model_workspace.assignin("total_time", total_time);

fs = model_workspace.getVariable('sample_frequency');

V_pi = model_workspace.getVariable('V_pi');

sim_input = Simulink.SimulationInput(mdl);
sim_input = sim_input.setModelParameter('SimulationMode', 'rapid-accelerator', ...
        'RapidAcceleratorUpToDateCheck', 'off');

sim_input = sim_input.setModelParameter(StartTime="0", StopTime=string(total_time));
    
[noise_ts, unalt_ts] = generate_input(sample_time, bit_sample, input_dim, V_pi, 0.1);
sim_input = sim_input.setVariable("noise_ts", noise_ts, "Workspace",mdl);
ts = noise_ts;

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

hfig = figure(1);
    
%Set figure config 
picturewidth = 20; % set this parameter and keep it forever
hw_ratio = 0.65; % feel free to play with this ratio
set(hfig,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
set(findall(hfig,'-property','FontSize'),'FontSize',17) % adjust fontsize to your document
fontname("CMU Sans Serif Demi Condensed")

tiledlayout(2,1)

nexttile
plot(fshift_i,(input_ft./max_in), 'LineWidth', 1.5)
ylabel('Magnitude/Max')
xlabel('Frequency [Hz]')
xlim auto
ylim auto
fontname("CMU Sans Serif Demi Condensed")

nexttile
plot(fshift_o, (out_ft./max_out), 'LineWidth', 1.5)
xline(-laser_freq, 'LabelOrientation','horizontal', ...
    'Label',string(-laser_freq/(10^12)) + " [THz]", ...
    'Color', 'black', ...
    'LineWidth', 1.2)
xline(laser_freq, 'LabelOrientation','horizontal', ...
    'Label',string(laser_freq/(10^12)) + " [THz]", ...
    'Color', 'black', ...
    'LineWidth', 1.2)

ylabel('Magnitude/Max')
xlabel('Frequency [Hz]')
xlim auto
ylim auto
fontname("CMU Sans Serif Demi Condensed")


pos = get(hfig,'Position');
set(hfig,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
print(hfig,'RF_alpha','-dpdf','-vector','-fillpage')


