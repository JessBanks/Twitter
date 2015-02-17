%% Temporal workspace prep
% Creates temporal_ws.mat

% Needs raw_county_fisher_workspace<ntag>.mat
%       temporal.csv

clearvars
cd('C:\Users\Matthew Banks\Documents\Spring 2014\C4 Twitter Project');

% Load workspace of Fisher-scored county data
nTag = 200;
countyfile = ['Raw Matlab Workspaces\raw_county_fisher_workspace',num2str(nTag)];
load(countyfile);

% Load temporal data from temporal.csv.
% Assumes data is in the following column_wise format:
% state_fips,county_fips, offset_to_eastern, year, month, day, weekday, COUNTS
timefile = 'Data\Temporal\temporal.csv';
data = csvread(timefile,3,0); % There are two lines of comments in this file

% Remove all data from September 1 2014, as not all counties have entries.
sep1 = datetime(data(:,4:6)) == datetime([2014 9 1]);
data(sep1,:) = [];

% Sort by date
[~,datesort] = sort(datetime(data(:,4:6)),'ascend');
data = data(datesort,:);
% fips = unique(data(:,1:2),'rows');
alldate = datetime(data(:,4:6));
date = unique(alldate);

nCounty = length(fips(:,1));
nDay = length(date);
nTime = 12*24*nDay;

% Preallocate
timeseries_local = zeros(nCounty,nTime);
timeseries = zeros(nCounty,nTime+3*12);
offset = zeros(nCounty,1);
starts = zeros(nCounty,1);
stops = zeros(nCounty,1);

% Create activity timeseries for each county
for county = 1:nCounty
    % Find all rows that correspond to a given county.
    which_rows = find(data(:,1) == fips(county,1) & data(:,2) == fips(county,2));
    % Put all the corresponding rows of counts into a matrix.
    ts_mat = zeros(nDay,12*24);
    ts_mat(ismember(date,alldate(which_rows)),:) = data(which_rows,8:end);
    % Make this into a vector and put it into 'timeseries_local'; all times
    % are initially local so this time series is aligned in local time.
    timeseries_local(county,:) = reshape(ts_mat',1,nTime);
    
    % Also, find the county timzesone offset (relatve to Eastern) and put it in
    % 'offset'. NY = X - offset.
    offset(county) = unique(data(which_rows,3));
    % Now put the data in timeseries so that global time is in synch
    starts(county) = 1 + 12*(-offset(county));
    stops(county) = starts(county) + nTime - 1;
    timeseries(county,starts(county):stops(county)) = reshape(ts_mat',1,nTime);
end

activity_local = sum(timeseries_local);
activity = sum(timeseries);
gaps = activity == 0;

clearvars -except timeseries timeseries_local fips date nCounty nDay nTime offset activity activity_local gaps county_boundaries county_centers county_counts county_shapes county_unique_users
save('Projects\Temporal\temporal_ws.mat');