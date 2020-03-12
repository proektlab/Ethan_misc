function x = safeinput(prompt, validator, val_msg)
% input that reprompts instead of errors if you make a typo.
% also reprompts if input does't pass validator function, if used.
% if input does not pass validation, issues a warning including the
% optional val_msg, which should be formatted as a sentence.

if nargin < 2 || isempty(validator)
    validator = @(~) true;
end

if nargin < 3
    val_msg = '';
end

while true
    raw_input = input(prompt, 's');
    try
        % use eval to get around weird reprompting behavior of `input`
        if isempty(raw_input)
            x = [];
        else
            x = eval(raw_input);
        end

        if validator(x)
            return;
        else
            warning(['Invalid input - try again. ', val_msg]);
        end
    catch
        warning('Invalid syntax - try again.');
    end
end

end