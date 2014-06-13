include <recirculating_mw.scad>
echo("recirc_plate(14.5)");
translate([0, 27, 12]) recirc_plate(14.5, 0.25);

translate([-30, -27, 8.45]) {
    recirc_half();
    translate([20, 0, 0]) inner_half();
}
translate([15, -27, 8.45]) {
    recirc_half();
    translate([20, 0, 0]) inner_half();
}

