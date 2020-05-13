function [b_delta, b_theta, b_ab, b_gamma] = band_filters(Fs)
% Construct a bank of FIR bandpass filters with given sample rate.

% delta (0.5-4 Hz)
N      = 3000; % order
Fstop1 = 0.45;
Fpass1 = 0.5;
Fpass2 = 4;
Fstop2 = 4.1;
Wstop1 = 1;
Wpass  = 1;
Wstop2 = 1;

b_delta = firls(N, [0 Fstop1 Fpass1 Fpass2 Fstop2 Fs/2]/(Fs/2), ...
                [0 0 1 1 0 0], [Wstop1 Wpass Wstop2]);

% theta (4-10 Hz)
N      = 800;
Fstop1 = 3.9;
Fpass1 = 4;
Fpass2 = 10;
Fstop2 = 10.2;
Wstop1 = 1;
Wpass  = 1;
Wstop2 = 1;

b_theta = firls(N, [0 Fstop1 Fpass1 Fpass2 Fstop2 Fs/2]/(Fs/2), ...
                [0 0 1 1 0 0], [Wstop1 Wpass Wstop2]);

% alpha/beta (10-25 Hz)
N      = 400;
Fstop1 = 9.5;
Fpass1 = 10;
Fpass2 = 25;
Fstop2 = 26;
Wstop1 = 1;
Wpass  = 1;
Wstop2 = 1;

b_ab = firls(N, [0 Fstop1 Fpass1 Fpass2 Fstop2 Fs/2]/(Fs/2), ...
                [0 0 1 1 0 0], [Wstop1 Wpass Wstop2]);

% gamma (25-80 Hz)
N      = 150;
Fstop1 = 24;
Fpass1 = 25;
Fpass2 = 80;
Fstop2 = 83;
Wstop1 = 1;
Wpass  = 1;
Wstop2 = 1;

b_gamma = firls(N, [0 Fstop1 Fpass1 Fpass2 Fstop2 Fs/2]/(Fs/2), ...
                [0 0 1 1 0 0], [Wstop1 Wpass Wstop2]);


end
