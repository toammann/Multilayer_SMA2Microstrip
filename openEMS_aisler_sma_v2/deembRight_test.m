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

