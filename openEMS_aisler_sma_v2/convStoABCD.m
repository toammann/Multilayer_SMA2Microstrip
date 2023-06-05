function ABCD = convStoABCD(S, z0)
  % Pozar,Microwave Engineering 4th.edition, Chapter 4: Microwave Network Analysis
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