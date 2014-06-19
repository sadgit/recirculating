include <recirculating_mw.scad>

assign( track_radius = 6)
assign( outside_radius = channel_radius + track_radius + 1.5)
assign( min_circ = 20 * 2 * ball_radius)
assign( min_length = 0.5 * (min_circ - 2 * PI * track_radius + 4 * outside_radius - .2))
assign( length = min_length + 0.5 * 20 * .05)
assign( straight = length-2*outside_radius+0.1)
assign( circumference = 2 * PI * track_radius + 2 * straight)
{
    
    echo("track_radius: ", track_radius, " outside_radius: ", outside_radius);
    echo("min_length: ", min_length, "length: ", length);
    echo("circumference: ", circumference, " min_circ: ", min_circ);
    echo("straight length: ", straight);
    
    recirc_half();
    #% cube([2*outside_radius, straight, 2*channel_radius], center=true);        
}
