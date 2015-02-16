function [a_dist] = aDistPair(prob)
% Computes pairwise Aitchison distances between the rows of 'prob 
% and outputs in 'a_dist'. Will compute in one pass if there is suficient
% memory.

% For two distributions p and q,
%   d(p,q) = sum_i[ ( log( p_i/g(p) ) - log( q_i/g(p) ) ) )^2 ]^(1/2)
%          = sum_i[ ( log( (p_i/q_i)/g(p/q) ) )^2 ]^(1/2)

mem = 5e8; % Set memory limit

[nObj, nState] = size(prob);

if nObj*(nObj - 1)*nState < mem 
%     If there is sufficient memory, compute in a single step.
%     Aitchison distance is symmetric, so pull the row/column coordinates
%     from below the diagonal.
    rowcoord = nonzeros(tril(repmat((1:nObj)',1,nObj),-1));
    colcoord = nonzeros(tril(repmat(1:nObj,nObj,1)-1));
    ratio = prob(rowcoord,:)./prob(colcoord,:);
    geo_mean = geomean(ratio,2);
    a_dist_vec = sum(log(bsxfun(@times,ratio,geo_mean.^-1)).^2,2);
else
%     Otherwise, separate into blocks of maximum allowable size and
%     compute.
    rowcoord = nonzeros(tril(repmat((1:nObj)',1,nObj),-1));
    colcoord = nonzeros(tril(repmat(1:nObj,nObj,1)-1));
    
    block_length = floor(mem/(8*nState));
    nBlock = floor(nObj*(nObj-1)/(2*block_length));
    blockstarts = [1:block_length:(nBlock*block_length) length(rowcoord)+1];
    
    a_dist_vec = zeros(size(rowcoord));
    for block = 1:nBlock
%         tic;
        row_temp = rowcoord(blockstarts(block):blockstarts(block+1)-1);
        col_temp = colcoord(blockstarts(block):blockstarts(block+1)-1);
        ratio = prob(row_temp,:)./prob(col_temp,:);
        geo_mean = geomean(ratio,2);
        a_dist_vec(blockstarts(block):blockstarts(block+1)-1) = sum(log(bsxfun(@times,ratio,geo_mean.^-1)).^2,2);
%         toc;
    end
end

% We've put all our distances in a vector that should fill the lower
% triangle of our pw distance matrix columnwise.
a_dist = squareform(a_dist_vec);
end

