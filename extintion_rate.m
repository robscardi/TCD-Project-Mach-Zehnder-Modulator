function er = extintion_rate(out, bit_samples)
    
    logs = get(out, 'logsout');
    timeseries = get(logs, 'OUT2').Values;
    d = get(timeseries, 'Data');
    data = d.^2;
    total_sample = numel(data);
    bit_num = floor(total_sample/bit_samples);
    low = zeros(1, bit_num);
    n_low = 0;
    high = zeros(1, bit_num);
    n_high = 0;
    c = 1;
    %number of invalid samples
    begin_valid = 75;

    for j = (1:bit_num)
        
        bit = data(c+begin_valid:c+bit_samples-1);
        r = mean(bit, "all");
        if( r >= 0 && r < 0.25)
            n_low = n_low +1;
            low(n_low) = r;
        else
            n_high = n_high +1;
            high(n_high) = r;    
        end
        c = c +  bit_samples;
    end
    l = mean(low(1:n_low), "all");
    h = mean(high(1:n_high), "all");
    er = 10*log10(h/l);
end