function ABCD = convStoABCD(S, z0)
% CONVSTOABCD - Converts a 2x2 scattering matrix to a abcd matrix
% 
%   Reference:
%     Pozar,Microwave Engineering 4th.edition, Chapter 4: Microwave Network 
%     Analysis
%
%   Input:
%     S       [double 2x2xf]  - 2x2 scattering matrix with frequency in the 
%                               third dim.
%     z0      [double]        - Reference impedance 
%
%   Output:
%     ABCD    [array 2x2xf]  - 2x2 ABCD matrix with frequency in the third dim.
%
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

  s11 = squeeze(S(1,1,:));
  s12 = squeeze(S(1,2,:));
  s21 = squeeze(S(2,1,:));
  s22 = squeeze(S(2,2,:));
  
  ABCD = zeros(2,2,length(s11));
  ABCD(1,1,:) =      ((1 + s11).*(1 - s22) + s12.*s21)./(2*s21);
  ABCD(1,2,:) =   z0*((1 + s11).*(1 + s22) - s12.*s21)./(2*s21);
  ABCD(2,1,:) = 1/z0*((1 - s11).*(1 - s22) - s12.*s21)./(2*s21);
  ABCD(2,2,:) =      ((1 - s11).*(1 + s22) + s12.*s21)./(2*s21);
endfunction