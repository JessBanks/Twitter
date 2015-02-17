%% Fisher Score workspace prep
% Creates raw_county_fisher_ws<nTag>.mat

% Needs hashtag_fisherscores_relative_n<nTag>.csv
%       htscores_combined.csv
%       counties.csv
%       counties.user_counts.bot_filtered.csv
%       county_geodesic_ws.mat (Output of geodesic_distance_ws_prep.mat)
%       cb_2013_us_county_500k.shp

% Calls aDistPair, shannonEnt, refSort

clearvars;
cd('C:\Users\Matthew Banks\Documents\Spring 2014\C4 Twitter Project')

% Import by-county hashtag counts. This array has:
%     Column 1: county fips (leading zeros removed)
%     Column 2: county fisher score
%     Column 3-end: hashtag counts, columns 1-1 with htscores_combined.csv

nTag = 50; %Set #tags (50,100,200 for now)
countfile = ['Data\Fisher Score\hashtag_fisherscores_relative_n',num2str(nTag),'.csv'];
countdata = csvread(countfile,1,0);
[nCounty, ~] = size(countdata);
% fips = zeros(nCounty,2);
fips(:,1) = floor(countdata(:,1)/1000); % Pick out state code
fips(:,2) = rem(countdata(:,1),1000);   % Pick out county code
county_fisher = countdata(:,2);        
county_counts = countdata(:,3:end);
clear countdata countfile

% Import hashtags etc. this array has
%     Column 1,5-7: NaN
%     Column 2: hashtag count (total)
%     Column 3: hashtag user count
%     Column 4: hashtag fisher score (across all counties)
tagfile = 'Data\Fisher Score\htscores_combined.csv';
[num, txt, ~] = xlsread(tagfile);
num = num(:,~isnan(num(1,:)));
hashtag_count = num(1:nTag,1);
hashtag_users = num(1:nTag,2);
hashtag_fisher = num(1:nTag,3);
hashtag = txt(2:nTag+1,1);
clear txt num tagfile

% Load county unique users. counties.user_counts.bot_filtered.csv has rows
% 1-1 with counties.csv. THESE ARE NOT IN THE SAME ORDER AS ABOVE.
countyfile = 'Data\Binned Data\County\Hashtag Counts\counties.csv';
[user_fips,county_name, ~] = xlsread(countyfile);
county_name = county_name(2:end,1);
userfile = 'Data\Binned Data\County\Hashtag Counts\counties.user_counts.bot_filtered.csv';
county_unique_users = csvread(userfile,1,0);
county_unique_users = refSort(fips,user_fips,county_unique_users); %Put counties in order above
clear user_fips countyfile userfile

% Load county centers. (These are population centers, not centroids).
% county_geodesic_distance_ws.mat is the output of
% geodesic_distance_ws_prep.mat, which is time-consuming to run. 
% Again the county order may be different.
centerfile = 'Raw Matlab Workspaces\county_geodesic_distance_ws.mat';
load(centerfile);
[county_population, ind] = refSort(fips,center_fips,county_population);
county_centers = county_centers(ind,:);
g_dist = g_dist(ind,ind);
clear center_fips num centerfile ind

% Load county shapefiles. Shapefile available at
%     https://www.census.gov/geo/maps-data/data/cbf/cbf_counties.html.
shapefile = 'Data\County\County Shapefiles\cb_2013_us_county_500k.shp';
county_shapes = shaperead(shapefile);
rmfield(county_shapes,{'Geometry','COUNTYNS','AFFGEOID','GEOID','LSAD','ALAND','AWATER'});
shape_fips = zeros(length(county_shapes),2);
for it = 1:length(county_shapes);
    shape_fips(it,:) = [str2num(county_shapes(it).STATEFP) str2num(county_shapes(it).COUNTYFP)];
end
county_shapes = refSort(fips,shape_fips,county_shapes);
clear shapefile shape_fips it

% Create cell array of county_boundaries
county_boundaries = cell(nCounty,1);
for county = 1:nCounty
    county_boundaries{county} = [county_shapes(county).X(1:end); county_shapes(county).Y(1:end)];
end

% Compute # unique hashtags observed
county_unique_tags = sum(county_counts - 0.5 > 0,2);

% Compute posterior mean estimates of hashtag distributions
county_dist = bsxfun(@times,county_counts,sum(county_counts,2).^-1);

% Compute entropy of each county distribution
county_entropy = shannonEnt(county_dist);

% Compute pairwise Aitchison distances
a_dist = aDistPair(county_dist);

savefile = ['Raw Matlab Workspaces\raw_county_fisher_ws',num2str(nTag),'.mat'];
save(savefile);