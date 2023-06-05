clear;
clc;

[freq_fix, Sfix, npoints] = fromtouchn('p2_gcwg.s2p');
[freq_dut, Sdut, npoints] = fromtouchn('init_2023-04-28_164756.s2p');

z0 = 50;

Sdeemb = deembRight(Sdut, Sfix, z0, true);

figure;
hold on;
plot(freq_dut/1e9, 20*log10(abs(squeeze(Sdut(2,2,:)))));
plot(freq_dut/1e9, 20*log10(abs(squeeze(Sdeemb(2,2,:)))));

plot(freq_dut/1e9, 20*log10(abs(squeeze(Sdut(2,1,:)))));
plot(freq_dut/1e9, 20*log10(abs(squeeze(Sdeemb(2,1,:)))));
hold off;

xlabel('Frequency / GHz');
ylabel('Magnitude / dB');
legend('S_{22, DUT}', 'S_{22, deemb}', 'S_{21, DUT}','S_{21, deemb}');

grid minor
set(gca, 'fontsize', 12);

