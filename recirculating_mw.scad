nballs = 20;
thickness = 11;
ball_radius = .187 * 25.4 / 2;  // measurement of 3/16" diameter delrin balls
ball_tol = 0.3;
slot = 2.5;
xfaces = 36;
cfaces = 72;

channel_radius = 3;
track_radius = 6;

outside_radius = channel_radius + track_radius + 1.5;
min_circ = nballs * 2 * ball_radius;
min_length = 0.5 * (min_circ - 2 * PI * track_radius + 4 * outside_radius - .2);
// calculated circumference seems seems to be coming up about 2mm too long
ct_fudge = 2;
circ_tol = 1 + ct_fudge; // extra track circumference for ball clearance (plus fudge factor)
echo(str("net circumference tolerance: ", (circ_tol-ct_fudge)/nballs, "mm per ball"));
length = min_length + circ_tol/2;
straight = length-2*outside_radius+0.1;
circumference = 2 * PI * track_radius + 2 * straight;

echo("ball_radius:", ball_radius, " ball_tol:", ball_tol); 

module corner(yoffset) {
    echo("corner");
    cubeOff = (yoffset<0) ? -20 : 20;
    translate([0, yoffset, 0]) 
    intersection() {
        rotate_extrude($fn=xfaces)
        translate([track_radius, 0, 0]) circle(r=ball_radius+ball_tol, $fn=cfaces);
        translate([0, cubeOff, 0]) cube([40, 40, 40], center=true);
    }
}

module track() {
    echo("track");
    union() {
        corner(outside_radius-length/2, track_radius);
        corner(length/2-outside_radius, track_radius);
        for (s = [-1, 1]) {
            scale([s, 1, 1])
            translate([track_radius, 0, 0]) rotate([90, 0, 0]) {
                cylinder(r=ball_radius+ball_tol,
                h=length-2*outside_radius+0.1,
                center=true, $fn=cfaces);
                translate([0, 2, 0]) *
                cylinder(r=channel_radius*0.61,
                h=length-2*outside_radius+0.1,
                center=true, $fn=6);
            }
        }
    }
}

module balls() {
    echo("balls");
    assign(outside_radius = track_radius + channel_radius + 1.5) {
        translate([-track_radius+ball_tol, 0, 0]) % sphere(r=ball_radius, $fn=72); // 3/16" diameter
        translate([0, length/2-outside_radius+track_radius, 0]) % sphere(r=ball_radius, $fn=72);
    }
}

module half() {
    echo("half");
    difference() {
        union() {
            balls(track_radius);
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
        }
        track(track_radius);
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
        // bosses for bolt heads
        assign(bhr = 3)
        for (y = [2+outside_radius-length/2,
        length/2-outside_radius-2]) {
            translate([0, y, channel_radius])
            cylinder(r=3.1, h=bhr, $fn=36);
        }
    }
}

channelHeight = -1 + 2 * channel_radius;
cutDepth = 5;

module inner_volume(tol=0) {
    echo("inner_volume");
    translate([0, 0, -channelHeight/2-cutDepth/2]) 
    linear_extrude(height=channelHeight+cutDepth, convexity=2) {
        minkowski() {
            square([5+tol, length-16.5+tol], center=true);
            circle(r=channel_radius, $fn=24);
        }
    }
}

module inner_half() {
    echo("inner_half");
    echo("length:", length);
    translate([0, 0, channelHeight/2+cutDepth/2-8.45]) {
        difference() {
            intersection() {
                half(track_radius);
                // inner part of track 
                inner_volume(-.1);
            }
            // remove overhangs
            translate([track_radius, 0, -.5]) rotate([90, 0, 0]) translate([0, 2, 0]) 
            cylinder(r=channel_radius*0.61, h=length, center=true, $fn=6);
            translate([-track_radius, 0, -.5]) rotate([90, 0, 0]) translate([0, 2, 0]) 
            cylinder(r=channel_radius*0.61, h=length, center=true, $fn=6);
        }
        // bosses for bolt heads
        assign(bhr = 2)
        for (y = [2+outside_radius-length/2,
        length/2-outside_radius-2]) {
            translate([0, y, channel_radius-0.5])
            difference() {
                cylinder(r=4, h=bhr, $fn=36);
                cylinder(r=1.5, h=bhr, $fn=36);
            }
        }            
        translate([5.75, 0, 0]) % sphere(r=ball_radius, $fn=72); // 3/16" diameter
    }
}

module outer_half() {
    echo("outer_half");
    echo("length:", length);
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
        track(track_radius);
        balls(track_radius);
        
        // remove inner part of track to eliminate travel moves
        // allow an extra .1mm for clearance
        inner_volume(0.1);
        // remove overhang at top of track
        translate([-0.0, 0, 0]) 
        linear_extrude(height=channelHeight+cutDepth, convexity=2) {
            minkowski() {
                square([0.1, 0.1+length-2*outside_radius], center=true);
                circle(r=outside_radius-2.5, $fn=36);
            }
        }
        // remove thin wall
        translate([channel_radius+2.5, 0, -cutDepth/2]) # cube([1, length-14, cutDepth], center=true);
        
        translate([-10.5, 0, 12.5])
        cube([100, 100, 20], center=true);
        translate([0, 0, 10]) rotate([0, -90, 0]) {
            rotate([0, 0, 90]) cylinder(r=3.2, h=50, $fn=6);
            cylinder(r=1.8, h=50, center=true, $fn=12);
        }
        translate([10+track_radius, 0, -10-slot/2])
        cube([20, length, 20], center=true);
        translate([10+track_radius, 0, 10+slot/2])
        cube([20, length, 20], center=true);
    }
}

module recirc_plate(bearing_offset, recess=0.5) {
    echo("recirc_plate es");
    width = 42;
    height = 42;
    thickness = 12;
    sdepth = 9;
    slotwidth = 1;
    soffset = (bearing_offset-10)/2;
    tdepth = .4 * sdepth;
    stopdepth = thickness - 3;
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
		// end stops - centrline - top
        translate([0, 0, -stopdepth])  rotate([90, 0, 0])
        cylinder (r=1.25, h=height+2, $fn=5, center=true);
    }
}

module recirc_half() {
    echo("recirc_half");
    outer_half(track_radius);
    
    // add support
    swid = 4;
    stk = 0.75;
    soff = 6.5;
    gap = 0.005;
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

