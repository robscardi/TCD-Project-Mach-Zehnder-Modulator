
clearvars
close all
%MACH-ZEHNDER SIMULATION

%% UNIT MEASURE
m = 1;
cm = 1e-2;
um = 1e-6;
nm = 1e-9;
pm = 1e-12;
V = 1;
dB = 1;

%% GUIDE PARAMETERS
gap = 6* um;      % gap between electrode

% LITHIUM NIOBATE PARAMETERS
profile13 = 8.6* pm/V;	
r51 = 28* pm/V;	
r33 = 30.8* pm/V;	
r22 = 3.4* pm/V;	
no = 2.210;	
ne = 2.138;

%wavelength
wavelength = 1550*nm;

%guide
Length = 5* cm;
confinment_factor = 0.32;
phi0 = no*(Length).*(2*pi/wavelength);

RF_pi = (wavelength*gap)/((no^3)*confinment_factor*r33*Length);
E_i_laser = 1*V;

%% SETTINGS : varying RF input, fixed alpha/coupling factor


kL_factor = [
             (pi/4), (pi/4);
             ];

alpha = [0*(dB/cm), 0*(dB/cm);];

[n_alpha, z] = size(alpha);
[n_kl, zz] = size(kL_factor);

%% EXTINTION RATE SIMULATION : varying RF input, fixed alpha/coupling factor 


RF = (-2*RF_pi: 0.01: 2*RF_pi);
ER_rf1 = zeros(numel(alpha(:,1)), numel(kL_factor(:,1)), numel(RF));
ER_rf2 = zeros(numel(alpha(:,1)), numel(kL_factor(:,1)), numel(RF));

result_vector_high  = zeros(2, n_alpha, n_kl, numel(RF));
result_vector_low   = zeros(2, n_alpha, n_kl, numel(RF));


for j = (1: n_alpha)
   
    loss_1 = (alpha(j, 1)/8.6860000037)*Length;
    loss_2 = (alpha(j, 2)/8.6860000037)*Length;

    for k = (1: n_kl)
        
        kL_factor_s = kL_factor(k,1);
        kL_factor_c = kL_factor(k,2);

        Tc_matrix_s = [cos(kL_factor_s)     -1i*sin(kL_factor_s); 
                       -1i*sin(kL_factor_s) cos(kL_factor_s)];
        
        Tc_matrix_c = [cos(kL_factor_c)     -1i*sin(kL_factor_c); 
                       -1i*sin(kL_factor_c) cos(kL_factor_c)];

        for i = (1:numel(RF))
            
            % RF HIGH
            RF_max_input = RF(i);

            dn=-(no^3)*r33*confinment_factor*RF_max_input/(2*gap);


            d_phi = dn*(Length).*(2*pi/wavelength);
        
            MC_matrix_1 = [1*exp((-1i*(phi0+d_phi))-loss_1), 0; 0, 1*exp(-1i*(phi0)-loss_2)];
        
            r1 = Tc_matrix_c*MC_matrix_1*Tc_matrix_s*[E_i_laser, 0]';
        
            result_vector_high(1,j,k,i) = r1(1);
            result_vector_low(2,j,k,i) = r1(2);
        
        
            %RF LOW
            RF_max_input = 0;
        
            dn=-(no^3)*r33*confinment_factor*RF_max_input/(2*gap);
            d_phi = dn*(Length)*(2*pi/wavelength);
        
            MC_matrix_2 = [1*exp((-1i*(phi0+d_phi))-loss_1), 0; 0, 1*exp(-1i*(phi0)-loss_2)];
            r2 = Tc_matrix_c*MC_matrix_2*Tc_matrix_s*[E_i_laser, 0]';
    
            result_vector_low(1,k,j,i) = r2(1);
            result_vector_high(2,k,j,i) = r2(2);

            ER_rf1(j, k, i) = 10*log10((abs(r1(1))^2)/((abs(r2(1))^2)));
            ER_rf2(j, k, i) = 10*log10((abs(r2(2))^2)/((abs(r1(2))^2)));
          
        end
    end
end

%% PLOTS


figure(Name="ER / RF")
tiledlayout(2,1)
nexttile
yline(10, ":r", "label","ER = 10dB", "HandleVisibility","off")
yline(40, ":r", "label","ER = 40dB", "HandleVisibility","off")
xline(RF_pi, ":r", "label", "RF_p_i", "HandleVisibility","off", "LineWidth",1.2)
xline(-RF_pi, ":r", "label", "-RF_p_i", "HandleVisibility","off","LineWidth",1.2)
hold on

for j = (1: n_alpha)
    for k = (1: n_kl)
        data = squeeze(ER_rf1(j,k,:))';
        plot(RF, data, ...
            DisplayName="alpha= " + alpha(j,1)*cm + " [dB/cm]," +alpha(j,2)*cm + "[dB/cm],  kL= " + kL_factor(k,1)/pi + "*pi" + "," +kL_factor(k,2)/pi + "*pi", ...
            LineWidth=1.5) 
    end
end

hold off
grid on
legend
xlabel("RF [V]")
ylabel("ER [dB]")
title("ER/RF BAR")

nexttile
yline(10, ":r", "label","ER=10dB", "HandleVisibility","off")
yline(40, ":r", "label","ER=40dB", "HandleVisibility","off")
xline(RF_pi, ":r", "label", "RF_p_i", "HandleVisibility","off","LineWidth",1.2)
xline(-RF_pi, ":r", "label", "-RF_p_i", "HandleVisibility","off","LineWidth",1.2)
hold on

for j = (1: n_alpha )
    for k = (1: n_kl )
        data = squeeze(ER_rf2(j,k,:))';
        plot(RF, data, ...
            DisplayName="alpha= " + alpha(j,1)*cm + " [dB/cm]," +alpha(j,2)*cm + " [dB/cm],  kL= " + kL_factor(k,1)/pi + "*pi" + "," +kL_factor(k,2)/pi + "*pi", ...
            LineWidth=1.5) 
    end
end

hold off
grid on
legend
xlabel("RF [V]")
ylabel("ER [dB]") 
title("ER/RF CROSS")

%% PLOT output - loss - kL 
   
    figure(Name="Output / RF - kl - Loss ");
    tiledlayout(2,1)
    
    nexttile

    xline(RF_pi, ":r", "label","RF pi", "HandleVisibility","off", ...
        "LineWidth", 1.2)
    xline(-RF_pi, ":r", "label", "-RF_p_i", "HandleVisibility","off","LineWidth",1.2)
    hold on
    
    for j = (1:n_alpha)
        for k = (1:n_kl)
            plot(RF, abs(squeeze(result_vector_high(1,j,k,:))).^2, ...
                DisplayName="alpha= " + alpha(j,1)*cm + " [dB/cm]," +alpha(j,2)*cm + " [dB/cm],  kL= " + kL_factor(k,1)/pi + "*pi" + "," +kL_factor(k,2)/pi + "*pi", ...
                LineWidth=1.5)
        end
    end
    hold off
    grid on
    legend
    xlabel("RF input")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output BAR")

    nexttile

    xline(RF_pi, ":r", "label","RF pi", "HandleVisibility","off", ...
        "LineWidth", 1.2)
    xline(-RF_pi, ":r", "label", "-RF_p_i", "HandleVisibility","off","LineWidth",1.2)
    hold on
    
    for j = (1:n_alpha)
        for k = (1:n_kl)
            plot(RF, abs(squeeze(result_vector_low(2,j,k,:))).^2, ...
                DisplayName="alpha= " + alpha(j,1)*cm + " [dB/cm]," +alpha(j,2)*cm + " [dB/cm],  kL= " + kL_factor(k,1)/pi + "*pi" + "," +kL_factor(k,2)/pi + "*pi", ...
                LineWidth=1.5)
        end
    end
    
    hold off
    grid on
    legend
    xlabel("RF input")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output CROSS")



