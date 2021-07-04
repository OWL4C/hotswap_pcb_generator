include <parameters.scad>
include <utils.scad>

socket_length = trrs_length+4;
socket_width = trrs_width+4;
    

module wire_channel(length=pcb_thickness) {
    translate([0,0,-1]) cylinder(d=wire_diameter+.1,h=length+2);
}

module trrs(borders=[0,0,0,0]) {
    translate([h_unit/2,-socket_length,0])
        rotate([0,layout_type == "row"?180:0,0])
            translate([-socket_width/2,0,-pcb_thickness/2])
                uxcell_trrs(invert_borders(borders,layout_type == "row"));
}

module uxcell_trrs(borders=[0,0,0,0]) {
    difference() {
        union() {
            // Socket Base
            cube([socket_width,socket_length,pcb_thickness-2+trrs_flange_diameter*2/3]);
            translate([
                socket_width/2,
                socket_length-trrs_flange_length,
                pcb_thickness-2+trrs_flange_diameter/2
            ]) rotate([-90,0,0]) intersection() {
                cylinder(d=trrs_flange_diameter+2,trrs_flange_length);
                translate([0,0,trrs_flange_length/2]) 
                    cube([trrs_flange_diameter+2,trrs_flange_diameter/3,trrs_flange_length],center=true);
            }
            
            // Borders
            translate([socket_width/2,socket_length-v_unit/2,pcb_thickness/2-1])
                border(
                    [h_unit,v_unit], 
                    borders, 
                    pcb_thickness-2
                );
        }
        // Socket Cutout
        translate([4-trrs_flange_length,2,pcb_thickness-2]) 
            cube([trrs_width,trrs_length,trrs_height]);
        // Flange Cutout
        translate([
            socket_width/2,
            socket_length-1-trrs_flange_length,
            pcb_thickness-2+trrs_flange_diameter/2
        ]) rotate([-90,0,0]) 
            cylinder(d=trrs_flange_diameter,h=trrs_flange_length+2);
        
        // Wire Channels
        translate([(trrs_width-trrs_pin_spacing)/2+2,4-trrs_flange_length+0.5,0]) 
            wire_channel(pcb_thickness+trrs_height-3);
        for (y=[1.8,5.8,9.1]) {
            translate([(trrs_width+trrs_pin_spacing)/2+2,4-trrs_flange_length+y,0]) 
                wire_channel(pcb_thickness+trrs_height-3);
        }
        
        // Locating Pins
        for (y=[trrs_length-trrs_nub_offset,trrs_length-trrs_nub_offset-trrs_nub_spacing]) {
            translate([socket_width/2,4-trrs_flange_length+y,pcb_thickness-2-trrs_nub_height])
                cylinder(d=trrs_nub_diameter,h=pcb_thickness);
        }
    }
}

module trrs_plate_base(borders=[0,0,0,0], thickness=plate_thickness) {
    translate([h_unit/2,-v_unit/2,0])
        border(
            [h_unit,v_unit], 
            borders, 
            thickness
        );
}

module trrs_plate_cutout(thickness=plate_thickness) {
    if (switch_type == "mx") {
        // MX spacing is sufficient to fit the TRRS socket with no cutout
    } else if (switch_type == "choc") {
        translate([h_unit/2,-socket_length/2])
                border(
                    [socket_width,socket_length], 
                    [1000,0,0,0], 
                    thickness+1
                );
    } else {
        assert(false, "switch_type is invalid");
    }
}

trrs();
