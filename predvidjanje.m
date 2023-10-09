load('nis_data.mat');
velicina = size(nis_data,1);
inputs = zeros(8, velicina);
future_days = 5;
valid_interval = (future_days+1):velicina;
target = zeros(2, length(valid_interval));

cena = nis_data(:, 1)';
promena = nis_data(:, 2)';
obim = nis_data(:, 3)';
promet = nis_data(:, 4)';
open = nis_data(:, 5)';
dnevna_min = nis_data(:, 6)';
dnevna_max = nis_data(:, 7)';

for i = valid_interval
    target(1, i) = max(dnevna_max(i-future_days+1:i)); % maximum price for the next 5 days
    target(2, i) = min(dnevna_min(i-future_days+1:i)); % minimum price for the next 5 days
end

% Simple 10-day moving average
for i = 10:velicina
    sma = mean(cena(i-9:i));
    inputs(1, i-9) = sma;
end

% Weighted 10-day moving average
for i = 10:velicina
    weights = 10:-1:1;
    wma = sum(cena(i-9:i) .* weights) / sum(weights);
    inputs(2, i-9) = wma;
end

% Momentum
momentum = zeros(1, velicina);
for i = 11:velicina
    momentum(i-10) = cena(i) - cena(i-10);
end
inputs(3, :) = momentum;

% Stochastic K%
% Stochastic D% je zapravo 3-dnevni pokretni prosek Stochastic K%
stoK = zeros(1, velicina);
stoD = zeros(1, velicina);
for i = 15:velicina
    stoK(i-14) = ((cena(i) - min(dnevna_min(i-14:i)))*100) / (max(dnevna_max(i-14:i)) - min(dnevna_min(i-14:i)));
end
for i = 17:velicina
    stoD(i-16) = mean(stoK(i-2:i));
end
inputs(4,:) = stoK;
inputs(5,:) = stoD;

% CCI (Commodity Channel Index) %
tp = (dnevna_max + dnevna_min + cena)/3;
sma_tp = movmean(tp,14); % 14-day moving average of tp
md = movmean(abs(tp - sma_tp),14); % 14-day moving average of |tp - sma_tp|
cci = (tp - sma_tp) ./ (0.015 * md);
inputs(6, :) = cci;

% Larry William’s R%:  %
highest_high = movmax(dnevna_max,14); % 14-day highest high
lowest_low = movmin(dnevna_min,14); % 14-day lowest low
r_percent = (highest_high - cena) ./ (highest_high - lowest_low) * -100;
inputs(7, :) = r_percent;

% MACD (Moving Average Convergence Divergence) %
alpha_short = 2/(12+1);
alpha_long = 2/(26+1);

% Initialization
short_ema = zeros(size(cena));
long_ema = zeros(size(cena));

short_ema(1) = cena(1);
long_ema(1) = cena(1);

% Calculation of EMA
for i = 2:length(cena)
    short_ema(i) = alpha_short * cena(i) + (1-alpha_short) * short_ema(i-1);
    long_ema(i) = alpha_long * cena(i) + (1-alpha_long) * long_ema(i-1);
end

macd_line = short_ema - long_ema;
alpha_signal = 2/(9+1);
signal_line = zeros(size(macd_line));
signal_line(1) = macd_line(1);
for i = 2:length(macd_line)
    signal_line(i) = alpha_signal * macd_line(i) + (1-alpha_signal) * signal_line(i-1);
end

macd_hist = macd_line - signal_line;
inputs(8, :) = macd_hist;

predict_value = inputs(:,1:1);
inputs = inputs(:, (future_days+1):(velicina-10));
target = target(:, (future_days+1):(velicina-10));




