function [param, data] = parse_freecad_spr_param(filen, delim)
% PARSE_FREECAD_SPR_PARAM - Parses a exports of a FreeCAD spreadsheet 
%
%   The spreadsheet is assumed to contain a parameter list in the following 
%   format:
%
%   | col. 1: parameter name | col. 2: numerical value | col. 3 description |
%
%   Input:
%     filen   [string]  - Filename of the FreeCAD export
%     delim   [char]    - Delimiter used in the FreeCAD export file
%
%   Output:
%    param   [struct]  - Name value pair of the parameters as struct
%     data    [cell]   - Cell array containig all the data of the spreadsheets 
%                        first three columuns
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

  fid = fopen(filen, 'r');

  data = {};
  i = 1;
  n = 0;
  try
    while ~feof(fid)
      n = n + 1; % Increment the line counter
      
      % Read one line
      line = fgetl(fid);
      
      % Skip empty lines
      if isempty(line); continue; endif 
      
      % Split the file at the delimiter
      row = strsplit (line, delim);

      if length(row) < 2
        % Only one columns of the file contains values --> error
        error('No value found in line %i, column 2', n);
      elseif length(row) < 3
        % The third column in considered optinal --> use 'NaN' value
        row(3) = NaN;
      endif
      
      % Collect data
      data(i, 1) = row(1);
      data(i, 2) = str2double(row(2));
      data(i, 3) = row(3);
      
      i = i + 1; % Increment the value counter
      
  endwhile 

  catch ME
    fclose(fid);
    error(ME);
  end_try_catch

  %Close the file
  fclose(fid);
  
  % Return data
  param = cell2struct( data(:, 2) , data(:, 1));
end
