mdl = 'MZexample';
open_system(mdl);

num_sims = 5;

for j= 1:num_sims
    in(j) = Simulink.SimulationInput(mdl);
    in(j) = in(j).setModelParameter('SimulationMode', 'rapid', ...
        'RapidAcceleratorUpToDateCheck', 'off');
    in(j).PreSimFcn = @(x) generate_input;
    
end

out = parsim(in, 'ShowProgress', 'on');


figure("extinction rate")
yline(10, "-")
hold on
grid on
for j = 1:num_sims
    o = out(j);
    d = o.logsout.get.('OUT2').Values;
    er = extintion_rate(d, bit_samples);
    scatter(j, er)
end
hold off

