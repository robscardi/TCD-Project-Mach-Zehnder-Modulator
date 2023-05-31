
clearvars
close all
%MACH-ZENDER SIMULATION

%% UNIT MEASURE
m = 1;
cm = 1e-2;
um = 1e-6;
nm = 1e-9;
pm = 1e-12;
V = 1;
%% GUIDE PARAMETERS
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
%kL_factor = [pi/4, pi/4*1.10, pi/4*0.90, pi/4*1.5];
wavelenght = 1550*nm;

%% INPUTS
E_i_laser = 5*V;

alpha = (0: 0.01: 3);
ER_kL1 = zeros(numel(kL_factor), numel(alpha));
ER_kL2 = zeros(numel(kL_factor), numel(alpha));




result_vector_low = zeros(2, numel(alpha),numel(kL_factor));
result_vector_high = zeros(2, numel(alpha),numel(kL_factor));
for j = 1:numel(kL_factor)

    Tc_matrix = [cos(kL_factor(j)), -1i*sin(kL_factor(j)); 
                 -1i*sin(kL_factor(j)), cos(kL_factor(j))];
 
    for k = 1:numel(alpha)
        
        loss = (alpha(k)/8.6860000037)*Lenght;
        
        % RF HIGH - OUT LOW
        RF_max_input = (wavelenght*gap)/((ne^3)*confinment_factor*r33*Lenght);

        dn=-(ne^3)*r33*confinment_factor*RF_max_input/(2*gap);
        d_phi = dn*(Lenght).*(2*pi/wavelenght);
        
        MC_matrix_1 = [exp((-1i*d_phi)-loss), 0; 0, 1];
        
        r = Tc_matrix*MC_matrix_1*Tc_matrix*[E_i_laser, 0]';
        
        result_vector_low(1,k,j) = r(1);
        result_vector_low(2,k,j) = r(2);
        
        %RF LOW

        RF_max_input = 0;
        dn=-(ne^3)*r33*confinment_factor*RF_max_input/(2*gap);
        d_phi = dn*(Lenght)*(2*pi/wavelenght);
        
        MC_matrix_2 = [exp((-1i*d_phi)-loss), 0; 0 , 1];
        r = Tc_matrix*MC_matrix_2*Tc_matrix*[E_i_laser, 0]';
    
        result_vector_high(1,k,j) = r(1);
        result_vector_high(2,k,j) = r(2);

        ER_kL1(j, k) = 10*log(abs(result_vector_high(1,k,j))^2/abs((result_vector_low(1,k,j))^2));
        ER_kL2(j, k) = 10*log(abs(result_vector_high(2,k,j))^2/abs((result_vector_low(2,k,j))^2));
    end
end
%% PLOT kL - Loss diagrams    
    
    mycolors = [1 0 0; 0 1 0; 0 0 1; 1 0 1];
    ax = gca;
    ax.ColorOrder = mycolors;
    

    figure(Name="ER/loss - kL");
    tiledlayout(1,2)

    %plot ER1
    nexttile
    plot(alpha, ER_kL1(1,:), DisplayName="kL Factor = pi/4")
    hold on
    plot(alpha, ER_kL1(2,:), DisplayName="kL Factor = pi/3")
    plot(alpha, ER_kL1(3,:), DisplayName="kL Factor = pi/2")
    plot(alpha, ER_kL1(4,:), DisplayName="kL Factor = pi/1")
    hold off
    legend
    grid on
    xlabel("loss [db/m]");
    ylabel("Extinction rate [db] port 1")
    title("Extinction rate port 1")
   

    %plot ER2
    nexttile
    plot(alpha, ER_kL2(1,:), DisplayName="kL Factor = pi/4")
    hold on
    plot(alpha, ER_kL2(2,:), DisplayName="kL Factor = pi/3")
    plot(alpha, ER_kL2(3,:), DisplayName="kL Factor = pi/2")
    plot(alpha, ER_kL2(4,:), DisplayName="kL Factor = pi/1")
    hold off
    legend
    grid on
    xlabel("loss [db/m]");
    ylabel("Extinction rate [db] port 2")
    title("Extinction rate port 2")

%% PLOT output - loss - kL 
    figure(Name="output / loss - kL ");
    tiledlayout(2,2)
    
    nexttile
    grid on
    plot(alpha, abs(result_vector_high(1,:,1)).^2, DisplayName="kL Factor = pi/4")
    hold on
    plot(alpha, abs(result_vector_high(1,:,2)).^2, DisplayName="kL Factor = pi/4")
    plot(alpha, abs(result_vector_high(1,:,3)).^2, DisplayName="kL Factor = pi/4")
    plot(alpha, abs(result_vector_high(1,:,4)).^2, DisplayName="kL Factor = pi/4")
    hold off
    legend
    xlabel("Loss [db/m]")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output high port 1")
    
    nexttile
    plot(alpha, abs(result_vector_high(2,:,1)).^2, DisplayName="kL Factor = pi/4")
    hold on
    plot(alpha, abs(result_vector_high(2,:,2)).^2, DisplayName="kL Factor = pi/4")
    plot(alpha, abs(result_vector_high(2,:,3)).^2, DisplayName="kL Factor = pi/4")
    plot(alpha, abs(result_vector_high(2,:,4)).^2, DisplayName="kL Factor = pi/4")
    hold off
    legend
    xlabel("Loss [db/m]")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output high port 2")

    nexttile
    grid on
    plot(alpha, abs(result_vector_low(1,:,1)).^2, DisplayName="kL Factor = pi/4")
    hold on
    plot(alpha, abs(result_vector_low(1,:,2)).^2, DisplayName="kL Factor = pi/4")
    plot(alpha, abs(result_vector_low(1,:,3)).^2, DisplayName="kL Factor = pi/4")
    plot(alpha, abs(result_vector_low(1,:,4)).^2, DisplayName="kL Factor = pi/4")
    hold off
    legend
    xlabel("Loss [db/m]")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output low port 1")

    nexttile
    grid on
    plot(alpha, abs(result_vector_low(2,:,1)).^2, DisplayName="kL Factor = pi/4")
    hold on
    plot(alpha, abs(result_vector_low(2,:,2)).^2, DisplayName="kL Factor = pi/4")
    plot(alpha, abs(result_vector_low(2,:,3)).^2, DisplayName="kL Factor = pi/4")
    plot(alpha, abs(result_vector_low(2,:,4)).^2, DisplayName="kL Factor = pi/4")
    hold off
    legend
    xlabel("Loss [db/m]")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output low port 2")




alpha = [0; 0.01 ; 0.05; 0.10; 0.15];
kL_factor = (-pi/4: 0.01: pi/4);

ER_a1 = zeros(numel(alpha), numel(kL_factor));
ER_a2 = zeros(numel(alpha), numel(kL_factor));


for j = 1:numel(alpha)

    loss = alpha(j)/8.6860000037;
    for k = 1:numel(kL_factor)

       Tc_matrix = [cos(kL_factor(j)), -1i*sin(kL_factor(j)); 
                   -1i*sin(kL_factor(j)), cos(kL_factor(j))];

        % RF HIGH
        RF_max_input = 5;%(wavelenght*gap)/((ne^3)*confinment_factor*r33*Lenght);

        dn=-(ne^3)*r33*confinment_factor*RF_max_input/(2*gap);
        d_phi = dn*(Lenght).*(2*pi/wavelenght);

        MC_matrix = [exp(-1i*d_phi-loss), 0; 0, 1];
        result_vector_low = Tc_matrix*MC_matrix*Tc_matrix*[E_i_laser, 0]';

        %RF LOW

        RF_max_input = 0;
        dn=-(ne^3)*r33*confinment_factor*RF_max_input/(2*gap);
        d_phi = dn*(Lenght)*(2*pi/wavelenght);

        MC_matrix = [exp(-1i*d_phi-loss), 0; 0, 1];
        result_vector_high = Tc_matrix*MC_matrix*Tc_matrix*[E_i_laser, 0]';
    
        ER_a1(j, k) = 10*log(abs(result_vector_high(1)^2)/abs(result_vector_low(1)^2));
        ER_a2(j, k) = 10*log(abs(result_vector_high(2)^2)/abs(result_vector_low(2)^2));
    end
end


%% ER/kL Factor - Loss
figure(Name="ER/kL_factor - loss");
tiledlayout(1,2)

    %plot ER1
    nexttile
    plot(kL_factor, ER_a1(1,:), DisplayName="alpha = 0")
    hold on
    plot(kL_factor, ER_a1(2,:), DisplayName="alpha = 0.01")
    plot(kL_factor, ER_a1(3,:), DisplayName="alpha = 0.05")
    plot(kL_factor, ER_a1(4,:), DisplayName="alpha = 0.10")
    plot(kL_factor, ER_a1(5,:), DisplayName="alpha = 0.15")
    hold off
    legend
    grid on
    xlabel("kL factor");
    ylabel("Extinction rate [db] port 1")
    title("Extinction rate port 1")
   

    %plot ER2
    nexttile
    plot(kL_factor, ER_a2(1,:), DisplayName="alpha = 0")
    hold on
    plot(kL_factor, ER_a2(2,:), DisplayName="alpha = 0.01")
    plot(kL_factor, ER_a2(3,:), DisplayName="alpha = 0.05")
    plot(kL_factor, ER_a2(4,:), DisplayName="alpha = 0.10")
    plot(kL_factor, ER_a2(5,:), DisplayName="alpha = 0.15")
    hold off
    legend
    xlabel("kL Factor");
    ylabel("Extinction rate [db] port 2")
    title("Extinction rate port 2")











