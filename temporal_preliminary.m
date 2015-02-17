%% Preliminary temporal analysis
clearvars
cd('C:\Users\Matthew Banks\Documents\Spring 2014\C4 Twitter Project');
load('Projects\Temporal\temporal_ws.mat');              

ny_ind = find(fips(:,1) == 36 & fips(:,2) == 61); % NY County
west_ind = find(county_centers(:,1) == min(county_centers(:,1))); % Westernmost county
east_ind = find(county_centers(:,1) == max(county_centers(:,1))); % Easternmost county
la_ind = find(fips(:,1) == 6 & fips(:,2) == 37); % LA County

center = @(x) (x - mean(x))./std(x);

% Plot full time series (synchronous time)
fullfigure;
plot((289:2305)/12,activity(289:2305),'LineWidth',2,'Color','black');
xlim([289 2305]/12);
xlab = 'Hours from 26-Apr 2014 12:00 UTC';
ylab = 'Tweets collected';
tlab = 'Timeseries of Twitter Activity';
texlab(xlab,ylab,tlab);
set(gca,'fontsize',16)

%% Fourier Transform of Full Time Series in Synchronous Time
Fs = (1/5)*(1/60); % Sampling frequency is once per 5 minutes
T = 1/Fs; % Period = 1/F

nFFT = 2^nextpow2(nTime);% for zero pad
spectrum = fft(activity-mean(activity),nFFT)/nTime;
frequency = Fs/2*linspace(0,1,nFFT/2+1);
% plot(frequency,2*abs(spectrum(1:nFFT/2+1)));
plot(3600*24*frequency,2*abs(spectrum(1:nFFT/2+1)));
xlim([0 10]);
xlab = 'Frequency (Cycles/day)';
ylab = 'Amplitude of FFT Coefficient';
tlab = 'Fourier Transform of Twitter Activity (Sync. Time)';
texlab(xlab,ylab,tlab);

%% Fourier Transforms of county timeseries
% Compute 'typical day' timeseries for each county
timePerDay = 12*24;
timeseries_day = zeros(nCounty,12*24);
std_day = zeros(nCounty,timePerDay);
for it = 1:timePerDay
    which = (12*24)*(0:nDay-1) + it;
    timeseries_day(:,it) = mean(timeseries(:,which),2);
    std_day(:,it) = std(timeseries(:,which),0,2);
end

% Compute county timeseries of deviations from typical day
timeseries_dev = (timeseries(:,1:nTime) - repmat(timeseries_day,1,nDay))./repmat(std_day,1,nDay);

nFFT_day = 288; %OR 2^nextpow2(288);
Fs = (1/5)*(1/60); % Sampling frequency is once per 5 minutes
T = 1/Fs;
frequency_day = Fs/2*linspace(0,1,nFFT_day/2+1);

county_spectra = zeros(nCounty,nFFT_day);
for county = 1:nCounty
    county_spectra(county,:) = fft(center(timeseries_day(county,:)),nFFT_day);
end

fullfigure;
scatter(3600*24*frequency_day,mean(abs(county_spectra(:,1:nFFT_day/2 + 1))),200,'filled');
xlim([0 20]);
xlab = 'Frequency (Cycles/day)';
ylab = 'Amplitude';
tlab = ' Avg. Fourier Transform of Daily Activity';
texlab(xlab,ylab,tlab);
set(gca,'fontsize',16)
%% Phase offset and geography

% Compute phase offsets (in hours, from easternmost county) of 3 largest magnitude Fourier components
which_county = east_ind;
phase1_relative = 24/(2*pi)*(angle(county_spectra(:,2)) - angle(county_spectra(which_county,2)));
phase2_relative = 12/(2*pi)*(angle(county_spectra(:,3)) - angle(county_spectra(which_county,3)));
phase3_relative = 8/(2*pi)*(angle(county_spectra(:,4)) - angle(county_spectra(which_county,3)));

% We'd naively expect phase offset to be linear in latitude with a slope of
% 24 hours/360 degrees, so fit the data to that. 
[xData, yData] = prepareCurveData(county_centers(:,1),phase2_relative);
ft = fittype( '(24/360)*x + b', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = 0.8498812306747;
[fitresult, gof] = fit( xData, yData, ft, opts );
phase2_relative_model = (24/360)*county_centers(:,1) + fitresult.b;

% Plot our fit
fullfigure;
hold on
scatter(county_centers(:,1),phase2_relative,50,'filled');
plot(county_centers(:,1),phase2_relative_model,'LineWidth',2,'Color','r');
xlab = 'Longitude';
ylab = 'Phase offset (Hours)';
tlab = 'Phase Offset vs. Latitude';
texlab(xlab,ylab,tlab);

% Map each county's deviation from this model
mapPlot(county_boundaries,phase2_relative - phase2_relative_model);
tlab = 'Phase Offset Dev. from Linear Model';
texlab('','',tlab);
axis tight off
