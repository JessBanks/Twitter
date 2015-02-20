%% Pairwise geographic distance prep
% This computation is long and should only be done once.

clearvars;
% cd('C:\Users\Matthew Banks\Documents\Spring 2014\C4 Twitter Project')

centerfile = 'Data\County\county_population_centers_2010.csv';
[num, ~, ~] = xlsread(centerfile);
center_fips = num(:,1:2);
county_centers = num(:,[7 6]); % Reverse lat and long
county_population = num(:,5);

nCounty = length(center_fips(:,1));

g_dist = zeros(nCounty,nCounty);
for it = 1:nCounty
    for jt = it:nCounty
        g_dist(it,jt) = distance(county_centers(it,2),county_centers(it,1),county_centers(jt,2),county_centers(jt,1));
    end
end
g_dist = g_dist + g_dist.';
radius = 3963.1676;
g_dist = g_dist.*(2*pi*radius/360);

clearvars -except center_fips centerfile county_centers county_population g_dist
save('Raw Matlab Workspaces\county_geodesic_distance_ws.mat');