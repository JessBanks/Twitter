function [ ] = square_plot(boundaries,data,cmap)
%Colors polygons (with boundary points stored in the cell array
%'boundaries') according to the data vector 'data'.

if ~exist('cmap')
    cmap = cool;
end

nSquares = length(data);

hold on;
for square = 1:nSquares
%     shp files use NaNs to separate polygonal regions, so find them.
    if ismember(1,isnan(boundaries{square}(1,:)))
        breaks = [0 find(isnan(boundaries{square}(1,:)))];
        for poly = 1:(length(breaks)-1)
            to_fill = breaks(poly)+1:breaks(poly+1)-1;
            fill(boundaries{square}(1,to_fill),boundaries{square}(2,to_fill),double(data(square)),'EdgeColor','none');
        end
    else
        fill(boundaries{square}(1,:),boundaries{square}(2,:),double(data(square)),'EdgeColor','none');
    end
end
hold off 
% shading flat
colormap(cmap)
cbar = colorbar;

end

