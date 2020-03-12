function x = safeinput(prompt, validator)
% input that reprompts instead of errors if you make a typo
% also reprompts if input does't pass validator function, if used

if nargin < 2
    validator = @(~) true;
end

while true
    try
        x = input(prompt);
        if validator(x)
            return;
        end
    catch
    end
end
end