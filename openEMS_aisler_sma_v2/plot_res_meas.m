close all;
addpath('../CTB');

% Plot Size and scaling
size_x = 1280;
size_y = 720;
ref_line_y = -20;
x_lim = [0, 25];
y_lim = [-35, 0];
cmap = lines (21);

% Parse Touchstone
[type,freq,sp,ref,comment]=read_touchstone('SMA_Rosenberger_32K242-40ML5v2_Aisler6LayerHD_meas.s2p');

s11dB = 20*log10(abs(squeeze(sp(1,1,:))));
s21dB = 20*log10(abs(squeeze(sp(2,1,:))));
s12dB = 20*log10(abs(squeeze(sp(1,2,:))));
s22dB = 20*log10(abs(squeeze(sp(2,2,:))));

% Create Figure
fig = figure('Position', [0,0, size_x, size_y]);

% Plot Lines
hold on;
plot(freq/1e9, s11dB, 'Linewidth', 1.5);
plot(freq/1e9, s21dB, 'Linewidth', 1.5);
plot(freq/1e9, s12dB, 'Linewidth', 1.5);
plot(freq/1e9, s22dB, 'Linewidth', 1.5);
plot(xlim, repmat(ref_line_y, 1, 2), 'bk--', 'Linewidth', 0.5);
text(28, ref_line_y + 0.8, [num2str(ref_line_y), ' dB'], 'FontSize', 10)

% Marker S11
[~, mkr_idx] = min(abs(freq - 16.245e9))
mkr_val = s11dB(mkr_idx);
text(freq(mkr_idx)/1e9, mkr_val + 1, [num2str(mkr_val, '%.2f'), ' dB'], 'FontSize', 9, 'horizontalalignment', 'center');
plot(freq(mkr_idx)/1e9, mkr_val, 'or', 'markersize', 8);

% Marker S21
[~, mkr_idx] = min(abs(freq - 20e9))
mkr_val = s21dB(mkr_idx);
text(freq(mkr_idx)/1e9, mkr_val + 1, [num2str(mkr_val, '%.2f'), ' dB'], 'FontSize', 9, 'horizontalalignment', 'center');
plot(freq(mkr_idx)/1e9, mkr_val, 'or', 'markersize', 8);
hold off;

% Apply Scaling
xlim(x_lim);
ylim(y_lim);

% Plot Texts
legend('S_{11}', 'S_{21}', 'S_{12}', 'S_{22}', 'FontSize', 11);
title({'Rosenberger 32K242-40ML5 on Aisler 6LayerHD',...
       'Measurement: Test Board (Back to Back)'});
xlabel('Frequency / GHz');
ylabel('Magnitude / dB');
grid minor

% Export to JPG and PDF
print('plot_res_meas_testboard.pdf', '-landscape', '-bestfit');
print('plot_res_meas_testboard.png', '-dpng', sprintf('-S%i,%i', size_x, size_y));