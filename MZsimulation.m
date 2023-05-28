
clearvars
close all
%%
%MACH-ZENDER SIMULATION

%%
%UNIT MEASURE
m = 1;
cm = 1e-2;
um = 1e-6;
nm = 1e-9;
pm = 1e-12;
V = 1;
%%
%GUIDE PARAMETERS
gap = 6* um;      % gap between electrode

% LITHIUM NIOBATE PARAMETERS
profile13 = 8.6* pm/V;	
r51 = 28* pm/V;	
r33 = 30.8* pm/V;	
r22 = 3.4* pm/V;	
no = 2.210;	
ne = 2.138;

%guide
Lenght = 5* cm;
confinment_factor = 0.32;
%splitter/combiner
kL_factor = [pi/4, pi/3, pi/2, pi]; 
wavelenght = 1550*nm;

%%
%INPUTS
E_i_laser = 5*V;

alpha = (0: 0.01: 3);
ER1 = zeros(1, numel(alpha));
ER2 = zeros(1, numel(alpha));



for j = 1:numel(kL_factor)

    Tc_matrix = [cos(kL_factor(i)), -1i*sin(kL_factor(i)); 
                 -1i*sin(kL_factor(i)), cos(kL_factor(i))];

    for i = 1:numel(alpha)

        % RF HIGH
        RF_max_input = 5;%(wavelenght*gap)/((ne^3)*confinment_factor*r33*Lenght);

        n=-(ne^3)*r33*confinment_factor*RF_max_input/(2*gap);
        d_phi = n*(Lenght).*(2*pi/wavelenght);

        MC_matrix = [exp(-1i*d_phi+(alpha(i)/8.6860000037)), 0; 0, 1];
        result_vector_low = Tc_matrix*MC_matrix*Tc_matrix*[E_i_laser, 0]';

        %RF LOW

        RF_max_input = 0;
        n=-(ne^3)*r33*confinment_factor*RF_max_input/(2*gap);
        d_phi = n*(Lenght)*(2*pi/wavelenght);

        MC_matrix = [1, 0; 0,1];
        result_vector_high = Tc_matrix*MC_matrix*Tc_matrix*[E_i_laser, 0]';
    
        ER1(i) = 20*log(abs(result_vector_high(1))/abs(result_vector_low(1)));
        ER2(i) = 20*log(abs(result_vector_high(2))/abs(result_vector_low(2)));
    end 
    figure(1)
    tiledlayout(1,2)

    %plot ER1
    nexttile
    plot(alpha, ER1)
    xlabel("loss [db/m]");
    ylabel("Extinction rate [db] port 1")
    title("Ectinction rate port 1")
    hold on

    %plot ER2
    nexttile
    plot(alpha, ER2, 'red')
    hold on
    plot(alpha, 10, '.')
    xlabel("loss [db/m]");
    ylabel("Extinction rate [db] port 2")
    title("Ectinction rate port 2")
    hold on
    
end


