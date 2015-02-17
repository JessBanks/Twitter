function [] = texlab(xtext,ytext,titletext)
%Typesets x-axis, y-axis, and title with LaTex

xlabel(xtext,'Interpreter','LaTex','FontSize',20);
ylabel(ytext,'Interpreter','LaTex','FontSize',20);
title(titletext,'Interpreter','LaTex','FontSize',30);

end

