/* [PCB Properties] */
// Diameter of row/column wire channels
wire_diameter = 2.15;
// Upward angle of switch pin in contact with diode anode (gives more reliable connections but slightly deforms pin)
diode_pin_angle = 5;  // [0:15]
// Diameter of standoff hole
standoff_hole_diameter = 3;
// Overall thickness of PCB
thickness = 4;

/* [Layout Values] */
// Layout (Format is [[[x_location, y_location], [rotation, rotation_x, rotation_y]], [key_size, [top_border, bottom_border, left_border, right_border], rotate_column]])
layout = [
    [[[0,0.125]],[1,[0,1,0,2],false]],
    [[[0,1.125]],[1,[1,1,0,1],false]],
    [[[0,2.125]],[1,[1,1,0,1],false]],
    [[[0,3.125]],[1,[1,0,0,0],false]],
    [[[1,0]],[1,[0,1,0,0],false]],
    [[[1,1]]],
    [[[1,2]]],
    [[[1,3]],[1,[1,0,2,2],false]],
    [[[2,0.125]],[1,[0,1,2,2],false]],
    [[[2,1.125]]],
    [[[2,2.125]]],
    [[[2,3.125]],[1,[1,0,0,0],false]],
    [[[3,0]],[1,[0,1,0,0],false]],
    [[[3,1]]],
    [[[3,2]]],
    [[[3,3]],[1,[1,0,2,2],false]],
    [[[4,0.125]],[1,[0,1,2,0],false]],
    [[[4,1.125]]],
    [[[4,2.125]]],
    [[[4,3.125]],[1,[1,0,0,0],false]],
    [[[5,0.25]],[1,[0,1,2,0],false]],
    [[[5,1.25]]],
    [[[5,2.25]],[1,[1,6,2,0],false]],
    [[[6,1]],[1,[0,1,2,0],false]],
    [[[6,2]],[1,[1,0,2,0],false]],
    [[[4.875,4.625],[60,4.875,4.625]],[1.5,[6,1,0,0],true]],
    [[[4.875,5.625],[60,4.875,4.625]],[1.5,[1,0,0,0],true]],
];

// Standoff hole layout
hole_layout = [
    [[[0,1.625]]],
    [[[2.5,0]]],
    [[[2.5,3.125]]],
    [[[3,1.5]]],
    [[[6,1.5]]],
    [[[4.875,5.125],[60,4.875,4.625]],[1.5,[0,0,0,0],true]],
];

// Whether to flip the layout
invert_layout_flag = false;

layout_final = invert_layout_flag ? invert_layout(layout) : layout;
hole_layout_final = invert_layout_flag ? invert_layout(hole_layout) : hole_layout;


/* [Advanced Values (related to switch size)] */
// Switch spacing distance
unit = 19.05;
// Size of socket body
socket_size = 14; 
// Depth of the socket holes
socket_depth = 3.5;
// Spacing of grid for pins
grid = 1.27;
// Resolution of holes (affects render times)
$fn=12;
// Thickness of a border unit around the socket (for joining adjacent sockets)
border_width = (unit - socket_size)/2;

module __Customizer_Limit__ () {}

function invert_layout(layout) = [
    for(key = layout) 
        let(
            location = len(key[0]) == 2 ? key[0] : [key[0][0],[0,0,0,0]],
            shape = len(key) == 2 ? key[1] : [1,[1,1,1,1],false]
        )
            [
                [
                    [-location[0][0]-shape[0], location[0][1]],
                    [-location[1][0], -location[1][1], location[1][2]]],
                [
                    shape[0],
                    [shape[1][0], shape[1][1], shape[1][3], shape[1][2]],
                    shape[2]
                ]
        ]
    
];

module key_socket(borders=[1,1,1,1], rotate_column=false) {
    difference() {
        key_socket_base(borders);
        key_socket_cutouts(borders, rotate_column);
    }
}

module key_socket_base(borders=[1,1,1,1]) {
    translate([unit/2,-unit/2,0]) union() {
        cube([socket_size, socket_size, thickness], center=true);
        translate([
            border_width/2 * (borders[3] - borders[2]),
            border_width/2 * (borders[0] - borders[1]),
            -1
        ]) {
            cube([
                socket_size+border_width*(borders[2]+borders[3])+0.001, 
                socket_size+border_width*(borders[0]+borders[1])+0.001, 
                thickness-2
            ], center=true);
        }
    }
}

module key_socket_cutouts(borders=[1,1,1,1], rotate_column=false) {
    render() translate([unit/2,-unit/2,0]) intersection() {
        union() {
            translate([0,0,thickness/2-socket_depth]) 
                cylinder(h=thickness+1,r=2.1);
            for (x = [-4,4]) {
                translate([x*grid,0,thickness/2-socket_depth]) 
                    cylinder(h=thickness+1,r=1.05);
            }
            translate([2*grid,4*grid,thickness/2-socket_depth]) 
                cylinder(h=thickness+1,r=1);
            translate([-3*grid,2*grid,(thickness+1)/2]) 
                rotate([180+diode_pin_angle,0,0]) 
                    cylinder(h=thickness+1,r=.7);
            translate([3*grid,-4*grid,0]) 
                cylinder(h=thickness+1,r=.7,center=true);
            
            // Wire Channels
            translate([0,4*grid,thickness/2-wire_diameter/3]) rotate([0,90,0]) 
                cylinder(h=unit+1,d=wire_diameter,center=true);
            if (rotate_column) {
                translate([3*grid,-4*grid,-(thickness/2-wire_diameter/3)]) rotate([90,0,90]) 
                    cylinder(h=100+1,d=wire_diameter,center=true);
            } else {
                translate([3*grid,-4*grid,-(thickness/2-wire_diameter/3)]) rotate([90,0,0]) 
                    cylinder(h=100+1,d=wire_diameter,center=true);
            }
            
            // Diode Channel
            translate([-3*grid,-1*grid-.25,thickness/2]) 
                cube([1,6*grid+.5,2],center=true);
            translate([0,-4*grid,thickness/2]) 
                cube([6*grid,1,2],center=true);
            translate([-1*grid-.5,-4*grid,thickness/2]) 
                cube([4*grid,2,3],center=true);
        }
        
        translate([
            border_width/2 * (borders[3] - borders[2]),
            border_width/2 * (borders[0] - borders[1]),
            -1
        ]) {
            cube([
                socket_size+border_width*(borders[2]+borders[3]+2)+0.002, 
                socket_size+border_width*(borders[0]+borders[1]+2)+0.002, 
                2*thickness
            ], center=true);
        }
    }
}

module standoff_hole() {
    translate([unit/2,-unit/2,0]) cylinder(h=thickness+1,d=standoff_hole_diameter,center=true);
}

module layout_pattern(layout) {
    union() {
        for (param = layout) {
            // Setting defaults
            location = len(param[0]) == 2 ? param[0] : [param[0][0],[0,0,0,0]];
            shape = len(param) == 2 ? param[1] : [1,[1,1,1,1],false];
            
            switch_offset = (shape[0]-1)/2;
            
            translate([location[1][1]*unit,-location[1][2]*unit,0]) {
                rotate([0,0,location[1][0]]) {
                    translate([(location[0][0]-location[1][1]+switch_offset)*unit,
                               (location[1][2]-location[0][1])*unit,
                               0]) {
                        $borders = shape[1];
                        $rotate_column = shape[2];
                        children();
                    }
                }
            }
        }
    }
}

difference() {
    layout_pattern(layout_final) { 
        key_socket_base($borders);
    }
    layout_pattern(layout_final) { 
        key_socket_cutouts($borders, $rotate_column);
    }
    layout_pattern(hole_layout_final) { 
        standoff_hole();
    }
}