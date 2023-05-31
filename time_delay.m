function t = time_delay(phi, delay_factor) 
    p = wrapTo2Pi(phi);
    t = p*delay_factor;
end