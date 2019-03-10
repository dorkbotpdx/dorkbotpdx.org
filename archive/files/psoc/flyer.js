var focus = true;
function init() {
    d3.select("#svg-container").append("svg")
        .attr({
            "width": 480,
            "height" : 480,
            "class" : "flyer-svg"
        });
    getColors();
    drawPaths();
    drawCircles();
    drawPSoC();
    drawRectangles();
    startIntervals();
}

function drawPaths() {
    var svg = d3.select(".flyer-svg");
    svg.selectAll(".trace")
        .data(paths)
    .enter().append("path")
        .attr("transform", "translate(-24,-24)scale(1.1)")
        .attr("class", function(d) {return d.class;})
        .attr("id", function(d) {return d.id;})
        .attr("fill", "none")
        .attr("stroke", "#EEE")
        .attr("stroke-width", function(d) {return d.class.indexOf("active") < 0 ? 8 : 3;})
        .attr("stroke-linejoin", "round")
        .attr("d", function(d) {return d.d;});
}

function transitionPaths(initial) {
    // get color and set delay + duration
    paths.forEach(function(d){
        var color = d.attach ? d3.select("rect."+d.attach).attr("fill") : getRandomColor();
        var delay = 1500*Math.random() + 500;
        var duration = 500*Math.random() + 500;
        d.delay = delay;
        d.duration = duration;
        d.color = color;
        pathEnter(d3.select("#"+d.id+".active"), color, initial);
    });
}

function pathEnter(d, color, initial) {
    d.attr("stroke", color)
        .attr("stroke-dasharray", function(d) {
            d.color = color; // for circles
            var l = d3.select(this).node().getTotalLength(); 
            return l + " " + l;})
        .attr("stroke-dashoffset", function(d) {return d3.select(this).node().getTotalLength();})
    .transition()
        .delay(function(d) {return initial ? d.delay : 0;})
        .duration(function(d) {return d.duration;})
        .ease("linear")
        .attr("stroke-dashoffset", 0)
        .each("end", terminalOn);        
}

function pathExit(d, color) {
    d.transition()
        .delay(function(d) {return d.delay/2;})
        .duration(0)
        .attr("stroke-dashoffset", function(d) {return d3.select(this).node().getTotalLength();})
    .transition()
        .duration(500)
        .ease("linear")
        .attr("stroke-dasharray", function(d) { 
            var l = d3.select(this).node().getTotalLength(); 
            return l + " " + l;})
        .attr("stroke-dashoffset", function(d) {return -d3.select(this).node().getTotalLength();})
        .each("end", terminalOff);
}

function terminalOn(path) {
    d3.selectAll("circle."+path.id)
        .transition()
        .attr("stroke", path.color);
}

function terminalOff(path) {
    d3.selectAll("circle."+path.id)
        .transition()
        .attr("stroke", "#EEE");
}

function drawCircles() {
    var svg = d3.select(".flyer-svg");
    svg.selectAll(".circle")
        .data(circles)
    .enter().append("circle")
        .attr("transform", "translate(-24,-24)scale(1.1)")
        .attr("class", function(d) {return d.attach;})
        .attr("cx", function(d) {return d.cx;})
        .attr("cy", function(d) {return d.cy;})
        .attr("r", 4)
        .attr("stroke-width", 4)
        .attr("stroke", "#EEE")
        .attr("fill", "#EEE");
}

function drawPSoC() {
    var svg = d3.select(".flyer-svg");
    svg.append("rect")
        .attr("x", 110)
        .attr("y", 109)
        .attr("width", 260)
        .attr("height", 260)
        .attr("fill", "#333");
}

function drawRectangles() {
    var svg = d3.select(".flyer-svg");
    assignBlocks();

    var blockGroup = svg.selectAll(".block")
        .data(rectangles)
    .enter().append("g")
        .attr("class", function(d) {return "block "+d.class;})
        .attr("transform", function(d) {
            return "rotate("+d.angle+" "+d.in.x+","+d.in.y+") translate("+d.in.x+","+d.in.y+")";
        });
    blockGroup.append("rect")
        .attr("class", function(d) {return d.class;})
        .attr("rx", 4)
        .attr("ry", 4)
        .attr("width", function(d) {return d.width;})
        .attr("height", function(d) {return d.height;})
        .attr("fill", function(d) {return d.block.color;});
    blockGroup.append("text")
        .attr("fill", "#FFF")
        .attr("x", function(d) {return d.width/2;})
        .attr("y", function(d) {return d.height/1.5;})
        .attr("font-family", "source_code_proregular")
        .attr("text-anchor", "middle")
        .text(function(d) {return d.block.name;});
    transitionPaths(true);
}

function assignBlocks() {
    var shortCopy = shortNames.slice(0);
    var medCopy = medNames.slice(0);
    var longCopy = longNames.slice(0);
    var xLongCopy = xLongNames.slice(0);
 
    rectangles.forEach(function(m) {
        var nameArray;
        if(m.width < 53) {nameArray = shortCopy;}
        else if(m.width < 76) {nameArray = medCopy;}
        else if(m.width < 96) {nameArray = longCopy;}
        else {nameArray = xLongCopy;}
        m.block = getBlock(nameArray, m.block);
        m.interval = parseInt(Math.random()*10000 + 2500);
    });
}

function getBlock(nameArray, currentBlock) {
    var index = 0;
    var block = currentBlock;
    function getNew() {
        index = parseInt(Math.random()*nameArray.length); 
        block = nameArray[index];
    }
    if(!currentBlock || currentBlock.name == block.name) {getNew();}
    nameArray = nameArray.splice(index, 1);
    return block;
}

function startIntervals() {
    rectangles.forEach(function(m){
        var blockName = m.class.split(" ")[0];
        var blockGroup = d3.select("g."+blockName);
        var rect = d3.select("g."+blockName).select("rect");
        var txt = d3.select("g."+blockName).select("text");
        var paths = d3.selectAll("path.active."+blockName);
        var nameArray;
        if(m.width < 53) {nameArray = shortNames;}
        else if(m.width < 76) {nameArray = medNames;}
        else if(m.width < 96) {nameArray = longNames;}
        else {nameArray = xLongNames;}
        repeat();

        function repeat() {
            if(!focus) {return;}
            var block = m.block;
            function getNew() {
                var index = parseInt(Math.random()*nameArray.length); 
                block = nameArray[index];
            }
            if(block.name == m.block.name) {getNew();}
            block.color = getRandomColor();

            blockGroup
                .transition()
                    .each("start", function(d){
                        pathExit(paths, block.color);
                    })
                    .delay(function(d) {return d.interval;})
                    .duration(2000)
                    .ease("poly-out", 8)
                    .attr("transform", function(d) {
                        return "rotate("+d.angle+" "+d.out.x+","+d.out.y+") translate("+d.out.x+","+d.out.y+")";
                    })
                    .each("end", function(){
                        txt.text(block.name);
                        rect.attr("fill", block.color);
                    })
                .transition()
                    .duration(1500)
                    .ease("exp-out")
                    .attr("transform", function(d) {
                        return "rotate("+d.angle+" "+d.in.x+","+d.in.y+") translate("+d.in.x+","+d.in.y+")";
                    })
                    .each("end", function(d) {
                        pathEnter(paths, block.color);
                        repeat();
                        m.interval = parseInt(Math.random()*10000 + 2500);
                    });
        }
    });
}

function getColors() {
    var nameArrays = [shortNames, medNames, longNames, xLongNames];
    nameArrays.forEach(function(na) {
        na.forEach(function(n) { n.color = getRandomColor(); });
    });
}

function rand(min, max) {return parseInt(Math.random() * (max-min+1), 10) + min;}

function getRandomColor() {
    var h = rand(0, 360);
    var s = rand(90, 360);
    var l = rand(30, 60);
    return 'hsl(' + h + ',' + s + '%,' + l + '%)';
}
function windowActive() { 
    focus = true; 
    transitionPaths(false); 
    startIntervals(); 
}
function windowInactive() { 
    d3.selectAll("g, path, circle").transition().duration(0); 
    focus = false; 
}
window.onfocus = windowActive;
window.onblur = windowInactive;

init();