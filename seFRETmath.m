function efficiency = seFRETmath(G,Dratio,Aratio,DAset)
% seFRETmath calculates FRET efficiency per pixel based on the
% sensitized-emission FRET analysis developed by S Vogel (NIH)
Fc = DAset(1) - DAset(2)*Dratio - DAset(3)*Aratio;
efficiency = (Fc/G)/(DAset(2) + Fc/G);