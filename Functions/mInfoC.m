function MI = mInfoC(X,Y,Z,nBin)
% Mutual information between X and Y conditioned on Z, given by
% MI(X;Y | Z) = sum_{x,y,z} p(x,y,z) * log( (p(z)*p(x,y,z))/(p(x,z)*p(y,z)) )

X = reshape(X,length(X),1);
Y = reshape(Y,length(Y),1);
Z = reshape(Z,length(Z),1);

edges = {linspace(min(X),max(X)+2*eps,nBin+1), linspace(min(Y),max(Y)+2*eps,nBin+1), linspace(min(Z),max(Z)+2*eps,nBin+1)};
edges{1}(end) = inf;
edges{2}(end) = inf;
edges{3}(end) = inf;
[pZ,Zsort] = histc(Z,edges{3});
pZ = pZ./sum(pZ(:));
pZ = pZ(1:end-1);

pXYZ = zeros(nBin,nBin,nBin);
for bin = 1:nBin
    select = Zsort == bin;
    pTemp = hist3([X(select) Y(select)],'Edges',{edges{1} edges{2}});
    pTemp = pTemp(1:end-1,1:end-1);
    pXYZ(:,:,bin) = reshape(pTemp,nBin,nBin,1);
end
pYZ = reshape(sum(pXYZ,1),nBin,nBin);
pYZ = pYZ./sum(pYZ(:));

pXZ = reshape(sum(pXYZ,2),nBin,nBin);
pXZ = pXZ./sum(pXZ(:));

pXYZ = pXYZ./sum(pXYZ(:));
% 
% pXZ = hist3([X Z],'Edges',{edges{1} edges{3}});
% pXZ = pXZ(1:end-1,1:end-1);
% pXZ = pXZ./sum(pXZ(:));
% 
% pYZ = hist3([Y Z],'Edges',{edges{2} edges{3}});
% pYZ = pYZ(1:end-1,1:end-1);
% pYZ = pYZ./sum(pYZ(:));

% Expand as
% MI(X;Y | Z) = sum_{x,y,z} p(x,y,z) * [log(p(z) + log(p(x,y,z)) - log(p(x,z)) - log(p(y,z))]

logNum = bsxfun(@plus,log2(pXYZ),log2(reshape(pZ,1,1,nBin)));
logDen = bsxfun(@plus,log2(reshape(pXZ,nBin,1,nBin)),log2(reshape(pYZ,1,nBin,nBin)));
summand = pXYZ.*(logNum - logDen);
zeroprobs = pXYZ == 0;
summand(zeroprobs) = 0;
MI = sum(summand(:));
end

