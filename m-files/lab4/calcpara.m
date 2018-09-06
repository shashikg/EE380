Kt = 25.5e-3; J = 13e-7; Kb = 0.0209;
Km = 39.3; Tm = 0.0565;
Rs = (Kt.*Tm)./(J.*Km)
B = (1./Rs).*(Kt./Km - Kt.*Kb)
