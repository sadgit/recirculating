include <recirculating_mw.scad>
difference() {
    recirc_half(6.0);
    translate([0, -20, 0]) cube([40, 40, 40], center=true);
    translate([-20, 0, 0]) cube([40, 60, 40], center=true);
}

/* translate([29, 0, 0]) rotate([0,0,180]) % half(6);
// extrusion
xwid = 15;
translate([xwid/2, -50, -xwid/2]) 
   % cube([15, 100, 15]);
// carriage plate
translate([15,0,-thickness+slot])
   % recirc_plate(14.5);
 */
