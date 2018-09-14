function FigureToPDF(fig, name)
% FIGURETOPDF  Prints the figure fig to a PDF named 'name'.
% Automaticlly appends .pdf if missing.
%
% fig: The figure to print (use gcf for the currently open figure.
% name: Name of the output file.

set(fig,'Units','Inches');
pos = get(fig,'Position');
width = pos(3);
hight = pos(4);
set(fig,'PaperPositionMode','Auto','PaperUnits','Inches','PaperSize',[width, hight])
%[pos(3), pos(4)]
if strfind(name, '.pdf') == [ ]
    outputname = [name '.pdf'];
else
    outputname = name;
end



print(fig, '-painters', '-dpdf', '-r600', outputname);