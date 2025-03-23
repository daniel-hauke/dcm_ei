
set(0,'DefaultAxesFontName','Aptos')
set(0,'DefaultAxesFontWeight','normal')
set(0,'DefaultAxesFontSize',31)


tau_range = [2 4 8 16 32 64 128];

t = linspace(0,1000,1000);

cols = winter(numel(tau_range));

scrsz = get(0,'screenSize');
fh = figure('OuterPosition',[0.05*scrsz(3),0.05*scrsz(4),.535*scrsz(3),0.575*scrsz(4)]);
hold all;
for i = 1:numel(tau_range)
    tau = tau_range(i);
    y(i,:) = 1/tau.*t.*exp((-1/tau).*t);
    plot(t, y(i,:), 'Color',cols(i,:), 'LineWidth',3);
end
xlabel('time [ms]')
ylabel('h ( t )','FontAngle','italic')
l = legend( arrayfun(@num2str, tau_range, 'UniformOutput', false), 'Location', 'BestOutside');
title(l,'\tau');



V = linspace(-50,50,1000);
S_range = [-2 -1 0 1 2];

cols = winter(numel(S_range));
scrsz = get(0,'screenSize');
fh = figure('OuterPosition',[0.05*scrsz(3),0.05*scrsz(4),.535*scrsz(3),0.575*scrsz(4)]);
hold all;
clear y
for i = 1:numel(S_range)
    S = exp(S_range(i));
    y(i,:) = 1./(1+exp(-S*V))-0.5;
    plot(V, y(i,:), 'Color',cols(i,:), 'LineWidth',3);
end
xlabel('V_{in}','FontAngle','italic')
ylabel('\sigma ( V_{in} )','FontAngle','italic')
l = legend(strcat('e^{', arrayfun(@num2str, S_range, 'UniformOutput', false), '}'), 'Location', 'BestOutside');
title(l,'S','FontWeight', 'normal');
