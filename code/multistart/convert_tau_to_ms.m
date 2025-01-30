function T = convert_tau_to_ms(x)

T  = [2 2 16 28]./1000; 

T = T.*exp(full(x)).*1000;



