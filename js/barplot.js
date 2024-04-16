//Set some initial values
var margin = options.margin,
    width = width-(2*margin),
    height = height-(2*margin),
    barPadding = options.barPadding*(width/data.length),
    barWidth = (width-(data.length*barPadding))/data.length,
    xmax = d3.max(data, function(d) { return d.year; }),
    xmin = d3.min(data, function(d) { return d.year; }),
    ymax = d3.max(data, function(d) { return d.value; });

//Create the x axis
var x = d3.scaleBand()
    .domain(data.map(function(d) { return d.year; }))
    .range([margin, margin+width]);
svg.append("g")
    .attr("transform", "translate(" + 0 + "," + (height+margin) + ")")
    .call(d3.axisBottom(x));
svg.append("text")
    .attr("transform", "translate(" + (width/2) + " ," + (height+2*margin) + ")")
    .attr("dx", "1em")
    .style("text-anchor", "middle")
    .style("font-family", "Tahoma, Geneva, sans-serif")
    .style("font-size", "12pt")
    .text(options.xLabel);

//Create the y axis
    var y = d3.scaleLinear()
    .range([height, 0])
    .domain([0, ymax]);
svg.append("g")
    .attr("transform", "translate(" + margin + ", " + margin + ")")
    .call(d3.axisLeft(y));
svg.append("text")
    .attr("transform", "translate(" + 0 + " ," + ((height+2*margin)/2) + ") rotate(-90)")
    .attr("dy", "1em")
    .style("text-anchor", "middle")
    .style("font-family", "Tahoma, Geneva, sans-serif")
    .style("font-size", "12pt")
    .text(options.yLabel);

//Create the chart title
svg.append("text")
    .attr("x", (width / 2))
    .attr("y", (margin/2))
    .attr("text-anchor", "middle")
    .attr("dx", "1em")
    .style("font-size", "16pt")
    .style("font-family", "Tahoma, Geneva, sans-serif")
    .text(options.chartTitle);

//Create the chart
svg.selectAll('rect')
    .data(data)
    .enter()
    .append('rect')
    .attr('width', barWidth)
    .attr('x', function(d, i) { return (margin+((i+0.5)*barPadding)+(i*barWidth)); })
    .attr('y', height + margin)
    .attr('fill', options.colour);

//Transition animation on load
svg.selectAll('rect')
    .transition()
    .delay(function(d,i){return (i*100);})
    .duration(function(d,i){return (1000+(i*200));})
    .attr('height', function(d) { return d.value/ymax * height; })
    .attr('y', function(d) { return (height+margin-(d.value/ymax * height)); });


//Create a tooltip
var Tooltip = d3.select('#htmlwidget_container')
    .append('div')
    .attr("class", "tooltip")
    .style('position', 'absolute')
    .style('background-color', 'rgba(255,255,255,0.8)')
    .style('border-radius', '5px')
    .style('padding', '5px')
    .style('opacity', 0)
    .style("font-family", "Tahoma, Geneva, sans-serif")
    .style("font-size", "12pt");


//Mouseover effects for tooltip
var mouseover = function(d) {
    Tooltip
        .style('opacity', 1)
        .style('box-shadow', '5px 5px 5px rgba(0,0,0,0.2)');
    d3.select(this)
        .attr('fill', 'rgba(100,0,0,1)');
};
var mousemove = function(d) {
    Tooltip
        .html('Year ' + d.year + ': ' + d.value)
        .style("left", (d3.mouse(this)[0]+30) + "px")
        .style("top", (d3.mouse(this)[1]+30) + "px");
};
var mouseleave = function(d) {
    Tooltip
        .style("opacity", 0);
    d3.select(this)
        .attr('fill', options.colour);
};


svg.selectAll('rect')
    .on("mouseover", mouseover)
    .on("mousemove", mousemove)
    .on("mouseleave", mouseleave);