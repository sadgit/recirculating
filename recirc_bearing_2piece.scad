include <recirculating_mw.scad>
recirc_half();
translate([20, 0, 0]) inner_half();

//
//translate([29, 0, 0]) rotate([0,0,180]) % recirc_half();
//
//// extrusion
//xwid = 15;
//translate([xwid/2, -50, -xwid/2]) 
//    % cube([15, 100, 15]);
//
//// carriage plate
//translate([15,0,-thickness+slot])
//    % recirc_plate(14.5);
//
