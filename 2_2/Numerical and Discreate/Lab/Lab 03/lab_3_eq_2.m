f = @(x) exp(x) - 4*sin(x) - 3*log(x);
a = 1; b = 2;
lim = 0.001;
fa = f(a); fb = f(b);

if fa * fb > 0
    disp('Wrong guess');
else
    fprintf('%-10s %-10s %-10s %-10s\n', 'a', 'b', 'c', 'f(c)');
    fprintf('---------------------------------------------\n');
    c = a - fa * (b - a) / (fb - fa); fc = f(c);
    while abs(fc) > lim
        fprintf('%-10.4f %-10.4f %-10.4f %-10.4f\n', a, b, c, fc);
        if fa * fc < 0
            b = c; fb = f(b);
        else
            a = c; fa = f(a);
        end
        c = a - fa * (b - a) / (fb - fa); fc = f(c);
    end
    fprintf('%-10.4f %-10.4f %-10.4f %-10.4f\n', a, b, c, fc);
    fprintf('Root for Equation 2 found at: %.4f\n', c);
end
