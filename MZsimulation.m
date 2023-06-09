
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

%% SETTINGS : fixed coupling coefficient, varying alpha

% Set to 1, 0 or -1 to set the value of the attenuation constant of the
% second line. 
% 1  - the second line has the same attenuation constant as the first 
% 0  - the second line has an attenuation constant of 0
% -1 - the second line has a fixed attenuation constant
% Default = 0
same_loss_second_line  = 0;


% Fixed attenuation constant for the second line in [dB/cm]. 
% Irrelevant if 'a_same_loss_second_line' is other than -1.
% Default = 0 [dB/cm]
fixed_loss_second_line = 0*(dB/cm);

% Coupling coefficient splitter
kL_factor_s = [pi/4, (pi/4)*1.10, (pi/4)*0.90, (pi/4)*1.5];

% Coupling coefficient combiner
kL_factor_c = [pi/4, (pi/4)*1.10, (pi/4)*0.90, (pi/4)*1.5];

assert(numel(kL_factor_c) >= numel(kL_factor_s), "kL_factor c has less element than kL_factor_s ")

%% EXTINTION RATE SIMULATION : fixed coupling coefficient, varying alpha 
E_i_laser = 1*V;

alpha = (0: 0.01*(dB/cm): 2*(dB/cm)); %[dB/cm]
ER_kL1 = zeros(numel(kL_factor_s), numel(alpha));
ER_kL2 = zeros(numel(kL_factor_s), numel(alpha));


result_vector_low = zeros(2, numel(alpha),numel(kL_factor_s));
result_vector_high = zeros(2, numel(alpha),numel(kL_factor_s));


for j = 1:numel(kL_factor_s)


    Tc_matrix_s = [cos(kL_factor_s(j))      -1i*sin(kL_factor_s(j)); 
                   -1i*sin(kL_factor_s(j))  cos(kL_factor_s(j))];
    Tc_matrix_c = [cos(kL_factor_c(j))      -1i*sin(kL_factor_c(j)); 
                   -1i*sin(kL_factor_c(j))  cos(kL_factor_c(j))];
    for k = 1:numel(alpha)
        
        loss = (alpha(k)/8.6860000037)*Length;
        
        switch(same_loss_second_line)
            case 0
                loss_2 = 0;
            case 1
                loss_2 = loss;
            case -1
                loss_2 = fixed_loss_second_line;
            otherwise
                assert(false, "INVALID 'same_loss_second_line' parameter");
        end

        % RF HIGH
        RF_max_input = RF_pi;

        dn=-(ne^3)*r33*confinment_factor*RF_max_input/(2*gap);


        d_phi = dn*(Length).*(2*pi/wavelength);
        
        MC_matrix_1 = [1*exp((-1i*(phi0+d_phi))-loss), 0; 0, 1*exp(-1i*(phi0)-loss_2)];
        
        r1 = Tc_matrix_c*MC_matrix_1*Tc_matrix_s*[E_i_laser, 0]';
        
        result_vector_high(1,k,j) = r1(1);
        result_vector_low(2,k,j) = r1(2);
        
        
        %RF LOW
        RF_max_input = 0;
        
        dn=-(ne^3)*r33*confinment_factor*RF_max_input/(2*gap);
        d_phi = dn*(Length)*(2*pi/wavelength);
        
        MC_matrix_2 = [1*exp((-1i*(phi0+d_phi))-loss), 0; 0, 1*exp(-1i*(phi0)-loss_2)];
        r2 = Tc_matrix_c*MC_matrix_2*Tc_matrix_s*[E_i_laser, 0]';
    
        result_vector_low(1,k,j) = r2(1);
        result_vector_high(2,k,j) = r2(2);

        ER_kL1(j, k) = 10*log10((abs(result_vector_high(1,k,j))^2)/((abs(result_vector_low(1,k,j))^2)));
        ER_kL2(j, k) = 10*log10((abs(result_vector_high(2,k,j))^2)/((abs(result_vector_low(2,k,j))^2)));
    end
end

%% kL - Loss PLOTS    
   
    yBox = [10, 10, 40, 40, 10];
    xBox = [0, alpha(end)*cm, alpha(end)*cm, 0, 0];

    figure(Name="ER/loss - kL");
    tiledlayout(1,2)

    
    %plot ER1
    nexttile
    yline(10, ":r", "label","ER=10dB", "HandleVisibility","off")
    yline(40, ":r", "label","ER=40dB", "HandleVisibility","off")
    hold on
    p = patch(xBox, yBox, "black", "FaceColor", "green", "FaceAlpha", 0.1);
    p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    for j = (1:numel(kL_factor_s))
        plot(alpha.*cm, ER_kL1(j,:), DisplayName="kL Factor = " + kL_factor_s(j)/pi + "*pi")
    end

    hold off
    legend
    grid on
    xlabel("loss [db/cm]");
    ylabel("Extinction rate [db] port 1")
    title("Extinction rate port 1")
   

    %plot ER2
    nexttile
    yline(10, ":r", "label","ER=10dB", "HandleVisibility","off")
    yline(40, ":r", "label","ER=40dB", "HandleVisibility","off")
    hold on
    p = patch(xBox, yBox, "black", "FaceColor", "green", "FaceAlpha", 0.1);
    p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    for j = (1:numel(kL_factor_s))
        plot(alpha.*cm, ER_kL2(j,:), DisplayName="kL Factor = " + kL_factor_s(j)/pi + "*pi")
    end
    hold off
    legend
    grid on
    xlabel("loss [dB/cm]");
    ylabel("Extinction rate [dB] port 2")
    title("Extinction rate port 2")

%% PLOT output - loss - kL 
    figure(Name="output / loss - kL ");
    tiledlayout(2,2)
    
    nexttile
    plot(alpha, abs(result_vector_high(1,:,1)).^2, DisplayName="kL Factor = " + kL_factor_s(1)/pi + "pi")
    hold on
    for j = (2:numel(kL_factor_s))
        plot(alpha, abs(result_vector_high(1,:,j)).^2, DisplayName="kL Factor = " + kL_factor_s(j)/pi + "*pi")
    end
    hold off
    grid on
    legend
    xlabel("Loss [dB/cm]")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output high port 1")
    
    nexttile
    plot(alpha, abs(result_vector_high(2,:,1)).^2, DisplayName="kL Factor = " + kL_factor_s(1)/pi + "pi")
    hold on
    for j = (2:numel(kL_factor_s))
        plot(alpha, abs(result_vector_high(2,:,j)).^2, DisplayName="kL Factor = " + kL_factor_s(j)/pi + "*pi")
    end
    hold off
    grid on
    legend
    xlabel("Loss [dB/cm]")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output high port 2")

    nexttile
    plot(alpha, abs(result_vector_low(1,:,1)).^2, DisplayName="kL Factor = " + kL_factor_s(1)/pi + "pi")
    hold on
    for j = (2:numel(kL_factor_s))
        plot(alpha, abs(result_vector_low(1,:,j)).^2, DisplayName="kL Factor = " + kL_factor_s(j)/pi + "*pi")
    end
    hold off
    grid on
    legend
    xlabel("Loss [dB/cm]")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output low port 1")

    nexttile
    plot(alpha, abs(result_vector_low(2,:,1)).^2, DisplayName="kL Factor = " + kL_factor_s(1)/pi + "pi")
    hold on
    for j = (2:numel(kL_factor_s))
        plot(alpha, abs(result_vector_low(2,:,j)).^2, DisplayName="kL Factor = " + kL_factor_s(j)/pi + "*pi")
    end
    hold off
    grid on
    legend
    xlabel("Loss [dB/cm]")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output low port 2")


%% SETTINGS : fixed alpha, varying coupling coefficient 

% Set to 1, 0 or -1 to set the value of the attenuation constant of the
% second line. 
% 1  - the second line has the same attenuation constant as the first 
% 0  - the second line has an attenuation constant of 0
% -1 - the second line has a fixed attenuation constant
% Default = 0
same_loss_second_line = 0*(dB/cm);

% Fixed attenuation constant for the second line in [dB/m]. 
% Irrelevant if 'same_loss_second_line' is other than -1.
% Default = 0 [dB/cm]
fixed_loss_second_line = 0*(dB/cm);

% Set to 1, 0 or -1 to set the value of the attenuation constant of the
% second line. 
% 1  - the ratio between the CF of the splitter and combiner is constant
% 0  - the combiner has a coupling factor of pi/4
% Default = 0
coupling_splitter_combiner  = 1;

% Fixed coupling factor for the combiner. 
% Irrelevant if 'kL_equal_splitter_combiner' is other than -1.
% Default = pi/4 
kL_fixed_combiner = pi/4;

% Ratio between the coupling factor of the splitter and the combiner.
% E.g. : kL_combiner = kL_splitter/splitter_combiner_ratio
splitter_combiner_ratio = 1;


%% EXTINTION RATE SIMULATION : fixed alpha, varying coupling coefficient 

alpha = [0; 0.1 ; 0.5; 1; 1.5; 2].*100;
kL_factor = (0: 0.001: pi/2);

ER_a1 = zeros(numel(alpha), numel(kL_factor));
ER_a2 = zeros(numel(alpha), numel(kL_factor));


for j = 1:numel(alpha)

    loss = (alpha(j)/8.6860000037)*Length;
    switch(same_loss_second_line)
        case 0
            loss_2 = 0;
        case 1
            loss_2 = loss;
        case -1
            loss_2 = fixed_loss_second_line;
        otherwise
            assert(false, "INVALID 'same_loss_second_line' parameter");
    end
    for k = 1:numel(kL_factor)
        kL_factor_s = kL_factor(k);
        
        switch(coupling_splitter_combiner)
            case 0
                kL_factor_c = pi/4;
            case 1
                kL_factor_c = kL_factor_s/splitter_combiner_ratio;
            otherwise
                assert(false, "INVALID 'coupling_splitter_combiner' parameter");
        end

        Tc_matrix_s = [cos(kL_factor_s)     -1i*sin(kL_factor_s); 
                       -1i*sin(kL_factor_s) cos(kL_factor_s)];
        
        Tc_matrix_c = [(cos(kL_factor_c))    -1i*sin(kL_factor_c); 
                       -1i*sin(kL_factor_c)  cos(kL_factor_c)];

        % RF HIGH
        RF_max_input = RF_pi;

        dn=-(ne^3)*r33*confinment_factor*RF_max_input/(2*gap);
        d_phi = dn*(Length).*(2*pi/wavelength);

        MC_matrix_1 = [exp((-1i*(phi0+d_phi))-loss), 0; 0, exp((-1i*(phi0))-loss_2)];
        
        r = Tc_matrix_c*MC_matrix_1*Tc_matrix_s*[E_i_laser, 0]';
        result_vector_high(1) = r(1);
        result_vector_low(2) = r(2);

        %RF LOW
        RF_max_input = 0;
        dn=-(ne^3)*r33*confinment_factor*RF_max_input/(2*gap);
        d_phi = dn*(Length)*(2*pi/wavelength);

        MC_matrix_2 = [exp((-1i*(phi0+d_phi))-loss), 0; 0, exp((-1i*phi0)-loss_2)];
        
        r = Tc_matrix_c*MC_matrix_2*Tc_matrix_s*[E_i_laser, 0]';
        result_vector_low(1) = r(1);
        result_vector_high(2) = r(2);


        ER_a1(j, k) = 10*log10((abs(result_vector_high(1))^2)/((abs(result_vector_low(1))^2)));
        ER_a2(j, k) = 10*log10((abs(result_vector_high(2))^2)/((abs(result_vector_low(2))^2)));
    end
end


%% ER/kL Factor - Loss PLOTS
figure(Name="ER/kL_factor - loss");
tiledlayout(1,2)
    

    xBox = [kL_factor(1),  kL_factor(end), kL_factor(end), kL_factor(1), kL_factor(1)];
    %plot ER1
    nexttile
    yline(10, ":r", "label","ER=10dB", "HandleVisibility","off")
    yline(40, ":r", "label","ER=40dB", "HandleVisibility","off")
    xline(pi/4, ":r", "label","pi/4", "HandleVisibility","off")
    hold on
    p = patch(xBox, yBox, "black", "FaceColor", "green", "FaceAlpha", 0.1);
    p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    for j=1:numel(alpha)
        plot(kL_factor, ER_a1(j,:), DisplayName="alpha = " + alpha(j)*cm + " [dB/cm]")
    end
    hold off
    legend
    grid on
    xlabel("Coupling factor splitter")
    ylabel("Extinction rate [db] port 1")
    title("Extinction rate port 1")
   

    %plot ER2
    nexttile
    yline(10, ":r", "label","ER=10dB", "HandleVisibility","off")
    yline(40, ":r", "label","ER=40dB", "HandleVisibility","off")    
    xline(pi/4, ":r", "label","pi/4", "HandleVisibility","off")
    hold on
    p = patch(xBox, yBox, "black", "FaceColor", "green", "FaceAlpha", 0.1);
    p.Annotation.LegendInformation.IconDisplayStyle = 'off';
    for j=1:numel(alpha)
        plot(kL_factor, ER_a2(j,:), DisplayName="alpha = " + alpha(j)*cm + " [dB/cm]")
    end
    hold off
    grid on
    legend
    xlabel("Coupling factor splitter")
    ylabel("Extinction rate [db] port 2")
    title("Extinction rate port 2")


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
p = patch(xBox, yBox, "black", "FaceColor", "green", "FaceAlpha", 0.1);
p.Annotation.LegendInformation.IconDisplayStyle = 'off';
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
title("ER/RF port 1")

nexttile
yline(10, ":r", "label","ER=10dB", "HandleVisibility","off")
yline(40, ":r", "label","ER=40dB", "HandleVisibility","off")
xline(RF_pi, ":r", "label", "RF_p_i", "HandleVisibility","off")
hold on
p = patch(xBox, yBox, "black", "FaceColor", "green", "FaceAlpha", 0.1);
p.Annotation.LegendInformation.IconDisplayStyle = 'off';
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
title("ER/RF port 2")








