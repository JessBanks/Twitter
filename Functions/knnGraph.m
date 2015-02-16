function Adj = knnGraph(input, k, type)
% Constructs a k nearest neighbor graph for the data in 'input'. 
% If type = 'coordinate', assumes the input is an array of data coordinates.
% If type = 'distance', assumes the input is a distance matrix.

% If no type is sepecified, assume the input is coordinates
if isequal(type,'coordinate') || ~exist('type','var')
    distMat = squareform(pdist(input));
else
    distMat = input;
end

[nData, ~] = size(input);
Adj = zeros(nData);

for it = 1:nData
    [~,ind] = sort(distMat(it,:),'ascend');
    Adj(it, ind(2 : k+1)) = true;
end

% Two points are connected if EITHER is among the k nearest neighbors of
% the other
Adj = Adj | Adj.';

end

