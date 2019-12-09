// alert('hello')


var margin = {top: 30, right: 25, bottom: 100, left: 40},
  width = 1500 - margin.left - margin.right,
  height = 450- margin.top - margin.bottom;
  gridSize=Math.floor((width-45)/24);
	legendElementWidth=gridSize*2.665;
// console.log(window.innerWidth)
// console.log(window.innerHeight)


// var titleDropdown = d3.select(".titleDropdown")
//                 .append("svg")
//                 .attr("width", width + margin.left + margin.right)
//                 .attr("height", 100)
//                 .append("g")
//                 .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

// titleDropdown.append('text')
//               .attr('x', width/2)
//               .attr('y', 15)
//               .attr('text-anchor', 'middle')
//               .text('Socioeconomic Variations')
//               .attr('fill', 'white')
//               .style('font-size', 30)

// titleDropdown.append('text')
//               .attr('class', 'axis-text')
//               .html('<br><br>')
//               .attr('x', (width/2)-100)
//               .attr('font-size', 20)
//               .attr('y', 40)
//               .attr('text-anchor', 'middle')
//               .attr('fill', 'white')
//               .text('Metric:')

var myColors = ["#FFEBE7", "#FED7CF", "#FECABF", "#FEB7A7", "#FE9C87", "#FF896F ", "#FF7355", "#FC6241", "#FF2D00"]
var cols = [1, 2, 3, 4, 5, 6, 7, 8, 9]
var svgcols = d3.select(".firstrow").append("svg")
                .attr("viewBox", [-75, 0, 1600, 200])
                // .attr("width", width).attr("height",200)

// legend

svgcols.selectAll(".firstrow")
.data(cols).enter()
.append("rect")
.attr("x", function(d, i){ return legendElementWidth * i+50;})
.attr("y", 20)
.attr("width", legendElementWidth)
.attr("height", 20)
.attr("fill", function(d,i){return myColors[i] })





d3.csv("dat.csv").then(function(wide_data) {
        var long_data = [];
        wide_data.forEach( function(row) {
                                          // Loop through all of the columns, and for each column
                                          // make a new row
        Object.keys(row).forEach( function(colname) {
                                            // Ignore 'State' and 'Value' columns
        if(colname == "STATE" || colname == "Value" || colname == "YEAR") {
                return
                    }
                long_data.push({"States": row["STATE"], "Year": row["YEAR"], "Metric": colname, "Value": row[colname]});
                  });
          });

          window.data = long_data;

          data.forEach(function(d) {
              d['Value'] = +d['Value'];
              ;
          });
          // console.log(data)

    var svg = d3.select("#my_dataviz")
                .append("svg").attr("viewBox", [0, 0, 1500, 450])
                // .attr("width", width + margin.left + margin.right)
                // .attr("height", height + margin.top + margin.bottom)
                .append("g")
                .attr("transform", "translate(" + margin.left + "," + margin.top + ")");



    var tooltip = d3.select("#tooltip")
                      .attr('y', 50)
                      .style("opacity", 0)
                      .attr("class", "tooltip")
                      // .style("background-color", "white")
                      // .style("border", "solid")
                      // .style("border-width", "2px")
                      // .style("border-radius", "5px")
                      // .style("padding", "5px")


          // Three function that change the tooltip when user hover / move / leave a cell
      var mouseover = function(d) {
                        tooltip
                          .style("opacity", 1)
                        d3.select(this)
                          .style("stroke", "white")
                          .style("opacity", 1)
                      }
      var mousemove = function(d) {
                        tooltip
                          .html(d["States"] + "  " + d['Year']+ "<br>" + d['Value'])
                          // .style("left", ( d3.select(this).attr('x')-100  ) + "px")
                          // .style("top", ( d3.select(this).attr('y')+50  ) + "px")

                          .style("top", (d3.event.pageY + 16) + "px")
                          // .style("left", (d3.event.pageX + 16) + "px")

                          .style("left", function() {return d3.event.pageX >(window.innerWidth*.75) ? d3.event.pageX - 150+"px": d3.event.pageX + "px"});

                          // console.log(d3.select(this).attr('x'))
                      }
      var mouseleave = function(d) {
                        tooltip
                          .style("opacity", 0)
                        d3.select(this)
                          .style("stroke", "none")
                          .style("opacity", 0.8)
                      }




    var myCategories = d3.map(data, function(d) { return d['Metric'] }).keys()
    window.myCategories = myCategories
    // console.log(myCategories[3])
    var myCategories3 = myCategories[0]

    var dropDown = d3.select('.catfilter')
                      .append('select')
                      .attr('class', 'name-list')


    var options = dropDown.selectAll('option')
                          .data(d3.map(data, function(d) { return d['Metric'] }).keys())
                          .enter()
                          .append('option')
                          .text(function(d) { return d })
                          .attr('value', function(d) { return d });

    // var myGroups = d3.map(data, function(d){return d['States'];}).keys()

    var myVars = d3.map(data, function(d){return d['Year'];}).keys()


  // Build Y scales and axis:
    var y = d3.scaleBand()
            .range([ height, 0 ])
            .domain(myVars)
            .padding(0.05);
              svg.append("g")
                  .style("font-size", 14)
                  .attr('class', 'axis-text')
                  .call(d3.axisLeft(y).tickSize(0))
                  .select(".domain").remove()



    function updateHeatmap(newData, category){

    // data2 = window.data


    newData = data.filter(function(d) { return d['Metric'] == category })


    window.newData = newData
    // console.log(newData)
    var justvals = d3.map(newData, function(d){return d['Value'];}).keys()
    // console.log(justvals);
    // justvals.forEach(function(d) {
    //     d = +d;
    // });

    // console.log( (d3.max[justvals]) )
    // console.log((d3.max(d3.values(justvals))))


    // console.log(d3.min(newData, function(d) { return d['Value']; }))
    // console.log(d3.max(newData, function(d) { return d['Value']; }))

    minval = d3.min(newData, function(d) { return d['Value']; })
    maxval = d3.max(newData, function(d) { return d['Value']; })

    var myColor = d3.scaleQuantile().domain(justvals)
                          .range(["#FFEBE7", "#FED7CF", "#FECABF", "#FEB7A7", "#FE9C87", "#FF896F ", "#FF7355", "#FC6241", "#FF2D00"])

    var myGroups2 = d3.map(newData, function(d){return d['States'];}).keys()
    // console.log(myGroups2)
    var x2 = d3.scaleBand()
                .range([ 0, width ])
                .domain(myGroups2)
                .padding(0.05);
                svg.append("g")
                   .attr('class', 'x_axis')
                  .style("font-size", 14)
                  .attr('class', 'axis-text')
                  .attr("transform", "translate(0," + height + ")")
                  .call(d3.axisBottom(x2).tickSize(0))
                  .selectAll('text')
                  .style('text-anchor', 'end')
                  .attr('transform', 'rotate(-45)')
                  .select(".domain").remove()


    var appending = svg.selectAll('rect').data(newData);

    appending.enter().append('rect');

    appending.enter().append('rect')
                      .attr("x", function(d) { return x2(d['States']) })
                      .attr("y", function(d) { return y(d['Year']) })
                      .attr("rx", 4)
                      .attr("ry", 4)
                      .attr("width", x2.bandwidth() )
                      .attr("height", y.bandwidth() )
                      .style("fill", '#FFEBE7' )
                      // console.log(d["Value"]);
                      .style("stroke-width", 5)
                      .style("stroke", "none")
                      .style("opacity", 0.8)
                      // .attr('class', 'myRects')
                    .on("mouseover", mouseover)
                    .on("mousemove", mousemove)
                    .on("mouseleave", mouseleave);

    var rect_select = d3.selectAll('rect');
    rect_select.transition().duration(500).style("fill", function(d) { return myColor(d["Value"])} );



    appending.exit().remove();

    step = (maxval-minval)/9
    var allvals = []
    for (var i = 0; i < 9; i++) {
      var x = minval + step * i;
      allvals.push(x)
    }


    // Function below is to fix the issue of Math.round() producing incorrect results
    // Only used to display increments for legend
    function roundNumber(num, scale) {
      if(!("" + num).includes("e")) {
        return +(Math.round(num + "e+" + scale)  + "e-" + scale);
      } else {
        var arr = ("" + num).split("e");
        var sig = ""
        if(+arr[1] + scale > 0) {
          sig = "+";
        }
        return +(Math.round(+arr[0] + "e" + sig + (+arr[1] + scale)) + "e-" + scale);
      }
    }

    // console.log(allvals)

    svgcols.selectAll(".firstrow")
    .data(cols).enter()
    .append("rect")
    .attr("x", function(d, i){ return legendElementWidth * i+50;})
    .attr("y", 20)
    .attr("width", legendElementWidth)
    .attr("height", 20)
    .attr("fill", function(d,i){return myColors[i] })
    svgcols.selectAll('.legendtext')
           .data(allvals).enter()
           .append('text')
           .attr('class', 'legendtext')
           .attr('font-size', '13')
           .attr('fill', '#242424')
           .text(function(d) { return roundNumber(d,2) } )
           .attr('x', function(d, i){ return legendElementWidth * i+55;})
           .attr('y', 55)
    svgcols.selectAll('.legendtext').transition().duration(1000).style('fill', 'white')

  }

  updateHeatmap(window.newData, window.myCategories[0])

  function old_x() {
    window.OldX = d3.selectAll('.x_axis').remove();
    window.removeAllrect = d3.selectAll('rect').remove()
    window.resetlegendvals = d3.selectAll('.legendtext').remove()
  }

  d3.select('select')
    .on('change', function(d) {
      var category = d3.select('.name-list').node().value;
      window.category = category
      // console.log(category);
      old_x();
      updateHeatmap(newData, category);

    });


});
