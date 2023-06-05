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
[~,freq_sim,sp_sim,~,~] = read_touchstone('rosenberger_32K242-40ML5_on_aisler_6layer_v2_final_2023-05-11_153429.s2p');
[~,freq_meas,sp_meas,~,~] = read_touchstone('SMA_Rosenberger_32K242-40ML5v2_Aisler6LayerHD_meas_right_shift_14450um.s2p');

s21dB_sim = 20*log10(abs(squeeze(sp_sim(2,1,:))));
s11dB_sim = 20*log10(abs(squeeze(sp_sim(1,1,:))));

s21dB_meas = 20*log10(abs(squeeze(sp_meas(2,1,:))));
s11dB_meas = 20*log10(abs(squeeze(sp_meas(1,1,:))));


% Create Figure
fig = figure('Position', [0,0, size_x, size_y]);

% Plot Lines
hold on;
plot(freq_sim/1e9, s21dB_sim, 'Linewidth', 1.5, 'Color', cmap(5,:), 'lineStyle', '--');
plot(freq_sim/1e9, s11dB_sim, 'Linewidth', 1.5, 'Color', cmap(2,:), 'lineStyle', '--');
plot(freq_meas/1e9, s21dB_meas, 'Linewidth', 1.5, 'Color', cmap(3,:));
plot(freq_meas/1e9, s11dB_meas, 'Linewidth', 1.5, 'Color', cmap(1,:));
plot(xlim, repmat(ref_line_y, 1, 2), 'bk--', 'Linewidth', 0.5);
text(x_lim(2) - 2, ref_line_y + 0.8, [num2str(ref_line_y), ' dB'], 'FontSize', 10);

% Marker S21_meas
[~, mkr_idx] = min(abs(freq_meas - 20e9))
mkr_val = s21dB_meas(mkr_idx);
text(freq_meas(mkr_idx)/1e9, mkr_val - 1, [num2str(mkr_val, '%.2f'), ' dB'], 'FontSize', 9, 'horizontalalignment', 'center');
plot(freq_meas(mkr_idx)/1e9, mkr_val, 'or', 'markersize', 8);
hold off;

% Apply Scaling
xlim(x_lim);
ylim(y_lim);

% Plot Texts
legend('S_{21} - sim.', 'S_{11} - sim.', 'S_{21} - meas. deemb.', 'S_{11} - meas. deemb.', 'FontSize', 11, 'Location', 'SouthEast');
title({'Rosenberger 32K242-40ML5 on Aisler 6LayerHD',...
       'OpenEMS Simulation vs Deembedded VNA Measurement'});
xlabel('Frequency / GHz');
ylabel('Magnitude / dB');
grid minor

% Export to JPG and PDF
print('plot_res_sim_vs_meas.pdf', '-landscape', '-bestfit');
print('plot_res_sim_vs_meas.png', '-dpng', sprintf('-S%i,%i', size_x, size_y));