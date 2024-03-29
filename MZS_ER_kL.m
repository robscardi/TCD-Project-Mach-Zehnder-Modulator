
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

%% SETTINGS : fixed alpha, varying coupling coefficient 

% Set to 1, 0 or -1 to set the value of the attenuation constant of the
% second line. 
% 1  - the second line has the same attenuation constant as the first 
% 0  - the second line has an attenuation constant of 0
% -1 - the second line has a fixed attenuation constant
% Default = 0
same_loss_second_line = 0;

% Fixed attenuation constant for the second line in [dB/m]. 
% Irrelevant if 'same_loss_second_line' is other than -1.
% Default = 0 [dB/cm]
fixed_loss_second_line = 0.5*(dB/cm);

% Set to 1 or 0 or to set the value of the coupling factor of the 
% combiner. 
% 1  - the ratio between the CF of the splitter and combiner is constant
% 0  - the combiner has a coupling factor equals to kl_fixed_combiner
% Default = 0
coupling_splitter_combiner  = 0;

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
result_vector_high = zeros(2, numel(kL_factor), numel(alpha));
result_vector_low = zeros(2, numel(kL_factor), numel(alpha));



for j = 1:numel(alpha)

    loss = (alpha(j)/8.6860000037)*Length;
    switch(same_loss_second_line)
        case 0
            loss_2 = 0;
        case 1
            loss_2 = loss;
        case -1
            loss_2 = (fixed_loss_second_line/8.6860000037)*Length;
        otherwise
            assert(false, "INVALID 'same_loss_second_line' parameter");
    end
    for k = 1:numel(kL_factor)
        kL_factor_s = kL_factor(k);
        
        switch(coupling_splitter_combiner)
            case 0
                kL_factor_c = kL_fixed_combiner;
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

        dn=-(no^3)*r33*confinment_factor*RF_max_input/(2*gap);


        d_phi = dn*(Length).*(2*pi/wavelength);
        
        MC_matrix_1 = [1*exp((-1i*(phi0+d_phi))-loss), 0; 0, 1*exp(-1i*(phi0)-loss_2)];
        
        r1 = Tc_matrix_c*MC_matrix_1*Tc_matrix_s*[E_i_laser, 0]';
        
        result_vector_high(1,k,j) = r1(1);
        result_vector_low(2,k,j) = r1(2);
        
        
        %RF LOW
        RF_max_input = 0;
        
        dn=-(no^3)*r33*confinment_factor*RF_max_input/(2*gap);
        d_phi = dn*(Length)*(2*pi/wavelength);
        
        MC_matrix_2 = [1*exp((-1i*(phi0+d_phi))-loss), 0; 0, 1*exp(-1i*(phi0)-loss_2)];
        r2 = Tc_matrix_c*MC_matrix_2*Tc_matrix_s*[E_i_laser, 0]';
    
        result_vector_low(1,k,j) = r2(1);
        result_vector_high(2,k,j) = r2(2);

        ER_a1(j, k) = 10*log10((abs(result_vector_high(1,k,j))^2)/((abs(result_vector_low(1,k,j))^2)));
        ER_a2(j, k) = 10*log10((abs(result_vector_high(2,k,j))^2)/((abs(result_vector_low(2,k,j))^2)));
    end
end


%% ER/kL Factor - Loss PLOTS
hfig1 = figure(Name="ER/kL_factor - loss");

    %Set figure config 
    picturewidth = 20; % set this parameter and keep it forever
    hw_ratio = 0.65; % feel free to play with this ratio
    set(hfig1,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
    set(findall(hfig1,'-property','FontSize'),'FontSize',17) % adjust fontsize to your document
    fontname("CMU Sans Serif Demi Condensed")


tiledlayout(1,2)
    
    %plot ER1
    nexttile
    yline(10, ":r", "label","ER=10dB", "HandleVisibility","off")
    yline(40, ":r", "label","ER=40dB", "HandleVisibility","off")
    xline(1/4, ":r", "label","pi/4", "HandleVisibility","off", "LineWidth",1.2)
    hold on
    for j=1:numel(alpha)
        plot(kL_factor./pi, ER_a1(j,:), ...
            DisplayName="alpha = " + alpha(j)*cm + " [dB/cm]", ...
            LineWidth=1.5)
    end
    hold off
    leg = legend("Box","on");
    set(leg, 'FontSize', 10);
    grid on
    xlabel("Splitter Coupling Factor / Pi")
    ylabel("Extinction rate [db]")
    title("Extinction rate BAR")
    fontname("CMU Sans Serif Demi Condensed")
   

    %plot ER2
    nexttile
    yline(10, ":r", "label","ER=10dB", "HandleVisibility","off")
    yline(40, ":r", "label","ER=40dB", "HandleVisibility","off")    
    xline(1/4, ":r", "label","pi/4", "HandleVisibility","off","LineWidth",1.2)
    hold on
    for j=1:numel(alpha)
        plot(kL_factor./pi, ER_a2(j,:), ...
            DisplayName="alpha = " + alpha(j)*cm + " [dB/cm]", ...
            LineWidth=1.5)
    end
    hold off
    grid on
    leg2 = legend("Box","on");
    set(leg2, 'FontSize', 10);
    xlabel("Splitter Coupling Factor / Pi")
    ylabel("Extinction rate [db]")
    title("Extinction rate CROSS")
    fontname("CMU Sans Serif Demi Condensed")

%% PLOT output - loss - kL 
hfig2 = figure(Name="output / loss - kL ");

    %Set figure config 
    picturewidth = 20; % set this parameter and keep it forever
    hw_ratio = 0.65; % feel free to play with this ratio
    set(hfig2,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
    set(findall(hfig2,'-property','FontSize'),'FontSize',17) % adjust fontsize to your document
    fontname("CMU Sans Serif Demi Condensed")

tiledlayout(2,2)
    
nexttile
    plot(kL_factor./pi, abs(result_vector_high(1,:,1)).^2, ...
        DisplayName="alpha = " + alpha(1)*cm + " [dB/cm]", ...
        LineWidth=1.5)
    hold on
    xline(1/4, ":r", "label","pi/4", "HandleVisibility","off")
    for j = (2:numel(alpha))
        plot(kL_factor./pi, abs(result_vector_high(1,:,j)).^2, ...
            DisplayName="alpha = " + alpha(j)*cm + " [dB/cm]", ...
            LineWidth=1.5)
    end
    hold off
    grid on
    ylim([0,1])
    legend
    xlabel("Splitter Coupling Factor / Pi")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output high BAR")
    fontname("CMU Sans Serif Demi Condensed")
    
nexttile
    plot(kL_factor./pi, abs(result_vector_high(2,:,1)).^2, ...
        DisplayName="alpha = " + alpha(1)*cm + " [dB/cm]", ...
        LineWidth=1.5)
    hold on
    xline(1/4, ":r", "label","pi/4", "HandleVisibility","off")
    for j = (2:numel(alpha))
        plot(kL_factor./pi, abs(result_vector_high(2,:,j)).^2, ...
            DisplayName="alpha = " + alpha(j)*cm + " [dB/cm]", ...
            LineWidth=1.5)
    end
    hold off
    grid on
    ylim([0,1])
    legend
    xlabel("Splitter Coupling Factor / Pi")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output high CROSS")
    fontname("CMU Sans Serif Demi Condensed")

nexttile
    plot(kL_factor./pi, abs(result_vector_low(1,:,1)).^2, ...
        DisplayName="alpha = " + alpha(1)*cm + " [dB/cm]", ...
        LineWidth=1.5)
    hold on
    xline(1/4, ":r", "label","pi/4", "HandleVisibility","off", ...
        "LineWidth", 1.2)
    for j = (2:numel(alpha))
        plot(kL_factor./pi, abs(result_vector_low(1,:,j)).^2, ...
            DisplayName="alpha = " + alpha(j)*cm + " [dB/cm]", ...
            LineWidth=1.5)
    end
    hold off
    grid on
    ylim([0,1])
    legend
    xlabel("Splitter Coupling Factor / Pi")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output low BAR")
    fontname("CMU Sans Serif Demi Condensed")

nexttile
    plot(kL_factor./pi, abs(result_vector_low(2,:,1)).^2, ...
        DisplayName="alpha = " + alpha(1)*cm + " [dB/cm]", ...
        LineWidth=1.5)
    hold on
    xline(1/4, ":r", "label","pi/4", "HandleVisibility","off", ...
        "LineWidth", 1.2)
    for j = (2:numel(alpha))
        plot(kL_factor./pi, abs(result_vector_low(2,:,j)).^2, ...
            DisplayName="alpha = " + alpha(j)*cm + " [dB/cm]", ...
            LineWidth=1.5)
    end
    hold off
    grid on
    ylim([0,1])
    legend
    xlabel("Splitter Coupling Factor / Pi")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output low CROSS")
    fontname("CMU Sans Serif Demi Condensed")


