function [entropy] = shannonEnt(p)
%Computes the shannon entropy of a probability distribution 'p', h = sum_i
%p_i log2(p_i). Assumes that summation should occur along the largest
%nonsingleton dimension of p, i.e. that this dimension indexes the states.

plogp = p.*log2(p);
plogp(p == 0) = 0;
entropy = -sum(plogp,ndims(p));

end

