function MI = mInfo(X,Y,nBin)
% Computes the mutual information between X and Y, given by
% MI(X,Y) = sum_{x,y} [ p(x,y)*log(p(x,y)/(p(x)*p(y))) ]
X = reshape(X,length(X),1);
Y = reshape(Y,length(Y),1);

Xedge = linspace(min(X),max(X),nBin+1);
Yedge = linspace(min(Y),max(Y),nBin+1);
Xedge(end) = inf;
Yedge(end) = inf;

pXY = hist3([X Y],'Edges',{Xedge Yedge});
pXY = pXY(1:end-1,1:end-1);
pXY = pXY./sum(pXY(:));

pX = histc(X,Xedge);
pX(end) = [];
pX = pX./sum(pX);

pY = histc(Y,Yedge);
pY(end) = [];
pY = pY./sum(pY);

logProd = bsxfun(@plus,log2(pX),log2(pY)');
logJoint = log2(pXY);
summand = pXY.*(logJoint - logProd);
zeroprobs = pXY == 0;
summand(zeroprobs) = 0;
MI = sum(summand(:));
end

