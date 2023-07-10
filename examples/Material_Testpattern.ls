//======================================
//  Testpattern incl. labeling
//======================================

//====================================================================
//USER Adjustments
//====================================================================
var write_pattern       = 1;    //1:write   0:don't write
    var testShape           = 1;    //0=rectangle; 1=triangle

    //laser parameters for PATTERN
    var frequency		= parseInt(prompt("Frequenz?"));      //frequency in Hz       ***ATTENTION***

    var startPower 		= 10;       //in %                  ***ATTENTION***
    var endPower 		= 100;
    var powerStep 		= 10;       //power-increment in % 

    var startSpeed 		= 10;       //in %                  ***ATTENTION***
    var endSpeed 		= 100; 
    var speedStep	 	= 10;       //speed-increment in %

var write_labels        = 1;    //1:write   0:don't write

    //laser parameter for LABELS
    var labelpower          = 15;            //***ATTENTION***
    var labelspeed          = 100;
    var labelfreq           = 5000;

    var matname             = prompt("Materialname?");
    var thickness           = prompt("Dicke?");



var cutOutside          = 1;    //

    //laser parameter for OUTSIDE_CUT
    var cutpower            = 100;       //in %
    var cutspeed            = 35;      //in %
    var cutfreq             = 2500;      //in %



//====================================================================
//less important User-variables
//====================================================================


//====================================================================
//testpattern parameters
//====================================================================
var rectangleWidth 	= 5;    //define rectangle dimensions
var rectangleHeight     = 10;
var space 		= 2;    //space between rectangles in x-/y-direction
//====================================================================


//====================================================================
//labels
//====================================================================
var textsize            = 3;
var textspace           = space/2;
//====================================================================


// available chars
//var test0 = '0123456789';
//var test1 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
//var test2 = '0 - _ , 0';


//====================================================================
//program variables DON'T CHANGE
//====================================================================
var lines               = 6;    //no of (text-)lines over testpattern
var border              = 3;     //border outside text an pattern
var holediameter        = 8;     //diameter of hole in mm
var holepos             = 5;     //space between outside and hole
var textposX            = holepos*2+holediameter;    //space between left border and text

//reorder power & speed values, if necessary
var helper;
if (startSpeed<endSpeed){ //Speed goes from fast -> slow
    helper = startSpeed;
    startSpeed = endSpeed;
    endSpeed = helper;
}

if (startPower>endPower){ //Power goes from little -> much
    helper = startPower;
    startPower = endPower;
    endPower = helper;
}

var deltaX = startPower-endPower;
  if (deltaX<0) {deltaX=-deltaX;};
var deltaY = startSpeed-endSpeed;
  if (deltaY<0){deltaY=-deltaY;};
  

var numX = (1+(deltaX)/powerStep);
var numY = (1+(deltaY)/speedStep);
//====================================================================



//======================================
//        MAIN
//======================================
set("frequency", frequency);

//====================================================================
//write pattern
//====================================================================
//move(border, border);
//line(border+0.5, border);

if (write_pattern) {
    for (var i = 0; i < numX; i++)
    {
            var power = startPower+i*powerStep; //Power goes from little -> much
            set("power", power);
            for (var j = 0; j < numY; j++)
            {
                    var speed = startSpeed-j*speedStep; //Speed goes from fast -> slow
                    set("speed", speed);
                    var x = border+(rectangleWidth+space)*i;
                    var y = border+((textsize+space)*lines)+(rectangleHeight+space)*j;
                    if (testShape === 0)
                        {
                            rectangle(x, y, rectangleWidth, rectangleHeight);
                        }
                    else 
                        {
                            triangle(x, y, rectangleWidth, rectangleHeight);
                        }
                    
             }
    }
}
//====================================================================


//====================================================================
//write labels
//====================================================================
set("frequency", labelfreq);

if (write_labels) {
    set("power", labelpower);
    set("speed", labelspeed);

    segment7write (border+textposX, border, textsize/2, 'MAT - '+ matname);
    segment7write (border+textposX, border+(textsize+space)*1, textsize/2, 'THICK - ' + thickness);
    segment7write (border+textposX, border+(textsize+space)*2, textsize/2, 'FREQ - ' + frequency + ' Hz');
    
//write speed values on right side
    for (var spd = 0; spd < numY; spd++)
        {
               segment7write (border+(numX)*(rectangleWidth+space), border+((textsize+space)*lines)+rectangleHeight/8*5+(rectangleHeight+space)*spd, textsize/2, ''+(startSpeed-spd*speedStep)); //Speed goes from fast -> slow
        }
        
//write power values on top side
    for (var pwr = 0; pwr < numX; pwr++)
        {
               segment7write (border+pwr*(rectangleWidth+space), border+(textsize+space)*(lines-1), textsize/2, ''+(startPower+pwr*powerStep)); //Power goes from little -> much
        }
    segment7write (border+pwr*(rectangleWidth+space)+space, border+(textsize+space)*(lines-1), textsize/2, 'PWR');
    segment7write (border+pwr*(rectangleWidth+space)+space, border+(textsize+space)*lines, textsize/2, 'SPD');
}
//====================================================================



//====================================================================
//cut outside & hole
//====================================================================
if (cutOutside) {
    
    set("frequency", cutfreq);
    set("power", cutpower);
    set("speed", cutspeed);
    
    rectangle (holepos, holepos, holediameter, holediameter)
    rectangle (0, 0, 2*border+numX*(rectangleWidth+space)+space+(textsize/2+textspace)*3, ((textsize+space)*lines)+(rectangleHeight+space)*(numY-1)+rectangleHeight+2*border)
}
//====================================================================



//======================================
//        functions
//======================================

function rectangle(x, y, width, height)
{
	move(x, y);
	line(x+width, y);
	line(x+width, y+height);
	line(x, y+height);
	line(x, y);
}

function triangle(x, y, width, height)
{
	move(x, y);
	line(x+width, y+height);
	line(x, y+height);
	line(x, y);
}



//======================================
//        7 Segment functions
//======================================


function segmentLine(x1, y1, x2, y2)
{
    move(x1, y1);
    line(x2, y2);
}

function segment7draw (x,y,w,h,values)
{
    var xw = x+w;
    var yh = y+h;
    var yh2 = y+h/2;
    
    if (values[0] === 1) //A
    {
        segmentLine(x, y, xw, y);
    }
    if (values[1] === 1) //B
    {
       segmentLine(xw, y, xw, yh2);
    }
    if (values[2] === 1) //C
    {
        segmentLine(xw, yh2, xw, yh);
    }
    if (values[3] === 1) //D
    {
        segmentLine(xw, yh, x, yh);
    }
    if (values[4] === 1) //E
    {
        segmentLine(x, yh, x, yh2);
    }
    if (values[6] === 1) //G
    {
        segmentLine(x, yh2, xw, yh2);
    }
    if (values[5] === 1) //F
    {
        segmentLine(x, yh2, x, y);
    }
}


function segment7write (x,y,w,string)
{
    var characterMap = 
    {
        '0': [1, 1, 1, 1, 1, 1, 0],
        '1': [0, 1, 1, 0, 0, 0, 0],
        '2': [1, 1, 0, 1, 1, 0, 1],
        '3': [1, 1, 1, 1, 0, 0, 1],
        '4': [0, 1, 1, 0, 0, 1, 1],
        '5': [1, 0, 1, 1, 0, 1, 1],
        '6': [1, 0, 1, 1, 1, 1, 1],
        '7': [1, 1, 1, 0, 0, 0, 0],
        '8': [1, 1, 1, 1, 1, 1, 1],
        '9': [1, 1, 1, 1, 0, 1, 1],
        
        'A': [1, 1, 1, 0, 1, 1, 1],
        'B': [0, 0, 1, 1, 1, 1, 1],
        'C': [1, 0, 0, 1, 1, 1, 0],
        'D': [0, 1, 1, 1, 1, 0, 1],
        'E': [1, 0, 0, 1, 1, 1, 1],
        'F': [1, 0, 0, 0, 1, 1, 1],
        'G': [1, 1, 1, 1, 0, 1, 1],
        'H': [0, 1, 1, 0, 1, 1, 1],
        'I': [0, 0, 0, 0, 1, 1, 0],
        'J': [0, 1, 1, 1, 1, 0, 0],
        'K': [0, 1, 1, 0, 1, 1, 1],
        'L': [0, 0, 0, 1, 1, 1, 0],
        'M': [1, 0, 1, 0, 1, 0, 0],
        'N': [0, 0, 1, 0, 1, 0, 1],
        'O': [1, 1, 1, 1, 1, 1, 0],
        'P': [1, 1, 0, 0, 1, 1, 1],
        'Q': [1, 1, 1, 0, 0, 1, 1],
        'R': [0, 0, 0, 0, 1, 0, 1],
        'S': [1, 0, 1, 1, 0, 1, 1],
        'T': [0, 0, 0, 1, 1, 1, 1],
        'U': [0, 1, 1, 1, 1, 1, 0],
        'V': [0, 0, 1, 1, 1, 0, 0],
        'W': [0, 1, 0, 1, 0, 1, 0],
        'X': [0, 1, 1, 0, 1, 1, 1],
        'Y': [0, 1, 1, 1, 0, 1, 1],
        'Z': [1, 1, 0, 1, 1, 0, 1],
        
        'a': [1, 1, 1, 0, 1, 1, 1],
        'b': [0, 0, 1, 1, 1, 1, 1],
        'c': [1, 0, 0, 1, 1, 1, 0],
        'd': [0, 1, 1, 1, 1, 0, 1],
        'e': [1, 0, 0, 1, 1, 1, 1],
        'f': [1, 0, 0, 0, 1, 1, 1],
        'g': [1, 1, 1, 1, 0, 1, 1],
        'h': [0, 1, 1, 0, 1, 1, 1],
        'i': [0, 0, 0, 0, 1, 1, 0],
        'j': [0, 1, 1, 1, 1, 0, 0],
        'k': [0, 1, 1, 0, 1, 1, 1],
        'l': [0, 0, 0, 1, 1, 1, 0],
        'm': [1, 0, 1, 0, 1, 0, 0],
        'n': [0, 0, 1, 0, 1, 0, 1],
        'o': [1, 1, 1, 1, 1, 1, 0],
        'p': [1, 1, 0, 0, 1, 1, 1],
        'q': [1, 1, 1, 0, 0, 1, 1],
        'r': [0, 0, 0, 0, 1, 0, 1],
        's': [1, 0, 1, 1, 0, 1, 1],
        't': [0, 0, 0, 1, 1, 1, 1],
        'u': [0, 1, 1, 1, 1, 1, 0],
        'v': [0, 0, 1, 1, 1, 0, 0],
        'w': [0, 1, 0, 1, 0, 1, 0],
        'x': [0, 1, 1, 0, 1, 1, 1],
        'y': [0, 1, 1, 1, 0, 1, 1],
        'z': [1, 1, 0, 1, 1, 0, 1],
        
        ' ': [0, 0, 0, 0, 0, 0, 0],
        '_': [0, 0, 0, 1, 0, 0, 0],
        '-': [0, 0, 0, 0, 0, 0, 1],
        ',': [0, 0, 1, 0, 0, 0, 0]

    };
    
    for (var i = 0; i < string.length; i++)
    {
        segment7draw(x, y, w, 2*w, characterMap[string[i]]);
        x += (w+textspace);
    }
}