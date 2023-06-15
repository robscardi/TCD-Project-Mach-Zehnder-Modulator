
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
phi0 = ne*(Length).*(2*pi/wavelength);

RF_pi = (wavelength*gap)/((ne^3)*confinment_factor*r33*Length);
E_i_laser = 1*V;

%% SETTINGS : varying RF input, fixed alpha/coupling factor



kL_factor = [pi/4, pi/4*1.10;
             pi/3, pi/3*1.10;
             ];
alpha = [0*(dB/cm), 0*(dB/cm);
         1*(dB/cm), 1*(dB/cm);
         5*(dB/cm), 5*(dB/cm)];

%% EXTINTION RATE SIMULATION : varying RF input, fixed alpha/coupling factor 


RF = (0: 0.01: 2*RF_pi);
ER_rf1 = zeros(numel(alpha(:,1)), numel(kL_factor(:,1)), numel(RF));
ER_rf2 = zeros(numel(alpha(:,1)), numel(kL_factor(:,1)), numel(RF));

for j = (1: numel(alpha(:, 1)))
   
    loss_1 = (alpha(j, 1)/8.6860000037)*Length;
    loss_2 = (alpha(j, 2)/8.6860000037)*Length;

    for k = (1: numel(kL_factor(:, 1)))
        
        kL_factor_s = kL_factor(k,1);
        kL_factor_c = kL_factor(k,2);

        Tc_matrix_s = [cos(kL_factor_s)     -1i*sin(kL_factor_s); 
                       -1i*sin(kL_factor_s) cos(kL_factor_s)];
        
        Tc_matrix_c = [cos(kL_factor_c)     -1i*sin(kL_factor_c); 
                       -1i*sin(kL_factor_c) cos(kL_factor_c)];

        for i = (1:numel(RF))
            RF_max_input = RF(i);

            dn=-(ne^3)*r33*confinment_factor*RF_max_input/(2*gap);
            d_phi = dn*(Length).*(2*pi/wavelength);

            MC_matrix_1 = [exp((-1i*(phi0+d_phi))-loss_1), 0; 0, exp((-1i*(phi0))-loss_2)];
        
            r = Tc_matrix_c*MC_matrix_1*Tc_matrix_s*[E_i_laser, 0]';
            result_vector_high(1) = r(1);
            result_vector_low(2) = r(2);
          
            %RF LOW

            d_phi = 0;
            MC_matrix_2 = [exp((-1i*(phi0+d_phi))-loss_1), 0; 0, exp((-1i*phi0)-loss_2)];
        
            r = Tc_matrix_c*MC_matrix_2*Tc_matrix_s*[E_i_laser, 0]';
            result_vector_low(1) = r(1);
            result_vector_high(2) = r(2);


            ER_rf1(j, k, i) = 10*log10((abs(result_vector_high(1))^2)/((abs(result_vector_low(1))^2)));
            ER_rf2(j, k, i) = 10*log10((abs(result_vector_high(2))^2)/((abs(result_vector_low(2))^2)));
          
        end
    end
end

%% PLOTS

xBox = [RF(1),  RF(end), RF(end), RF(1), RF(1)];

figure(Name="ER / RF")
tiledlayout(2,1)
nexttile
yline(10, ":r", "label","ER=10dB", "HandleVisibility","off")
yline(40, ":r", "label","ER=40dB", "HandleVisibility","off")
xline(RF_pi, ":r", "label", "RF_p_i", "HandleVisibility","off")
hold on

for j = (1: numel(alpha(:, 1)))
    for k = (1: numel(kL_factor(:, 1)))
        data = squeeze(ER_rf1(j,k,:));
        plot(RF, data, DisplayName="alpha= " + alpha(j,1)*cm + " [dB/cm]," +alpha(j,2)*cm + "[dB/cm],  kL= " + kL_factor(k,1)/pi + "*pi" + "," +kL_factor(k,2)/pi +"*pi") 
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
xline(RF_pi, ":r", "label", "RF_p_i", "HandleVisibility","off")
hold on

for j = (1: numel(alpha(:, 1)))
    for k = (1: numel(kL_factor(:, 1)))
        data = squeeze(ER_rf2(j,k,:));
        plot(RF, data, DisplayName="alpha= " + alpha(j,1)*cm + " [dB/cm]," +alpha(j,2)*cm + " [dB/cm],  kL= " + kL_factor(k,1)/pi + "*pi" + "," +kL_factor(k,2)/pi + "*pi") 
    end
end

hold off
grid on
legend
xlabel("RF [V]")
ylabel("ER [dB]") 
title("ER/RF CROSS")