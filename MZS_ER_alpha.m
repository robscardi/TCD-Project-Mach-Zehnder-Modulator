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

    hfig1 = figure(Name="ER/loss - kL");
    
    %Set figure config 
    picturewidth = 20; % set this parameter and keep it forever
    hw_ratio = 0.65; % feel free to play with this ratio
    set(hfig1,'Units','centimeters','Position',[3 3 picturewidth hw_ratio*picturewidth])
    set(findall(hfig1,'-property','FontSize'),'FontSize',17) % adjust fontsize to your document


    tiledlayout(1,2)

    %% Plot ER BAR
    nexttile
    yline(10, ":r", "label","ER=10dB", "HandleVisibility","off", "LineWidth", 1)
    yline(40, ":r", "label","ER=40dB", "HandleVisibility","off", "LineWidth", 1)
    hold on
    for j = (1:numel(kL_factor_s))
        plot(alpha.*cm, ER_kL1(j,:), LineWidth=1.5, DisplayName="kL Factor = " + kL_factor_s(j)/pi + "*pi")
    end

    hold off
    legend("Box","on", "FontSize",12, "Tag","Coupling factor")
    grid on
    xlabel("loss [dB/cm]");
    ylabel("Extinction rate [dB]")
    title("Extinction rate BAR")
    fontname("CMU Sans Serif Demi Condensed")
   
    %% Plot ER CROSS
    nexttile

    yline(10, ":r", "label","ER=10dB", "HandleVisibility","off", "LineWidth", 1)
    yline(40, ":r", "label","ER=40dB", "HandleVisibility","off", "LineWidth", 1)
    hold on
    for j = (1:numel(kL_factor_s))
        plot(alpha.*cm, ER_kL2(j,:),LineWidth=1.5 , DisplayName="kL Factor = " + kL_factor_s(j)/pi + "*pi")
    end
    hold off
    legend("Box","on", "FontSize",12, "Tag","Coupling factor")
    grid on
    xlabel("loss [dB/cm]");
    ylabel("Extinction rate [dB]")
    title("Extinction rate CROSS")
    fontname("CMU Sans Serif Demi Condensed")

    pos = get(hfig1,'Position');
    set(hfig1,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
    print(hfig1,'ER_alpha','-dpdf','-vector','-fillpage')


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
    plot(alpha.*cm, abs(result_vector_high(1,:,1)).^2, DisplayName="kL Factor = " + kL_factor_s(1)/pi + "pi", LineWidth=1.5)
    hold on
    for j = (2:numel(kL_factor_s))
        plot(alpha.*cm, abs(result_vector_high(1,:,j)).^2, DisplayName="kL Factor = " + kL_factor_s(j)/pi + "*pi", LineWidth=1.5)
    end
    hold off
    grid on
    legend("Box","on", "Tag","Coupling factor", "FontName","CMU Sans Serif Demi Condensed")
    xlabel("Loss [dB/cm]")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output high BAR")
    fontname("CMU Sans Serif Demi Condensed")
    
    nexttile
    plot(alpha.*cm, abs(result_vector_high(2,:,1)).^2, DisplayName="kL Factor = " + kL_factor_s(1)/pi + "pi", LineWidth=1.5)
    hold on
    for j = (2:numel(kL_factor_s))
        plot(alpha.*cm, abs(result_vector_high(2,:,j)).^2, DisplayName="kL Factor = " + kL_factor_s(j)/pi + "*pi", LineWidth=1.5)
    end
    hold off
    grid on
    legend("Box","on", "Tag","Coupling factor", "FontName","CMU Sans Serif Demi Condensed")
    xlabel("Loss [dB/cm]")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output high CROSS")
    fontname("CMU Sans Serif Demi Condensed")

    nexttile
    plot(alpha.*cm, abs(result_vector_low(1,:,1)).^2, DisplayName="kL Factor = " + kL_factor_s(1)/pi + "pi", LineWidth=1.5)
    hold on
    for j = (2:numel(kL_factor_s))
        plot(alpha.*cm, abs(result_vector_low(1,:,j)).^2, DisplayName="kL Factor = " + kL_factor_s(j)/pi + "*pi", LineWidth=1.5)
    end
    hold off
    grid on
    legend("Box","on", "Tag","Coupling factor", "FontName","CMU Sans Serif Demi Condensed")
    xlabel("Loss [dB/cm]")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output low BAR")
    fontname("CMU Sans Serif Demi Condensed")

    nexttile
    plot(alpha.*cm, abs(result_vector_low(2,:,1)).^2, DisplayName="kL Factor = " + kL_factor_s(1)/pi + "pi", LineWidth=1.5)
    hold on
    for j = (2:numel(kL_factor_s))
        plot(alpha.*cm, abs(result_vector_low(2,:,j)).^2, DisplayName="kL Factor = " + kL_factor_s(j)/pi + "*pi", LineWidth=1.5)
    end
    hold off
    grid on
    legend("Box","on", "Tag","Coupling factor", "FontName","CMU Sans Serif Demi Condensed")
    xlabel("Loss [dB/cm]")
    ylabel("Intensity output [(V/m)^2]" )
    title("Output low CROSS")
    fontname("CMU Sans Serif Demi Condensed")


    pos = get(hfig2,'Position');
    set(hfig2,'PaperPositionMode','Auto','PaperUnits','centimeters','PaperSize',[pos(3), pos(4)])
    print(hfig2,'RF_alpha','-dpdf','-vector','-fillpage')


