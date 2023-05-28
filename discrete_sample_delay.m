function n_delay = discrete_sample_delay(phi, delay_factor, sample_time)
    p = wrapTo2Pi(phi);
    n = ((p*delay_factor)/sample_time);
    n_delay = uint32(floor(n));
end

