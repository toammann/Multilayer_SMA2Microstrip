function S = convABCDtoS(ABCD, z0)
% CONVABCDTOS - Converts a 2x2 abcd matrix to a scattering matrix 
% 
%   Reference:
%     Pozar,Microwave Engineering 4th.edition, Chapter 4: Microwave Network 
%     Analysis
%
%   Input:
%     ABCD    [double 2x2xf]  - 2x2 ABCD matrix with frequency in the third dim.
%     z0      [double]        - Reference impedance 
%
%   Output:
%     S       [double 2x2xf]  - 2x2 scattering matrix with frequency in the 
%                               third dim.
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

  
  a = squeeze(ABCD(1,1,:));
  b = squeeze(ABCD(1,2,:));
  c = squeeze(ABCD(2,1,:));
  d = squeeze(ABCD(2,2,:));
  
  S = zeros(2,2,length(a));
  S(1,1,:) =  (a + b/z0 - c*z0 - d)./(a + b/z0 + c*z0 + d);
  S(1,2,:) = 2*(a.*d - b.*c)       ./(a + b/z0 + c*z0 + d);
  S(2,1,:) = 2                     ./(a + b/z0 + c*z0 + d);
  S(2,2,:) = (-a + b/z0 - c*z0 + d)./(a + b/z0 + c*z0 + d);

  endfunction