function posSkipped = skipFixedMeshLine(pos, minDist)
% SKIPFIXEDMESHLINE - Removes meshlines adjacent distances less than minDist
%
%   Meshlines defined in "pos" are considered as fixed meshlines. These are 
%   manually defined lines in an openEMS simulation script. Horn_Antenna
%   
%   If this meshlines are located very close to each other this will result in a
%   small cell size (small timesteps) which will lead to long simulation times.
%   
%   If the user is about to tune the model the problematic meshlines will most 
%   likely occur at diffrent places in the model. This is an automatic approach
%   to resolve this issues.
%
%   As a user, define fixed meshlines at all places of interest. This function 
%   will remove meshlines below a threshold defined by "minDist". It is assumed 
%   that meshlines with a lower index (which appear first in the pos array) have 
%   a higher priority. Therefore the lower index meshlines will be kept and the 
%   higher index lines will be discarded.
%
%   Make sure to place the most importent meshlines at the begging of the "pos" 
%   array.
%   Input:
%     pos       [double[] ]  - Array containig mesh line positions sorted by
%                              priority. (first in array --> highest priority)
%
%     delim     [minDist]    - Minimum distance between adjacent meshlines
%
%   Output:
%    posSkipped [double[] ]  - Array with adjacent distances > minDist
%
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

  % delete exact dublicates
  posUnique = unique(pos, 'stable'); 
  posSkipped = [];
  
  for i = length(posUnique):-1:1 %run backwards trough vector
      
      diff = min(abs(posUnique(i) - posUnique(2:i-1)));
      
      if (diff < (minDist - 1e-12))
        % Not a valid Mesh line 
        fprintf('Info: Skipp mesh line in %s at %.4f. Distance to adjacent mesh line is smaller than minDist: %.4f < %.4f(minDist)\n', inputname(1), posUnique(i), diff, minDist);
      else
        posSkipped = [posUnique(i), posSkipped];
      end
   end
end