%% Compute MDS and Isomap embeddings of Aitchison Distance data.
% Calls: mapPlot, knnGraph

nTag = 200;
loadfile = ['Raw Matlab Workspaces\raw_county_fisher_ws',num2str(nTag),'.mat'];
load(loadfile);

% Remove counties with too low a Fisher score
fisher_thresh = .8;
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

%% Compute MDS Embedding of data
[mds_embed, mds_eig] = cmdscale(a_dist);

% Look at variance of each mds dimension
fullfigure;
scatter(1:nCounty,mds_eig,50,'filled');

% Check for sampling bias by plotting embedding dimensions against #users
for it = 1:4
    fullfigure;
    scatter(county_unique_users,mds_embed(:,it),50,county_fisher,'filled');
    set(gca,'XScale','log');
end

% Map each dimension
for it = 1:4
    fullfigure;
    mapPlot(county_boundaries,mds_embed(:,it));
end

%% Compute Isomap embedding of data

% Construct radial neighborhod graph
% radius = ;
% dataG = a_dist <= radius & a_dist > 0;

% OR, Construct k nearest neighbor graph
nNeighbor = 10;
dataG = knnGraph(a_dist,nNeighbor,'distance');

fullfigure;
spy(dataG);

graphconncomp(sparse(dataG)) % Is dataG connected?
dataG_dist = graphallshortestpaths(sparse(dataG));

[iso_embed, iso_eig] = cmdscale(dataG_dist);

fullfigure;
scatter(1:nCounty,iso_eig,50,'filled');

fullfigure;
scatter3(iso_embed(:,1),iso_embed(:,2),iso_embed(:,3),50,log10(county_unique_users),'filled');

% Check for sampling bias by plotting embedding dimensions against #users
% for it = 1:4
%     fullfigure;
%     scatter(county_unique_users,iso_embed(:,it),50,county_fisher,'filled');
%     set(gca,'XScale','log');
% end

% Map each dimension
for it = 1:4
    fullfigure;
    mapPlot(county_boundaries,iso_embed(:,it));
end
