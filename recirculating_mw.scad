//include </home/markw/Dropbox/3Dmodels/MCAD/nuts_and_bolts.scad>

length = 50;
thickness = 11;
channel_radius = 3;
track_radius = 6;
outside_radius = channel_radius + track_radius + 1.5;
slot = 2.5;

module track(h) {
  union() {
    translate([0, outside_radius-length/2, 0]) intersection() {
      rotate_extrude($fn=24) translate([track_radius, 0, 0])
        circle(r=channel_radius, $fn=6);
      translate([0, -20, 0]) cube([40, 40, 40], center=true);
    }
    translate([0, length/2-outside_radius, 0]) intersection() {
      rotate_extrude($fn=24) translate([track_radius, 0, 0])
        circle(r=channel_radius, $fn=6);
      translate([0, 20, 0]) cube([40, 40, 40], center=true);
    }
    for (s = [-1, 1]) {
      scale([s, 1, 1])
        translate([track_radius, 0, 0]) rotate([90, 0, 0]) {
          cylinder(r=channel_radius,
                   h=length-2*outside_radius+0.1,
                   center=true, $fn=6);
          translate([0, 2, 0]) #
            cylinder(r=channel_radius*0.61,
                     h=length-2*outside_radius+0.1,
                     center=true, $fn=6);
      }
    }
  }
}

module half() {
  difference() {
    translate([0, 0, slot/2-thickness+1.3])
    linear_extrude(height=30, convexity=2) {
      difference() {
        translate([-0.5, 0, 0]) minkowski() {
          square([0.1, 0.1+length-2*outside_radius], center=true);
          circle(r=outside_radius-0.05, $fn=36);
        }
        for (y = [2+outside_radius-length/2,
                  length/2-outside_radius-2]) {
          translate([0, y])
            circle(r=1.5, $fn=12);
        }
      }
    }
    track();
    translate([-10.5, 0, 12.5])
      cube([100, 100, 20], center=true);
    translate([0, 0, 10]) rotate([0, -90, 0]) {
      rotate([0, 0, 90]) cylinder(r=3.2, h=50, $fn=6);
      cylinder(r=1.7, h=50, center=true, $fn=12);
    }
    translate([10+track_radius, 0, -10-slot/2])
      cube([20, length, 20], center=true);
    translate([10+track_radius, 0, 10+slot/2])
      cube([20, length, 20], center=true);
    // recesses for bolt heads
    assign(bhr = 1)
    for (y = [2+outside_radius-length/2,
              length/2-outside_radius-2]) {
      translate([0, y, 3-bhr])
        cylinder(r=3.1, h=bhr, $fn=36);
    }
  }
}

channelHeight = -1 + 2 * channel_radius;
cutDepth = 1;

module inner_half() {
    translate([0, 0, -5])
    intersection() {
        half();
        // remove inner part of track to eliminate travel moves
        translate([0, 0, -cutDepth/2])
          cube([10, 38, channelHeight+cutDepth], center=true);
    }
}

module outer_half() {
  difference() {
    translate([0, 0, slot/2-thickness+1.3])
    linear_extrude(height=30, convexity=2) {
      difference() {
        translate([-0.5, 0, 0]) minkowski() {
          square([0.1, 0.1+length-2*outside_radius], center=true);
          circle(r=outside_radius-0.05, $fn=36);
        }
        for (y = [2+outside_radius-length/2,
                  length/2-outside_radius-2]) {
          translate([0, y])
            circle(r=1.5, $fn=12);
        }
      }
    }
    track();

    // remove inner part of track to eliminate travel moves
    translate([0, 0, -cutDepth/2])
      cube([10, 38, channelHeight+cutDepth], center=true);
      
    translate([-10.5, 0, 12.5])
      cube([100, 100, 20], center=true);
    translate([0, 0, 10]) rotate([0, -90, 0]) {
      rotate([0, 0, 90]) cylinder(r=3.2, h=50, $fn=6);
      cylinder(r=1.7, h=50, center=true, $fn=12);
    }
    translate([10+track_radius, 0, -10-slot/2])
      cube([20, length, 20], center=true);
    translate([10+track_radius, 0, 10+slot/2])
      cube([20, length, 20], center=true);
    // recesses for bolt heads
    assign(bhr = 1)
    for (y = [2+outside_radius-length/2,
              length/2-outside_radius-2]) {
      translate([0, y, 3-bhr])
        cylinder(r=3.1, h=bhr, $fn=36);
    }
  }
}

module recirc_plate(bearing_offset, recess=0.5) {
    width = 42;
    height = 42;
    thickness = 12;
    sdepth = 9;
    slotwidth = 1;
    soffset = (bearing_offset-10)/2;
    tdepth = .4 * sdepth;
    tol = 0.25;
    cutout = 10;
    difference() {
        // locate top face of plate at z=0
        translate([0,0,-thickness/2])
            cube([width, height, thickness], center=true);
        // cut slots for tensioning adjustment
        translate([bearing_offset-soffset,0,-sdepth/2])
            cube([slotwidth, height, sdepth], center=true);
        translate([-bearing_offset+soffset,0,-sdepth/2])
            cube([slotwidth, height, sdepth], center=true);
        // shave recess off center section
        translate([0,0,-recess/2])
            cube([2*(bearing_offset-soffset), height, recess], center=true);
        // hollow out center section 
        translate([0,0,-(sdepth-2)/2])
            cube([cutout, (height-6), sdepth-2], center=true);
        // carriage mounting holes (clearance)
        for(xoff=[-10,10]) {
            for(yoff=[-10,10]) {
                // M3 bolt
                translate([xoff, yoff, -thickness])
                    cylinder(r=1.5, h=thickness, $fn=36);
                // M3 nut
                translate([xoff, yoff, -sdepth]) rotate([0,0,30])
                    cylinder(r=3+tol, h=thickness, $fn=6);
            }
        }
        // recirc bearing mtg holes (clearance M3)
        for(xoff=[-bearing_offset, bearing_offset]) {
            for(yoff=[-12.5, 12.5]) {
                // .5 mm thick bridge at bottom of hole must be drilled out
                translate([xoff, yoff, 3.5-thickness])
                    cylinder(r=1.5, h=thickness, $fn=36);
                // M3 nut
                translate([xoff, yoff, -thickness])
                    cylinder(r=3+tol, h=2.5, $fn=6);
            }
        }
        // tensioning screw 
        // nuts (tolerance is added to radius of nuts)
        translate([-1.9-cutout/2, 0, -tdepth]) rotate([0, 90, 0]) rotate([0, 0, 30])
            cylinder(r=3+tol, h=2, $fn=6);
        translate([-.1+cutout/2, 0, -tdepth]) rotate([0, 90, 0]) rotate([0, 0, 30])
            cylinder(r=3+tol, h=2, $fn=6);
        // bolts
        translate([0, 0, -tdepth]) rotate([0, 90, 0])
            cylinder(r=3/2, h=width+2, $fn=36, center=true);
    }
}

module recirc_half() {
    outer_half();
    
    // support
    swid = 4;
    stk = 0.75;
    soff = 6.5;
    gap = 0.01;
    shgt = thickness-slot-1.3-gap;
    
    echo("recirc bearing bottom z offset:", -gap-shgt-slot/2);
    
    translate([soff+swid/2, 0, .2-gap-shgt-slot/2]) 
        cube([swid, 40+2*stk, .4], center=true);
        
    for (y = [-20: 5: 20]) {
        translate([soff+swid/2, y, -gap-(shgt+slot)/2]) 
            cube([swid, stk, shgt], center=true);
    }
    for (y = [-15: 10: 15]) {
        translate([soff+stk/2, y+5/2, -gap-(shgt+slot)/2]) 
            cube([stk, 5, shgt], center=true);
    }
    for (y = [-15: 10: 15]) {
        translate([soff+swid-stk/2, y-5/2, -gap-(shgt+slot)/2]) 
            cube([stk, 5, shgt], center=true);
    }
}

