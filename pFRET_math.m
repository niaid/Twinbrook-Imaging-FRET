function [E,pFRET,r] = pFRET_math(c_d,b_a,DA_DexDem,DA_DexAem,DA_AexAem)
% pFRET_math() computes the pFRET math for a per-ROI basis. This function
% is to be called within a loop when analyzing specific ROIs in a sample.
% Inputs and initial variables:
%   qDonor    Quenched Donor, FRET sample
%   uDonor    Unquenched Donor, FRET sample
%   p         Processed FRET (pFRET)
%   a = D_DexDem b = D_DexAem b_a = b/a
%   c = A_DexDem d = A_AexAem c_d = c/d
% Written by Javier Manzella-Lapeira for the LIG Imaging Core, 2017
% NIAID/NIH

e = DA_DexDem; % Donor CHannel, FRET sample
f = DA_DexAem; % Uncorrected FRET Channel, FRET sample
g = DA_AexAem; % Acceptor Channel, FRET sample

% coef = (Pd/Pa)*(Sd/Sa)*(Qd/Qa);
coef = 0.62/0.57; % Cerulean-Venus pair using same detector, same settings

% Acceptor Bleedthrough
ASBT = g.*(c_d);
% Donor Bleedthrough
DSBT = e.*(b_a);

% Corrected FRET channel
p = f - DSBT - ASBT;
pFRET = p;

% Efficiency calculations
qDonor = e + DSBT;
uDonor = qDonor + coef*p;
E = 100 * (1 - (qDonor/uDonor));
r = R0 * ((1/E)-1)^(1/6);

