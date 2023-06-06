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

addpath('../CTB');

close all;

% Plot Size and scaling
size_x = 1280;
size_y = 720;
ref_line_y = -23;

% Parse Touchstone
[type,freq,sp,ref,comment]=read_touchstone('rosenberger_32K242-40ML5_on_aisler_6layer_v2_final_2023-05-11_153429.s2p');
s21dB = 20*log10(abs(squeeze(sp(2,1,:))));
s11dB = 20*log10(abs(squeeze(sp(1,1,:))));

% Create Figure 1 - magnitude dB plots
fig1 = figure('Position', [0,0, size_x, size_y]);

% Plot Lines
hold on;
plot(freq/1e9, s21dB, 'Linewidth', 1.5);
plot(freq/1e9, s11dB, 'Linewidth', 1.5);
plot(xlim, repmat(ref_line_y, 1, 2), 'bk--', 'Linewidth', 0.5);
text(28, ref_line_y + 0.8, [num2str(ref_line_y), ' dB'], 'FontSize', 10)
hold off;

% Plot Texts
legend('S_{21}', 'S_{11}', 'FontSize', 11);
title({'Rosenberger 32K242-40ML5 on Aisler 6LayerHD',...
       'OpenEMS Final Scattering Parameters'});
xlabel('Frequency / GHz');
ylabel('Magnitude / dB');
grid minor

##% Create Figure 2 - Smithchart
##fig2 = figure('Position', [0,0, size_x, size_x]);
##
##[~, fmax_idx] = min(abs(freq - 22e9))
##h_plot_s11 = plotSmith(squeeze(sp(1,1,1:fmax_idx)), 'S11', freq(1:fmax_idx), []);
##h_plot_s22 = plotSmith(squeeze(sp(2,2,1:fmax_idx)), 'S22', freq(1:fmax_idx), [], 'nogrid');
##
##set(h_plot_s11, 'linewidth', 1.5);
##set(h_plot_s22, 'linewidth', 1.5);
##
##legend('FontSize', 11);
##title({'Rosenberger 32K242-40ML5 on Aisler 6LayerHD',...
##       'OpenEMS Final Scattering Parameters'});

% Export to JPG and PDF
print(fig1, 'plot_res_sim.pdf', '-landscape', '-bestfit');
print(fig1, 'plot_res_sim.png', '-dpng', sprintf('-S%i,%i', size_x, size_y));

##print(fig2, 'plot_res_sim_smith.pdf', '-portrait', '-bestfit');
##print(fig2, 'plot_res_sim_smith.png', '-dpng', sprintf('-S%i,%i', size_x, size_x));