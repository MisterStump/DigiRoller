// Digi Dice Roller - by MrStump
/*
Notes:
- Assuming you are looking head-on to the screen, then measurements are always:
    - x = left/right on screen
    - y = up/down on screen
    - z = the screen down to the battery back
- There are 3 models mentioned
    - Top Section = the upper body piece that includes the face
    - Bottom Section = the lower body piece that has the USB opening
    - Joystick = the little joystick nub that fits onto the 5-way switch
- Looking at the side, the module sections are:
    - ScreenSection = the screen all the way down to the UPS board
    - UPSSection = the battery board only, no pin sections
    - PicoSection = Everything below the UPS board, including the pin section
- The modules are oddly sided:
    - ScreenSection is larger in the Y than any other section
    - UPSSection is larger in the X than any other section
- The general layout of the code is:
    - Logic section determined what will be built and calls the Create module to make it
    - Create generates a whole printable piece using 1 or more Parts
    - Parts are individual fascets/conceptual elements of a model
*/


/////////////////////////////////////////////
// Parameters - things to modify to easilly change the model
/////////////////////////////////////////////

/* [General] */
//What part to print
Printed_Part = "All"; //[Top Section, Bottom Section, Joystick, All, Demo]
//How thick the face is. Impact look, as well as how stiff/flimsy buttons are
Face_Thickness = 0.6;
//How thickness of the thinnest part of walls
Wall_Thickness = 2;

/* [Tolerance offset so printed parts fit better] */
//How much X (left/right) to remove for the fitted parts
X_Tollerance = 0.3;
//How much Y (top of screen/bottom of screen) to remove for the fitted parts
Y_Tollerance = 0.3;
//How much Z (screen to back of case) to remove for the fitted parts
Z_Tollerance = 0.15;










//Prevents anything below this point showing in customizer
module customizerStop(){} customizerStop();


/////////////////////////////////////////////
// Hard-coded parameters - things to modify that are calculated or more delicate
/////////////////////////////////////////////

//Epsilon, prevent exact surface overlap during cutouts
eps = 0.007;
//Level of detail on rounded edges
$fn = 32;

//Measurements for the ScreenSection
//Circuit board measurements
ScreenSection_board_x = 52.25 + X_Tollerance;
ScreenSection_board_y = 26.52 + Y_Tollerance;
ScreenSection_board_z = 4.3;
//Pins (black plastic bit that connects ScreenSection to UPSSection)
ScreenSection_pins_x = 52.25 + X_Tollerance;
ScreenSection_pins_y = 20.15 + Y_Tollerance;
ScreenSection_pins_z = 9.8 - 0.45;

//Measurements for the UPSSection
//UPS board measurements (board only, not even counting circuits sticking up)
UPSSection_x = 63 + X_Tollerance;
UPSSection_y = 20.15 + Y_Tollerance;
UPSSection_z = 1.6 + Z_Tollerance;

//Max dimensions of interior space (where pico sits)
interiorMax_x = UPSSection_x;
interiorMax_y = ScreenSection_board_y;

//Measurements for the PicoSection
//Circuit board and circuits
PicoSection_board_x = 52.25 + X_Tollerance;
PicoSection_board_y = 20.95 + Y_Tollerance;
PicoSection_board_z = 2.8; //was 3.5
//Pins (black plastic bit that connects UPSSection to PicoSection)
PicoSection_pins_x = 52.25 + X_Tollerance;
PicoSection_pins_y = 20.95 + Y_Tollerance;
PicoSection_pins_z = 11.25;
//Amount above pins that the USB port is in the z
PicoSection_usb = 5.5; //THIS MAY BE WRONG
//Amount of upen air above the circuity
PicoSection_airGap_x = UPSSection_x;
PicoSection_airGap_y = 13; //in the center, this is the air space left
PicoSection_airGap_z = PicoSection_usb - PicoSection_board_z;

//UPS and Screen are not centered on the X. This is the additional excess
UPStoSCREEN_left = 6.11;
UPStoSCREEN_right = 4.88;
//Offset of Screen-To-UPS (it isn't quite centered on the X)
ScreenToUPSOffset_x = UPStoSCREEN_left - UPStoSCREEN_right - 0.6 + 0.2;

//Measurements of screen cutout
screenCut_x = 23.4 + X_Tollerance/2;
screenCut_y = 23.4 + Y_Tollerance/2;

//Measurements of joystick cutout
joyCut_x = 4 + X_Tollerance;
joyCut_y = 4 + Y_Tollerance;
//Distance from edge/center the joystick is positioned
joyCutDistance_fromEdge = 6.5;
joyCutDistance_fromCenter = ScreenSection_board_x/2 - joyCutDistance_fromEdge;

//Buttons X (y defined below)
button_x = 10;

//Space between each button
buttonCutWidth = 0.5;
//Measurements for buttons
buttonSecontion_x = button_x+buttonCutWidth;
buttonSecontion_y = ScreenSection_board_y;
//Distance from edge/center for the button positions
buttonSection_fromEdge = 4;
buttonSection_fromCenter = UPSSection_x/2 - buttonSecontion_x/2 - buttonSection_fromEdge;

//Button Y (x define above)
button_y = (buttonSecontion_y - (buttonCutWidth*5)) / 4;

//Joystick padding shape (to screen board, not UPS board)
joyPad_x = 8;
joyPad_y = 5;
joyPad_z = 2.5;

//Screen padding shape
screenPad_width = (ScreenSection_board_y - screenCut_y);
screenPad_x = screenCut_x + screenPad_width;
screenPad_y = screenCut_y + screenPad_width; 
screenPad_z = 0.5;

//Top section's walls, not including part that fits to bottom section
//X and Y don't include wall thickness
topWalls_x = UPSSection_x;
topWalls_y = ScreenSection_board_y;
topWalls_z = Face_Thickness + ScreenSection_board_z + ScreenSection_pins_z + UPSSection_z;

//Power switch cutouts (there are 2, 1 for switch and 1 for reset button)
switchCutout_insetFromSide = 4;
switchCutout_x = Wall_Thickness;
switchCutout_y = 7;
switchCutout_z = 6;

//Top iece Lip that connects to bottom piece's lip
topLip_x = topWalls_x;
topLip_y = topWalls_y;
topLip_z = 4;
topLip_thickness = Wall_Thickness/2;

//PicoSection's wall measurements (x and y doesn't include wallThickness)
botWalls_x = UPSSection_x;
botWalls_y = ScreenSection_board_y;
botWalls_z = Wall_Thickness + PicoSection_airGap_z + PicoSection_board_z + PicoSection_pins_z;

//Cutout for USB
usbCutout_x = Wall_Thickness + UPStoSCREEN_left;
usbCutout_y = 12;
usbCutout_z = Wall_Thickness + PicoSection_usb + 2;

//Bottom section lip that fits to top section lip to close case
//This is a cutout, while the top section's is addative
botLip_x = botWalls_x + Wall_Thickness; //removed x_tolerance due to looseness
botLip_y = botWalls_y + Wall_Thickness; //removed y_tolerance due to looseness
botLip_z = 4 - Z_Tollerance;

//Joystick wall/thumbpad thickness thickness
joy_thickness = 1;
//Joystick connector (inner dimensions)
//Tolerance is halved to get a tight fit
joyCon_x = 1.9 + X_Tollerance/2;
joyCon_y = 1.9 + Y_Tollerance/2;
joyCon_z = 1.7 + Z_Tollerance;
//Joystick thumbpad
joyPad_d = 6;

//Thickness of walls of connector for power switch and thickness of switch
power_thickness = 1;
//Power switch connector (inner dimensions)
//XYZ are oriented as if you are looking down at the switch, instead of the screen)
powerConnector_x = 1.52 + X_Tollerance/2;
powerConnector_y = 0.62 + Y_Tollerance/2;
powerConnector_z = 3.95 - power_thickness;
//Power switch botton (surface to grab)
powerSwitch_x = powerConnector_x + power_thickness*2;
powerSwitch_y = 5.8;
powerSwitch_z = power_thickness;



/////////////////////////////////////////////
// Logic - logic that determines what is made
/////////////////////////////////////////////

if (Printed_Part == "Top Section"){
    create_topSection();
}

else if (Printed_Part == "Bottom Section"){
    create_bottomSection();
}

else if (Printed_Part == "Joystick"){
    create_joystick();
}

else if (Printed_Part == "All"){
    yOffset = interiorMax_y/2 + Wall_Thickness*2;
    translate([0,yOffset,0])
    create_topSection();
    
    translate([0,-yOffset,0])
    create_bottomSection();
    
    translate([0,yOffset,0])
    create_joystick();
}

else if (Printed_Part == "Demo"){
    bottomToTop = botWalls_z+ScreenSection_board_z+ScreenSection_pins_z+UPSSection_z+Face_Thickness+0.1;
    translate([0,0,bottomToTop])
    rotate([180,0,0])
    create_topSection();
    
    translate([0,0,0])
    create_bottomSection();
    
    xOffset = -joyCutDistance_fromCenter+ScreenToUPSOffset_x;
    zOffset = bottomToTop + joy_thickness + joyCon_z;
    translate([xOffset,0,zOffset])
    rotate([180,0,0])
    create_joystick();
}







/////////////////////////////////////////////
// Create - Generate a whole piece of model
/////////////////////////////////////////////

//Create top section of model
module create_topSection(){
    union(){
        part_face();
        part_face_wallPad("left");
        part_face_wallPad("right");
        part_face_joyPads();
        part_face_screenPad();
        part_topSection_walls();
        part_topSection_lip();
    }
}

//Creates bottom section piece
module create_bottomSection(){
    union(){
        difference(){
            union(){
                part_buttomSection_walls();
                part_bottom_plate();
                part_bottom_airgapPad();
                part_bottom_wallPad("left");
                part_bottom_wallPad("right");
            }
            part_bottom_usbCut();
            part_bottom_lipCut();
        }
    }
}

//creates little cover for joystick
module create_joystick(){
    union(){
        translate([0,0,joy_thickness])
        part_joypad_connector();
        part_joypad_thumbpad();
    }
}

//Creates little cover for power switch
//I neded up not using this cause the power switch is too flimsy
module create_powerSwitch(){
    part_powerSwitch_switch();
    translate([0,0,powerSwitch_z])
    part_powerSwitch_connector();
}




/////////////////////////////////////////////
// Parts - Elements of the models
/////////////////////////////////////////////

// Cutout for screen
module part_face_cutout_screen(){
    xSize = screenCut_x;
    ySize = screenCut_y;
    zSize = Face_Thickness + screenPad_z + eps;
    
    //No X/Y positioning needed, screen is centered on Pi
    translate([0,0,-eps/2])
    linear_extrude(zSize)
    square([xSize, ySize], center=true);
}


// Cutout for joystick
module part_face_cutout_joystick(){
    xSize = joyCut_x;
    ySize = joyCut_y;
    zSize = Face_Thickness+eps;
    
    xPos = -( joyCutDistance_fromCenter );
    yPos = 0;
    zPos = -eps/2;
    
    translate([xPos,yPos,zPos])
    //cylinder(topWallThickness+eps, d=joy_d);
    linear_extrude(zSize)
    square([xSize,ySize], center=true);
}


// Cutout the area where buttons will go
module part_face_cutout_buttonArea(){
    xSize = buttonSecontion_x;
    ySize = buttonSecontion_y + eps;
    zSize = Face_Thickness + eps;
    
    xPos = buttonSection_fromCenter;
    yPos = 0;
    zPos = -eps/2;
    
    translate([xPos, yPos, zPos])
    linear_extrude(zSize)
    square([xSize+eps,ySize], center=true);
}

//Button creation/placement
module part_face_buttons(){
    xSize = button_x;
    ySize = button_y;
    zSize = Face_Thickness;

    //Loop that creates the buttons
    startPosY = -(buttonSecontion_y/2 - buttonCutWidth);
    for (i=[0:3]){
        xPos = buttonSection_fromCenter - xSize/2 + buttonCutWidth/2;
        yPos = startPosY + ((button_y+buttonCutWidth) * i);
        zPos = 0;
        
        translate([xPos,yPos,zPos])
        linear_extrude(zSize)
        square([xSize,ySize]);
    }
}

//Face surface (top surface of model)
module part_face_surface(){
    xSize = UPSSection_x;
    ySize = ScreenSection_board_y;
    zSize = Face_Thickness;
    
    linear_extrude(zSize)
    square([xSize, ySize], center=true);
}

//Create the face with all of its cutouts, not including the exterior wall parts
module part_face(){
    //Translate offset the x of the cutouts a bit since the screen is not eventer over UPS
    difference(){
        part_face_surface();
        translate([ScreenToUPSOffset_x,0,0]){
            part_face_cutout_screen();
            part_face_cutout_joystick();
            part_face_cutout_buttonArea();
        }
    }
    translate([ScreenToUPSOffset_x,0,0])
    part_face_buttons();
}

//Padding around the X sides of the walls, meant to fit snugly around screen's board
//Takes "left" or "right". Well, technically anything but "left" will be right
module part_face_wallPad(side){
    xSize = side == "left" ? UPStoSCREEN_left : UPStoSCREEN_right;
    ySize = ScreenSection_board_y;
    zSize = ScreenSection_board_z + Face_Thickness;
    
    xSideFlip = side == "left" ? 1 : -1;
    xPos = (xSize/2 - UPSSection_x/2) * xSideFlip;
    yPos = 0;
    zPos = 0;
    
    translate([xPos,yPos,zPos])
    linear_extrude(zSize)
    square([xSize,ySize],center=true);
}

//Padding around the joystick
module part_face_joyPads(){
    xSize = joyPad_x;
    ySize = joyPad_y;
    zSize = joyPad_z + Face_Thickness;
    
    xPos = xSize/2 - UPSSection_x/2 + UPStoSCREEN_left;
    yPos = ySize/2 - ScreenSection_board_y/2;
    zPos = 0;
    
    //pad 1
    translate([xPos,yPos,zPos])
    linear_extrude(zSize)
    square([xSize,ySize],center=true);
    //pad 2
    translate([xPos,-yPos,zPos])
    linear_extrude(zSize)
    square([xSize,ySize],center=true);
}

//Padding around the screen
module part_face_screenPad(){
    xSize = screenPad_x;
    ySize = screenPad_y;
    zSize = screenPad_z + Face_Thickness;
    
    xPos = ScreenToUPSOffset_x;
    yPos = 0;
    zPos = 0;
    
    translate([xPos,yPos,zPos])
    difference(){
        //screen padding
        linear_extrude(zSize)
        square([xSize,ySize],center=true);
        //cutout of screen
        part_face_cutout_screen();
    }
}

//Wall section that fits to the base piece
module part_topSection_walls(){
    xSize = topWalls_x;
    ySize = topWalls_y;
    zSize = topWalls_z;

    difference(){
        //Outer wall area
        linear_extrude(zSize)
        square([xSize+Wall_Thickness*2, ySize+Wall_Thickness*2],center=true);
        //Cutout for where device goes
        translate([0,0,-eps/2])
        linear_extrude(zSize+eps)
        square([xSize,ySize], center=true);
        //Cutout for switches on UPS board
        part_topSection_switchCut("left");
        *part_topSection_switchCut("right");
    }
}

//Cutouts for button and switch on UPS, which are cut out of top section
module part_topSection_switchCut(side){
    xSize = switchCutout_x + eps;
    ySize = switchCutout_y;
    zSize = switchCutout_z + eps;
    
    posFlip = side == "left" ? 1 : -1;
    xPos = -(xSize/2 - topWalls_x/2 - Wall_Thickness - eps/2);
    yPos = (ySize/2 - topWalls_y/2 + switchCutout_insetFromSide) * posFlip;
    zPos = topWalls_z - zSize + eps;
    
    translate([xPos, yPos, zPos])
    linear_extrude(zSize)
    square([xSize, ySize], center=true);
}

//Create the lip that holds the top and bottom sections togther
module part_topSection_lip(){
    xSize = topLip_x;
    ySize = topLip_y;
    zSize = topLip_z;
    
    xPos = 0;
    yPos = 0;
    zPos = topWalls_z;
    
    translate([xPos,yPos,zPos])
    difference(){
        //Outer wall area
        linear_extrude(zSize)
        square([xSize+topLip_thickness*2, ySize+topLip_thickness*2],center=true);
        
        //Cutout for where device goes
        translate([0,0,-eps/2])
        linear_extrude(zSize+eps)
        square([xSize,ySize], center=true);
        
        //Cutout so there is no lip over the swlitch ports (port)
        xSize_ports = topLip_thickness + eps;
        ySize_ports = switchCutout_y;
        xPos_ports = xSize_ports/2 + topWalls_x/2 - eps/2;
        yPos_ports = ySize_ports/2 - topWalls_y/2 + switchCutout_insetFromSide;
        zPos_ports = -eps/2;
        translate([xPos_ports,yPos_ports,zPos_ports])
        linear_extrude(zSize+eps)
        square([xSize_ports,ySize_ports], center=true);
    }
}



//Create bottom plate of the model
module part_bottom_plate(){
    xSize = botWalls_x;
    ySize = botWalls_y;
    zSize = Wall_Thickness;
    
    difference(){
        //Plate
        linear_extrude(zSize)
        square([xSize, ySize], center=true);
        //Vent cutouts
        
    }
}

//Create walls of the bottom section
module part_buttomSection_walls(){
    xSize = botWalls_x;
    ySize = botWalls_y;
    zSize = botWalls_z;

    difference(){
        //Wall
        linear_extrude(zSize)
        square([xSize + Wall_Thickness*2, ySize + Wall_Thickness*2], center=true);
        
        //Inner cutout where pico goes
        translate([0,0,-eps/2])
        linear_extrude(zSize+eps)
        square([xSize, ySize], center=true);
    }
}

//Place the airgap pads to hold up the board so it doesn't rest on its bios button
module part_bottom_airgapPad(){
    plate_xSize = botWalls_x;
    plate_ySize = botWalls_y;
    plate_zSize = PicoSection_airGap_z;
    
    airgap_xSize = botWalls_x + eps;
    airgap_ySize = PicoSection_airGap_y;
    airgap_zSize = PicoSection_airGap_z + eps;
    
    zPos = Wall_Thickness;
    
    translate([0,0,zPos])
    difference(){
        //airgap plate
        linear_extrude(plate_zSize)
        square([plate_xSize, plate_ySize], center=true);
        
        //cutout for the air
        translate([0,0,-eps/2])
        linear_extrude(airgap_zSize)
        square([airgap_xSize, airgap_ySize], center=true);
    }
}


//Cutout for vents on bottom plate
module part_bottom_plate_ventCut(){
    
}

module part_bottom_usbCut(){
    xSize = usbCutout_x+eps;
    ySize = usbCutout_y;
    zSize = usbCutout_z + eps;

    xPos = xSize/2 - interiorMax_x/2 - Wall_Thickness - eps/2;
    yPos = 0;
    zPos = -eps;
    
    translate([xPos, yPos, zPos])
    linear_extrude(zSize)
    square([xSize, ySize], center=true);
}

//Padding around the X sides of the walls, meant to fit snugly around pico's board
//Takes "left" or "right". Well, technically anything but "left" will be right
module part_bottom_wallPad(side){
    xSize = side == "left" ? UPStoSCREEN_left : UPStoSCREEN_right;
    ySize = botWalls_y;
    zSize = PicoSection_usb + Face_Thickness;
    
    xSideFlip = side == "left" ? 1 : -1;
    xPos = (xSize/2 - UPSSection_x/2) * xSideFlip;
    yPos = 0;
    zPos = 0;
    
    translate([xPos,yPos,zPos])
    linear_extrude(zSize)
    square([xSize,ySize],center=true);
}

//Cutout that makes the lip that fits to the top's lip
module part_bottom_lipCut(){
    xSize = botLip_x;
    ySize = botLip_y;
    zSize = botLip_z+eps;

    xPos = 0;
    yPos = 0;
    zPos = -botLip_z + botWalls_z + eps;
    
    translate([xPos, yPos, zPos])
    linear_extrude(zSize)
    square([xSize, ySize], center=true);
}

//Joystick's connector that fits onto the joystick nub of the screen
module part_joypad_connector(){
    xSize_inner = joyCon_x;
    ySize_inner = joyCon_y;
    zSize_inner = joyCon_z + eps;
    
    xSize_outer = joyCon_x + joy_thickness*2;
    ySize_outer = joyCon_y + joy_thickness*2;
    zSize_outer = joyCon_z;
    
    difference(){
        //outer
        linear_extrude(zSize_outer)
        square([xSize_outer, ySize_outer], center=true);
        
        //inner
        translate([0,0,-eps/2])
        linear_extrude(zSize_inner)
        square([xSize_inner, ySize_inner], center=true);
    }
}

//Joystick thumbpad
module part_joypad_thumbpad(){
    diameter = joyPad_d;
    height = joy_thickness;
    
    cylinder(d=diameter, h=height);
}

//Connector that fits around the little power toggle on the UPS
module part_powerSwitch_connector(){
    xSize_inner = powerConnector_x;
    ySize_inner = powerConnector_y;
    zSize_inner = powerConnector_z;
    
    xSize_outer = powerConnector_x + power_thickness*2;
    ySize_outer = powerConnector_y + power_thickness*2;
    zSize_outer = powerConnector_x + eps;
    
    difference(){
        //outer
        linear_extrude(zSize_outer)
        square([xSize_outer,ySize_outer], center=true);
        //inner
        translate([0,0,-eps/2])
        linear_extrude(zSize_inner)
        square([xSize_inner,ySize_inner], center=true);
    }
}

//Create part of switch that is touched to toggle on/off
module part_powerSwitch_switch(){
    xSize = powerSwitch_x;
    ySize = powerSwitch_y;
    zSize = powerSwitch_z;
    
    linear_extrude(zSize)
    square([xSize, ySize], center=true);
}





















