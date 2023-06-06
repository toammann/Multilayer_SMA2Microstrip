function Sdeemb = deembRight(Sdut, Sfix, z0)
% DEEMBRIGHT - De-Embedds a 2x2 fixture S-parameter file from a 2x2 dut on 
%              the right side
% 
%   Reference:
%     Pozar,Microwave Engineering 4th.edition, Chapter 4: Microwave Network 
%     Analysis
%
%   Input:
%     Sdut    [double 2x2xf]  - 2x2xf scattering matrix to be de-embedded
%     Sfix    [double 2x2xf]  - 2x2xf scattering matrix which is to be
%                               substracted from Sdut on the right side
%     z0      [double]        - Reference impedance 
%
%   Output:
%     Sdeemb  [double 2x2xf]  - De-embedded 2x2 scattering matrix
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

  ABCDfix = convStoABCD(Sfix, z0);
  ABCDdut = convStoABCD(Sdut, z0);

  for i = 1:length(Sdut)
    ABCDdeemb(:,:,i) = ABCDdut(:,:,i)*inv(ABCDfix(:,:,i));
  end

  Sdeemb = convABCDtoS(ABCDdeemb, z0);

end