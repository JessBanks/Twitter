function [sorted, ind] = refSort(ref_ind,sort_ind,to_sort)
% Sorts one arry by the index of another. 
% Say we have a matrix M with rows one-one with the rows of an index matrix I,
% and another matrix N with rows one-one with some permutation of the rows of I which live in a
% second index matrix J. We want to compare M and N so we sort M to be
% one-one with I.

% Input: An array 'to_sort' which will be sorted (by row).
%        An array 'sort_ind' with rows that index 'to_sort'
%        An array 'ref_ind' with rows that will sort 'to_sort'.

nToSort = length(ref_ind(:,1)); % How many rows does ref_ind have?
ind = zeros(nToSort,1); % Preallocate the vector which will translate ref_ind to sort_ind

for entry = 1:length(sort_ind)
    which_row = find(ismember(ref_ind,sort_ind(entry,:),'rows'),1); % Is this row of sort_ind in ref_ind?
    ind(which_row) = entry;
end

% Test by putting sort_ind in the order given by ind.
if isequal(sort_ind(ind,:),ref_ind)
    sorted = to_sort(ind,:);
else 
    error('Sorted index not equal to reference index.');
end

end

