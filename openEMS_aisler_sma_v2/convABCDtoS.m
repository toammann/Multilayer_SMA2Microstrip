function S = convABCDtoS(ABCD, z0)
  % Pozar,Microwave Engineering 4th.edition, Chapter 4: Microwave Network Analysis
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