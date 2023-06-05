function posSkipped = skipFixedMeshLine(pos, minDist)

 # diffPos = diff(pos);
##  idx2del = find(diffPos < (minDist - 1e-12));
##  posSkipped = pos;
##  posSkipped(idx2del+1) = [];

  posSkipped = pos(1);
  
  for i=1:(length(pos)-1)
    
   diffPos = pos(i+1) - posSkipped(end); % compare with the last known good line
   
   if abs(diffPos) < (minDist - 1e-12)
     % Not a valid Mesh line 
     fprintf('Info: Delete mesh line in %s at %.4f. Distance to adjacent mesh line is smaller than minDist: %.4f < %.4f(minDist)\n', inputname(1), pos(i+1), diffPos, minDist);
   else
     % Valid mesh line --> save index as good
     posSkipped(end+1) = pos(i+1);
   endif
   
  endfor
end