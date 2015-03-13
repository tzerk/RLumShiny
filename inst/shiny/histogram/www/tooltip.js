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

$("[for='error.bars']").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "Plot the standard error points over the histogram."
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

$("[for='p.ratio']").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "Relative space given to the radial versus the cartesian plot part, default is 0.75."
		      });

$("#rug").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "Option to add a rug to the KDE part, to indicate the location of individual values"
		      });

$("#norm").tooltip({	
			html: true,
		  	trigger: "hover",
			placement: "auto",
			title: "Add a normal curve to the histogram. Mean and standard deviation are calculated from the input data. If the normal curve is added, the y-axis in the histogram will show the probability density"
		      });

})