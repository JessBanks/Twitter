%% Preliminary exploration of Fisher Scored data

clearvars
% cd('')

nTag = 100;
loadfile = ['Raw Matlab Workspaces\raw_county_fisher_workspace',num2str(nTag),'.mat'];
load(loadfile);

% Remove counties with too low a Fisher score and reindex everything
% one-one with it.
fisher_thresh = 1;
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

%% Make some exploratory plots

fullfigure;
scatter(county_unique_users,county_fisher,50,'filled');
xlog
xlab = 'Users';
ylab = 'Fisher Score';
tlab = ['Fisher Score vs. Users (nTag=',num2str(nTag),')'];
texlab(xlab,ylab,tlab);

fullfigure;
scatter(county_unique_tags,county_fisher,50,'filled');
xlab = 'Unique Tags';
ylab = 'Fisher Score';
tlab = ['Fisher Score vs. Unique Tags (nTag=',num2str(nTag),')'];
texlab(xlab,ylab,tlab);

fullfigure;
scatter(county_unique_users,(1/nCounty)*sum(a_dist),50,'filled');
xlog
xlab = 'Users';
ylab = '$\langle$ Aitchison Dist. $\rangle$';
tlab = ['Average Aitchison Distance vs. Users (nTag=',num2str(nTag),')'];
texlab(xlab,ylab,tlab);

fullfigure;
scatter(county_unique_tags,(1/nCounty)*sum(a_dist),50,'filled');
xlab = 'Unique Tags';
ylab = '$\langle$ Aitchison Dist. $\rangle$';
tlab = ['Average Aitchison Distance vs. Unique Tags (nTag=',num2str(nTag),')'];
texlab(xlab,ylab,tlab);

fullfigure;
scatter(county_fisher,(1/nCounty)*sum(a_dist),50,'filled');
xlab = 'Fisher Score';
ylab = '$\langle$ Aitchison Dist. $\rangle$';
tlab = ['Average Aitchison Distance vs. Fisher Score (nTag=',num2str(nTag),')'];
texlab(xlab,ylab,tlab);