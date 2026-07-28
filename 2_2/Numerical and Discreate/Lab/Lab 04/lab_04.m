function lab_04()
    clc; close all;

    f_true = input('Enter the function: ');
    x = input('Enter the x data points as a vector: ');
    xt = input('Enter the target values to estimate as a vector: ');

    y = f_true(x);
    yt = zeros(size(xt));
    method_name = '';

    fprintf('\n1. Linear\n2. Lagrange\n3. Newton Forward\n');
    choice = input('Select a method (1-3): ');

    fprintf('\n');
    switch choice
        case 1
            method_name = 'Linear';
            yt = calc_linear(x, y, xt, true);
        case 2
            method_name = 'Lagrange';
            yt = calc_lagrange(x, y, xt, true);
        case 3
            method_name = 'Newton Forward';
            [yt, D] = calc_newton_forward(x, y, xt, true);
        otherwise
            choice = 1;
            method_name = 'Linear';
            yt = calc_linear(x, y, xt, true);
    end

    fprintf('\nEstimated Values using %s:\n', method_name);
    for i = 1:length(xt)
        fprintf('f(%.4f) = %.4f\n', xt(i), yt(i));
    end

    res_lin = calc_linear(x, y, xt, false);
    res_lag = calc_lagrange(x, y, xt, false);
    [res_nf, ~] = calc_newton_forward(x, y, xt, false);

    all_results = [res_lin; res_lag; res_nf];
    method_names = {'Linear', 'Lagrange', 'Newton Fwd'};

    fprintf('\nMethod             ');
    for i = 1:length(xt)
        fprintf('f(%.4f)      ', xt(i));
    end
    fprintf('\n');

    for i = 1:3
        fprintf('%-18s ', method_names{i});
        for j = 1:length(xt)
            fprintf('%-12.6f ', all_results(i, j));
        end
        fprintf('\n');
    end

    fprintf('\nDifference from True Analytical Value:\n');
    true_vals = f_true(xt);
    for i = 1:3
        fprintf('%-18s ', method_names{i});
        for j = 1:length(xt)
            err = abs(all_results(i, j) - true_vals(j));
            fprintf('Error at %.2f: %-10.6f | ', xt(j), err);
        end
        fprintf('\n');
    end

    figure('Name', 'Interpolation Results', 'NumberTitle', 'off');
    x_smooth = linspace(min(x)-0.5, max(x)+0.5, 200);
    y_true_smooth = f_true(x_smooth);

    if choice == 2
        y_interp_smooth = calc_lagrange(x, y, x_smooth, false);
    elseif choice == 3
        [y_interp_smooth, ~] = calc_newton_forward(x, y, x_smooth, false);
    else
        y_interp_smooth = calc_linear(x, y, x_smooth, false);
    end

    plot(x_smooth, y_true_smooth, '--k', 'LineWidth', 1.2); hold on;
    plot(x_smooth, y_interp_smooth, '-b', 'LineWidth', 1.5);
    plot(x, y, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k');
    plot(xt, yt, 'r*', 'MarkerSize', 10, 'LineWidth', 2);

    title(sprintf('Interpolation using %s Method', method_name));
    xlabel('x'); ylabel('f(x)');
    legend('True Function', sprintf('%s Curve', method_name), 'Given Data Points', 'Interpolated Points', 'Location', 'NorthWest');
    grid on; hold off;
end

function y_est = calc_linear(x, y, xt, show_tab)
    y_est = zeros(size(xt));
    if show_tab
        fprintf('--- Linear Iteration Table ---\n');
        fprintf('%-10s %-10s %-10s %-10s %-10s %-10s\n', 'xt', 'x0', 'x1', 'y0', 'y1', 'Estimate');
    end
    for k = 1:length(xt)
        idx = find(x <= xt(k), 1, 'last');
        if isempty(idx) || idx == length(x), idx = length(x) - 1; end
        x0 = x(idx); x1 = x(idx+1);
        y0 = y(idx); y1 = y(idx+1);
        y_est(k) = y0 + (xt(k) - x0) * (y1 - y0) / (x1 - x0);
        if show_tab
            fprintf('%-10.4f %-10.4f %-10.4f %-10.4f %-10.4f %-10.4f\n', xt(k), x0, x1, y0, y1, y_est(k));
        end
    end
end

function y_est = calc_lagrange(x, y, xt, show_tab)
    n = length(x);
    y_est = zeros(size(xt));
    for k = 1:length(xt)
        sum = 0;
        if show_tab
            fprintf('\n--- Lagrange Iteration for xt = %.4f ---\n', xt(k));
            fprintf('%-5s %-10s %-10s %-10s %-10s %-10s\n', 'i', 'x(i)', 'y(i)', 'L_i', 'Term', 'Sum');
        end
        for i = 1:n
            product = 1;
            for j = 1:n
                if i ~= j
                    product = product * (xt(k) - x(j)) / (x(i) - x(j));
                end
            end
            term = y(i) * product;
            sum = sum + term;
            if show_tab
                fprintf('%-5d %-10.4f %-10.4f %-10.4f %-10.4f %-10.4f\n', i, x(i), y(i), product, term, sum);
            end
        end
        y_est(k) = sum;
    end
end

function [y_est, D] = calc_newton_forward(x, y, xt, show_tab)
    n = length(x);
    D = zeros(n, n); D(:,1) = y(:);
    for j = 2:n
        for i = 1:n-j+1
            D(i,j) = D(i+1,j-1) - D(i,j-1);
        end
    end
    if show_tab
        fprintf('--- Newton Forward Difference Table ---\n');
        disp(D);
    end
    h = x(2) - x(1);
    y_est = zeros(size(xt));
    for k = 1:length(xt)
        p = (xt(k) - x(1)) / h;
        val = D(1,1); term = 1;
        if show_tab
            fprintf('\n--- Newton Fwd Iteration for xt = %.4f (p = %.4f) ---\n', xt(k), p);
            fprintf('%-5s %-12s %-12s %-12s %-12s\n', 'j', 'Multiplier', 'D(1,j)', 'Added Term', 'Estimate');
            fprintf('%-5d %-12.4f %-12.4f %-12.4f %-12.4f\n', 1, 1.0000, D(1,1), D(1,1), val);
        end
        for j = 2:n
            term = term * (p - j + 2) / (j - 1);
            added_term = term * D(1,j);
            val = val + added_term;
            if show_tab
                fprintf('%-5d %-12.4f %-12.4f %-12.4f %-12.4f\n', j, term, D(1,j), added_term, val);
            end
        end
        y_est(k) = val;
    end
end

