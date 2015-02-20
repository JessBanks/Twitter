%% Analysis of temporal data
% Calls mInfo mInfoC mapPlot

clearvars
cd('C:\Users\Matthew Banks\Documents\Spring 2014\C4 Twitter Project');
nTag = 100;
fisherfile = ['Raw Matlab Workspaces\raw_county_fisher_workspace',num2str(nTag),'.mat'];
load(fisherfile);
timefile = 'Projects\Temporal\temporal_ws.mat';
load(timefile);

% Remove counties with too low a Fisher score and reindex everything
% one-one with it.
fisher_thresh = .6;
keep_counties = find(county_fisher <= fisher_thresh);
a_dist = a_dist(keep_counties,keep_counties);
county_boundaries = county_boundaries(keep_counties,:);
county_centers = county_centers(keep_counties,:);
county_counts = county_counts(keep_counties,:);
county_dist = county_dist(keep_counties,:);
county_entropy = county_entropy(keep_counties,:);
county_fisher = county_fisher(keep_counties,:);
county_population = county_population(keep_counties,:);
county_shapes = county_shapes(keep_counties,:);
county_unique_tags = county_unique_tags(keep_counties,:);
county_unique_users = county_unique_users(keep_counties,:);
fips = fips(keep_counties,:);
g_dist = g_dist(keep_counties,keep_counties);
nCounty = length(keep_counties);
timeseries = timeseries(keep_counties,:);
timeseries_local = timeseries_local(keep_counties,:);
offset = offset(keep_counties,:);

% Calculate the indices of some useful counties
ny_ind = find(fips(:,1) == 36 & fips(:,2) == 61); % NY County
west_ind = find(county_centers(:,1) == min(county_centers(:,1))); % Westernmost county
east_ind = find(county_centers(:,1) == max(county_centers(:,1))); % Easternmost county
la_ind = find(fips(:,1) == 6 & fips(:,2) == 37); % LA County

center = @(x) (x - mean(x))./std(x);

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

% Compute phase offsets (in hours, from easternmost county) of 3 largest magnitude Fourier components
ref_county = east_ind;
phase_relative = zeros(nCounty,timePerDay-1);
for it = 1:timePerDay-1
    phase_relative(:,it) = (24/it)/(2*pi)*(angle(county_spectra(:,it+1)) - angle(county_spectra(ref_county,it+1)));
end

% We'd naively expect phase offset to be linear in latitude with a slope of
% 24 hours/360 degrees, so fit the data to that. 
which_phase = 2; % Look at the 1/day Fourier component
[xData, yData] = prepareCurveData(county_centers(:,1),phase_relative(:,which_phase));
ft = fittype( '(24/360)*x + b', 'independent', 'x', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Display = 'Off';
opts.StartPoint = 0.8498812306747;
[fitresult, gof] = fit( xData, yData, ft, opts );
phase_relative_model = (24/360)*county_centers(:,1) + fitresult.b;

% Plot our fit
fullfigure;
hold on
scatter(county_centers(:,1),phase_relative(:,which_phase),50,'filled');
plot(county_centers(:,1),phase_relative_model,'LineWidth',2,'Color','r');
xlab = 'Longitude';
ylab = 'Phase offset (Hours)';
tlab = 'Phase Offset vs. Latitude';
texlab(xlab,ylab,tlab);

% Map each county's deviation from this model
fullfigure;
mapPlot(county_boundaries,phase_relative(:,which_phase) - phase_relative_model);
tlab = ['Phase Offset Dev. from Linear Model, ',num2str(which_phase),'/day'];
texlab('','',tlab);
axis tight off
%% Compare Fourier, Aitchison and Geographic Distances
distf = @(x,X) sqrt(sum(bsxfun(@plus,X,-x).*conj(bsxfun(@plus,X,-x)),2));
s_dist = squareform(pdist(county_spectra,distf));
[mds_embed,mds_eig] = cmdscale(s_dist);

nBin = 20;
MI = mInfo(squareform(s_dist),squareform(a_dist),nBin);
MInull = mInfo(randsample(squareform(s_dist),length(squareform(s_dist)),'false'),squareform(a_dist),nBin);
MIcond = mInfoC(squareform(s_dist),squareform(a_dist),squareform(g_dist),nBin);

for nb = 2:2:100
    tic;
    MIvec(nb/2) = mInfo(squareform(s_dist),squareform(a_dist),nb);
    MICvec(nb/2) = mInfoC(squareform(s_dist),squareform(a_dist),squareform(g_dist),nb);
    toc;
end
fullfigure;
hold on
plot(MIvec,'LineWidth',2,'Color','b');
plot(MICvec,'LineWidth',2,'Color','r');
hold off;

[edges,avgs] = distanceComparison(g_dist,a_dist,100,'cum');
plot(edges,avgs);