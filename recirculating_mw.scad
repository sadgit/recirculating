nballs = 20;
thickness = 11;


extrusion_clearance = 13.35;
extrusion_half = 7.5;

ball_radius = .187 * 25.4 / 2;  // measurement of 3/16" diameter delrin balls
ball_tol = 0.3;
slot = 2.5;
xfaces = 36;
cfaces = 72;


z_offset = slot/2-thickness+1.3;
echo("z_offset:", z_offset);

plate_thickness = extrusion_clearance + extrusion_half + z_offset;
echo("plate_thickness:", plate_thickness);


// Fixing Sizes
smidge              = 0.1;
m3Radius            = (2.9/cos(30)) / 2;
m3LooseRadius       = m3Radius + 0.2;
m3HeadHeight        = 3.0;
m3LooseHeadRadius   = (5.4 + 0.6) / 2;
m3NutRadius         = (6.25 + 0.75) / 2;
m3NutHeight         = 2.4;


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

center_spacing = length - (2*outside_radius); 
center_offset = center_spacing / 2;

straight = center_spacing + 0.1;
circumference = 2 * PI * track_radius + 2 * straight;


bolt_spacing = center_spacing -4;

echo("ball_radius:", ball_radius, " ball_tol:", ball_tol); 

echo("outside_radius:", outside_radius); 
echo("length:", length); 
echo("bolt_spacing:", bolt_spacing, "calc", 2*(center_offset-2) ); 

module octagonal_channel(r1,r2){
    big_rad = r1+r2;
    intersection() {
        union() {
            circle(r=r1/cos(45), $fn=4, center=true);
            translate([(big_rad)/2,0,0]) square([big_rad, 2*(big_rad)], center=true);
        }
      //  intersection() {
            rotate([0,0,45]) circle(r=(big_rad)/cos(45), $fn=4, center=true);
          //  circle(r=(big_rad)/cos(45), $fn=4, center=true);
        //}
    };
}

module channel_profile(r1, r2){
    // circle(r=r1+r2, $fn=cfaces);
    octagonal_channel (r1, r2);
}


module corner(yoffset) {
    echo("corner");
    cubeOff = (yoffset<0) ? -20 : 20;
    translate([0, yoffset, 0]) 
    intersection() {
        rotate_extrude($fn=xfaces)
        translate([track_radius, 0, 0])
            channel_profile(ball_radius, ball_tol); 
        translate([0, cubeOff, 0]) cube([40, 40, 40], center=true);
    }
}

module straight_channel(r1, r2, len) {
    // cylinder(r=r1+r2, h=len, center=true, $fn=cfaces);
    translate([0,0,-len/2]) linear_extrude(height=len) channel_profile(r1, r2);
}

module track() {
    echo("track");
    union() {
        corner(-center_offset, track_radius);
        corner(center_offset, track_radius);
        for (s = [-1, 1]) {
            scale([s, 1, 1])
            translate([track_radius, 0, 0]) rotate([90, 0, 0]) {
                straight_channel(ball_radius, ball_tol, straight);
                // cylinder(r=ball_radius+ball_tol, h=straight, center=true, $fn=cfaces);
                
            //     translate([0, 2, 0]) // *
            // #    cylinder(r=channel_radius*0.61,
            //     h=straight,
            //     center=true, $fn=6);
            }
        }
    }
}

module balls() {
    echo("balls");
    assign(outside_radius = track_radius + channel_radius + 1.5) {
        translate([-track_radius+ball_tol, 0, 0]) % sphere(r=ball_radius, $fn=72); // 3/16" diameter
        translate([0, center_offset+track_radius, 0]) % sphere(r=ball_radius, $fn=72);
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

// module inner_half_dl(){
// rotate([90,0,0])
// translate([25,0,0]) 
// linear_extrude(height=30, convexity=2) 
// octagonal_channel(ball_radius, 0.1);
//     // Main Section
//     translate([0, 0, channelHeight/2+cutDepth/2-8.45]){
//         half(track_radius);
//     //    inner_volume(-0.1);
//     }
// }

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
            // translate([track_radius, 0, -.5]) rotate([90, 0, 0]) translate([0, 2, 0]) 
            // cylinder(r=channel_radius*0.61, h=length, center=true, $fn=6);
            // translate([-track_radius, 0, -.5]) rotate([90, 0, 0]) translate([0, 2, 0]) 
            // cylinder(r=channel_radius*0.61, h=length, center=true, $fn=6);
        }
        // bosses for bolt heads
        assign(bhr = 2)
        for (y = [-bolt_spacing/2,
        bolt_spacing/2]) {
            translate([0, y, channel_radius-0.5])
            difference() {
                cylinder(r=4, h=bhr, $fn=36);
                translate([0,0,-0.1]) cylinder(r=m3Radius, h=bhr+0.2, $fn=6);
            }
        }            
        translate([5.75, 0, 0]) % sphere(r=ball_radius, $fn=72); // 3/16" diameter
    }
}


module half() {
    echo("half");
    difference() {
        union() {
            balls(track_radius);
            translate([0, 0, z_offset])
            linear_extrude(height=30, convexity=2) {
                difference() {
                    translate([-0.5, 0, 0]) minkowski() {
                        square([0.1, 0.1+center_spacing], center=true);
                        circle(r=outside_radius-0.05, $fn=36);
                    }
                    for (y = [2+-center_offset,
                    center_offset-2]) {
                        translate([0, y])
                        circle(r=m3Radius, $fn=6);
                    }
                }
            }
        }
        track(track_radius);
        translate([-10.5, 0, 12.5])
        cube([100, 100, 20], center=true);
        // translate([0, 0, 10]) rotate([0, -90, 0]) {
        //     rotate([0, 0, 90]) # cylinder(r=3.2, h=50, $fn=6);
        //  //   cylinder(r=1.7, h=50, center=true, $fn=12);
        // }
        // translate([10+track_radius, 0, -10-slot/2])
        // cube([20, length, 20], center=true);
        // translate([10+track_radius, 0, 10+slot/2])
        // cube([20, length, 20], center=true);
        // bosses for bolt heads
        // assign(bhr = 3)
        // for (y = [2-center_offset,
        // center_offset-2]) {
        //     translate([0, y, channel_radius])
        //     cylinder(r=3.1, h=bhr, $fn=36);
        // }
    }
}

module outer_half() {
    echo("outer_half");
    echo("length:", length);
    difference() {
        translate([0, 0, z_offset])
        linear_extrude(height=30, convexity=2) {
            difference() {
                translate([-0.5, 0, 0]) minkowski() {
                    square([0.1, 0.1+center_spacing], center=true);
                    circle(r=outside_radius-0.05, $fn=36);
                }
                for (y = [2-center_offset,
                center_offset-2]) {
                    translate([0, y])
                    circle(r=m3Radius, $fn=6);
                }
            }
        }
        track(track_radius);
        balls(track_radius);

        
        // remove overhang at top of track
        // translate([-0.0, 0, -3]) 
        hull() {
            translate([0,center_spacing/2,0]) cylinder(r=outside_radius-2.5, h=(channelHeight+cutDepth));
            translate([0,-center_spacing/2,0]) cylinder(r=outside_radius-2.5, h=(channelHeight+cutDepth));
        }
    
        // remove inner part of track to eliminate travel moves
        // allow an extra .1mm for clearance
        inner_volume(0.1);
        // remove thin wall
        translate([channel_radius+2.5, 0, -cutDepth/2]) //#
        cube([1, length-14, cutDepth], center=true);
        
        // slice off the top
        translate([-outside_radius-1,-1-length/2,2.5]) cube([2*outside_radius+2, length+2, 20]);
        
        translate([10+track_radius, 0, -10-slot/2])
        cube([20, length, 20], center=true);
        translate([10+track_radius, 0, 10+slot/2])
        cube([20, length, 20], center=true);
    }
}

module support(thick){
    translate([0, 0, thick/2]) {
        difference(){
            hull() {
                translate([0, bolt_spacing/2,0]) cylinder(r1=5, r2=10, h=thick, center=true);
                translate([0,-bolt_spacing/2,0]) cylinder(r1=5, r2=10, h=thick, center=true);
            } 
            translate([2,-25,-thick/2+3])  // # 
            cube([10,50,thick]);

            //Mountings
            translate([0, bolt_spacing/2,-thick/2]) rotate([0, 0, 0]) underM3x25(thick, 3, rot=30);  
            translate([0,-bolt_spacing/2,-thick/2]) rotate([0, 0, 0]) underM3x25(thick, 3, rot=30); 

            // Cinch Bolt
            translate([-10,0,thick/2 - 3.5]) rotate([0,90,0]) rotate([0,0,30]) #  captiveM3x25(20, 9);
        }
    }
}

module recirc_plate(bearing_offset) {
    echo("recirc_plate es");
    width = 42;
    height = 42;
    thick = plate_thickness;
    sdepth = 9;
    slotwidth = 1;
    soffset = (bearing_offset-10)/2;
    tdepth = .4 * sdepth;
    stopdepth = 3;
    tol = 0.25;
    cutout = 10;
    difference() {
        union() {
            block_2020(stopdepth, thick - 1);

            translate([-bearing_offset, 0, 0])  support(thick);
            translate([bearing_offset, 0, 0]) rotate([0,0,180]) 
             support(thick);
    
        }

        translate([0,0,-smidge]) fixings_2020(7+smidge+smidge);
         //# 
        bearing_fixings(thick+smidge, bearing_offset, bolt_spacing/2);
    }
}

module bearing_fixings(thick, xoffset, yoffset){
    translate([0,0,thick])
    rotate([0, 180, 0])
        fixings_rect(thick, xoffset, yoffset, dep=3, rot=30, under=1);
}

module fixings_rect(thick, xoffset, yoffset, rot=30, dep=m3NutHeight, under=0){
    union(){
        for(xoff=[-xoffset,xoffset]) {
            for(yoff=[-yoffset, yoffset]) {
                // M3 bolt
                translate([xoff, yoff, thick]) 
                rotate([180,0,rot]) 
                if (under==0) {
                     captiveM3x25(thick, dep);
                } else {
                     underM3x25(thick, dep);
                }
            }
        }
    }
}

module fixings_2020(thick, xoffset=10, yoffset=10){
    fixings_rect (thick, xoffset, yoffset, rot=30, dep=2.5);   
}

module m3x25(h, countersunkHead=0)
{   
    translate([0,0,smidge])
    {
        cylinder(r=m3LooseRadius, h=h);
        translate([0, 0, h - m3HeadHeight - countersunkHead])
        cylinder(r=m3LooseHeadRadius, h=m3HeadHeight + countersunkHead);
    }
}

module captiveM3x25(h, dep=m3NutHeight, rot=0) 
{
// This is an M3 screw hole, with room for a nyloc nut on the bottom.
    rotate(0,0,rot){
        cylinder(r=m3LooseRadius, h=h);
        cylinder(r=m3NutRadius-0.075, h=dep, $fn=6);
    }
    
}
module underM3x25(h, dep=m3NutHeight, rot=0)
{
    rotate([0,0,rot]){
       # captiveM3x25(h, dep);
        //chamfer added by TL
        translate([0,0,-0.2])
        cylinder(r1=m3NutRadius+1,r2=m3NutRadius-1, h=2, $fn=6);
    }
}

module block_2020(stopdepth, tension_ht) {
    overhang = 8;
    spacing = 20;
    thick = 7;
    height = spacing + 2*overhang;
    width = spacing + 4;
    offset = spacing/2;
    difference() {
        translate([0,0,7/2]) //#
            // minkowski(){
            //     cube ([spacing, spacing, 7/2]);
            //     cylinder(r=overhang, h=7/2);
            // }
            union () {
                cube ([width, height, 7], center=true);
                translate([0,0,(tension_ht-7)/2]) cube ([width, 14, tension_ht], center=true);
            }

        translate([0,0,(tension_ht-2.5)]) # cube ([width-12, 6, 6], center=true);
        // Cinch bolts
        translate([-6,0,tension_ht - 2.5]) rotate([0,90,180]) rotate([0,0,30]) #  captiveM3x25(20, 4);
        translate([6,0,tension_ht - 2.5]) rotate([0,90,0]) rotate([0,0,30]) #  captiveM3x25(20, 4);
       

        // carriage mounting holes (clearance)
        fixings_2020(thick);

        // end stops - centrline - top
        translate([0, 0, stopdepth])  rotate([90, 0, 0])
       #   cylinder (r=1.25, h=height+2, $fn=5, center=true);
    }

}

module tension_screw(cutout, tdepth,width) {
    // tensioning screw 
    // nuts (tolerance is added to radius of nuts)
    translate([-1.9-cutout/2, 0, -tdepth]) rotate([0, 90, 0]) rotate([0, 0, 30])
    m3nut();
    translate([-.1+cutout/2, 0, -tdepth]) rotate([0, 90, 0]) rotate([0, 0, 30])
    m3nut();

    translate([-.1+width/2-3, 0, -tdepth]) rotate([0, 90, 0]) rotate([0, 0, 30])
    m3nut(3.2);
    translate([-.1-width/2, 0, -tdepth]) rotate([0, 90, 0]) rotate([0, 0, 30])
    m3nut(3.2);

    // bolts
    translate([0, 0, -tdepth]) rotate([0, 90, 0])
    cylinder(r=3/2, h=width+2, $fn=36, center=true);

}

module m3nut(ht=2, tol=0.25) {
  cylinder(r=3+tol, h=ht, $fn=6);

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

