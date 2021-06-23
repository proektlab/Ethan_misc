function res = deep_structfun(fh, s)
% Applies a function to each field of s, or if the field is a struct, recursively applies it to
% the field's fields. Does not deal with nonscalar struct arrays and this won't ever apply
% the function to a struct. The result is a nested struct.

fn = make_deep_structfun_fn(fh);
res = structfun(fn, s, 'uni', false);

end

function fn = make_deep_structfun_fn(fh)

    fn = @deep_structfun_fn;

    function res = deep_structfun_fn(f)
        if isstruct(f)
            res = deep_structfun(fh, f);
        else
            res = fh(f);
        end
    end
end
