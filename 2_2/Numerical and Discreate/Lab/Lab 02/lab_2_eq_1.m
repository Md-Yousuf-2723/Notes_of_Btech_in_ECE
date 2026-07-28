f = @(x) x^3 - 2*x^2 - 5;
a = 2; b = 3;
lim = 0.001;
fa = f(a); fb = f(b);
fprintf('%-10s %-10s %-10s %-10s\n', 'a', 'b', 'c', 'f(c)');
fprintf('---------------------------------------------\n');
c = (a + b) / 2; fc = f(c);
while abs(fc) > lim
    fprintf('%-10.4f %-10.4f %-10.4f %-10.4f\n', a, b, c, fc);
    if fa * fc < 0
        b = c;
    else
        a = c; fa = f(a);
    end
    c = (a + b) / 2; fc = f(c);
end
fprintf('%-10.4f %-10.4f %-10.4f %-10.4f\n', a, b, c, fc);
fprintf('Root for Equation 1 found at: %.4f\n', c);
