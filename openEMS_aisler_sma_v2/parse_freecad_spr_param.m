function [param, data] = parse_freecad_spr_param(filen, delim)

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
