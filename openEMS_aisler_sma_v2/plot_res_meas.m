% BSD 2-Clause License
% Copyright (c) 2023, Tobias Ammann
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
% DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
% FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
% DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
% SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
% CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
% OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
% OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

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