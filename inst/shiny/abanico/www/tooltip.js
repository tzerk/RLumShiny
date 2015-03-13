$(window).load(function(){

$("#refresh").tooltip({	
			html: true,
		  	trigger: "hover",
			title: "Redraw the plot"
		      });

$("[for='summary']").tooltip({
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "Adds numerical output to the plot"
		      });

$("[for='sumpos']").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "Position of the statistical summary. The keyword 'Subtitle' will only work if no plot subtitle is used."
		      });

$("[for='stats']").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "Statistical parameters to be shown in the summary"
		      });

$("#statlabels").tooltip({	
			html: true,
		  	trigger: "hover",
			title: "Additional labels of statistically important values in the plot."
		      });

$("#errorbars").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "Option to show D<sub>e</sub>-errors as error bars on D<sub>e</sub>-points. Useful in combination with hidden y-axis and 2&sigma; bar"
		      });

$("#file1").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "<img src='file_structure.png' width='250px'/>"
		      });

$("#file2").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "<img src='file_structure.png' width='250px'/>"
		      });

$("#headers").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "<img src='file_containsHeader.png' width='250px'/>"
		      });

$("#sep").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "<img src='file_sep.png' width='400px'/>"
		      });

$("#cent").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "User-defined central value, primarily used for horizontal centering of the z-axis"
		      });

$("#bwKDE").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "Bin width of the kernel density estimate"
		      });

$("[for='p.ratio']").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "Relative space given to the radial versus the cartesian plot part, default is 0.75."
		      });

$("[for='centrality'").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "Measure of centrality, used for the standardisation, centering the plot and drawing the central line. When a second 2&sigma; bar is plotted the dataset is centered by the median."
		      });

$("[for='dispersion']").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "Measure of dispersion, used for drawing the polygon that depicts the spread in the dose distribution."
		      });

$("#rotate").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "Option to rotate the plot by 90&deg;."
		      });

$("#rug").tooltip({	
			html: true,
		  	trigger: "hover",
        placement: "auto",
			title: "Option to add a rug to the KDE part, to indicate the location of individual values"
		      });

$("[for='layout']").tooltip({	
			html: true,
      placement: "auto",
		  	trigger: "hover",
			title: "The optional parameter layout allows to modify the entire plot more sophisticated. Each element of the plot can be addressed and its properties can be defined. This includes font type, size and decoration, colours and sizes of all plot items. To infer the definition of a specific layout style cf. get_Layout() or type eg. for the layout type 'journal' get_Layout('journal'). A layout type can be modified by the user by assigning new values to the list object."
		      });

})