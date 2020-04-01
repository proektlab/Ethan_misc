function [b, a] = exp_filter(width_2t, decay_2t)
% Produces the coefficients for a recursive single-pole low-pass filter i.e. exponential
% filter i.e. leaky integrator.
%
% The inputs specify the scale of the impulse response if it is applied in a zero-phase
% manner using filtfilt. At the point where this 2-tailed impulse response reaches
% decay_2t times the peak, the width will be width_2t samples.

amp = -2 * log(decay_2t) / width_2t;
b = amp;
a = [1, -exp(-amp)];

end