function [b, a] = exp_filter(width_2t, decay_2t)
% Produces the coefficients for a recursive single-pole low-pass filter i.e. exponential
% filter i.e. leaky integrator.
%
% The inputs specify the scale of the impulse response if it is applied in a zero-phase
% manner using filtfilt. At the point where this 2-tailed impulse response reaches
% decay_2t times the peak, the width will be width_2t samples.

assert(width_2t >= 1, 'Width must be positive');

if width_2t == 1 % make a no-op
    b = 1;
    a = 1;
else
    if mod(width_2t, 2) == 0
        % we want it to be odd, just add 1
        width_2t = width_2t + 1;
    end

    amp = -2 * log(decay_2t) / (width_2t - 1);
    b = amp;
    a = [1, -exp(-amp)];
end

end