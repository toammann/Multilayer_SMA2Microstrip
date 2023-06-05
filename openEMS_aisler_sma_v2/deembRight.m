function Sdeemb = deembRight(Sdut, Sfix, z0, dbgPlt)
  
  ABCDfix = convStoABCD(Sfix, z0);
  ABCDdut = convStoABCD(Sdut, z0);

  for i = 1:length(Sdut)
    ABCDdeemb(:,:,i) = ABCDdut(:,:,i)*inv(ABCDfix(:,:,i));
  end

  Sdeemb = convABCDtoS(ABCDdeemb, z0);

end