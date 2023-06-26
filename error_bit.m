function [res] = error_bit(out, bit_sample, unalt_ts, Vth)

    logs = get(out, 'logsout');
    timeseries = get(logs, 'OUT2').Values;
    d = get(timeseries, 'Data');
    data = d.^2;
    total_sample = numel(data);
    bit_num = floor(total_sample/bit_sample);
    n = 0;
    
    unalt_bits = squeeze(get(unalt_ts, 'Data'));


    c = 1;
    
    %number of invalid samples
    begin_valid = 75;

    for j = (1:bit_num)
        
        bit = data(c+begin_valid:c+bit_sample-1);
        middle = ceil(c+(bit_sample/2));
        unalt_bit = unalt_bits(middle);
        r = mean(bit, "all");
        out_low = 0;
        out_high = 0;
        
        if( r >= 0 && r < 0.25)
            out_low = 1;
        else
            out_high = 1;    
        end
        
        if(unalt_bit < Vth)
            if (out_low)
                n = n+1;
            end
        else
            if(out_high)
                n = n+1;
            end
        end  
        c = c +  bit_sample;
    end
    res = n;
end