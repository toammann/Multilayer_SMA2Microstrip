gamma1 = 10^(-20/20);
gamma2 = -gamma1;

ml = (abs(gamma1) + abs(gamma2)) / (abs(gamma1)*abs(gamma2) + 1)

20*log10(ml)

gamma_max = 10^(-15.67/20);
gamma = (1 - sqrt(1-gamma_max^2))/gamma_max

20*log10(gamma)
