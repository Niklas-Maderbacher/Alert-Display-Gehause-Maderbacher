// ============================================================
//  Housing for D1 Mini (ESP8266) + 0.96" SSD1306 OLED I2C
//  128x64 pixels – snap-fit two-part enclosure
//  All dimensions in millimetres
//  Print: base + lid separately, no supports needed
// ============================================================

$fn = 48;
wall   = 2.0;
tol    = 0.25;

// D1 Mini PCB
d1_l   = 34.2;
d1_w   = 25.6;
d1_h   = 10.5;
d1_bot =  1.6;
usb_w  = 10.0;
usb_h  =  4.5;

// OLED PCB
oled_pcb_l = 27.0;
oled_pcb_w = 27.0;
oled_pcb_h =  7.0;
disp_w = 23.0;
disp_h = 13.0;
disp_dy = 4.0;

// Internal layout
gap_between = 1.5;
inner_l = max(d1_l, oled_pcb_l) + 2*tol + 1.0;
inner_w = max(d1_w, oled_pcb_w) + 2*tol + 1.0;
inner_h = d1_bot + d1_h + gap_between + oled_pcb_h + 1.0;

outer_l = inner_l + 2*wall;
outer_w = inner_w + 2*wall;

base_h  = wall + d1_bot + d1_h + gap_between + oled_pcb_h*0.5;
lid_h   = inner_h - (base_h - wall) + wall;
corner_r = 3.0;

snap_w   = 8.0;
snap_t   = 1.2;
snap_lip = 0.8;

module rounded_rect(l, w, h, r) {
    hull() {
        for (x = [-l/2+r, l/2-r])
        for (y = [-w/2+r, w/2-r])
            translate([x, y, 0]) cylinder(r=r, h=h);
    }
}

module standoff(h, od=4.0, id=1.8) {
    difference() {
        cylinder(d=od, h=h);
        cylinder(d=id, h=h+0.1);
    }
}

module snap_tab() {
    translate([-snap_w/2, 0, 0])
    difference() {
        union() {
            cube([snap_w, snap_t, 6.0]);
            translate([0, snap_t, 4.5])
                cube([snap_w, snap_lip, 1.5]);
        }
    }
}

module base() {
    difference() {
        rounded_rect(outer_l, outer_w, base_h, corner_r);
        translate([0, 0, wall])
            rounded_rect(inner_l, inner_w, base_h, corner_r-wall+0.1);
        // USB cutout
        translate([-outer_l/2 - 0.1, -usb_w/2, wall + d1_bot - 0.5])
            cube([wall + 1.0, usb_w, usb_h]);
        // Vent slots
        for (y = [-4, 0, 4])
            translate([outer_l/2 - wall - 0.1, y - 1.0, wall + 4])
                cube([wall + 0.2, 2.0, 6.0]);
        // Snap recesses
        for (side = [-1, 1])
            translate([0, side*(outer_w/2 - wall/2), base_h - snap_t - snap_lip])
                cube([snap_w, wall + 0.2, snap_t + snap_lip + 0.1], center=true);
    }
    // PCB standoffs
    for (x = [-d1_l/2 + 2, d1_l/2 - 2])
    for (y = [-d1_w/2 + 2, d1_w/2 - 2])
        translate([x, y, wall])
            standoff(wall + 0.6, od=3.5, id=1.8);
}

module lid() {
    difference() {
        rounded_rect(outer_l, outer_w, lid_h, corner_r);
        translate([0, 0, wall])
            rounded_rect(inner_l, inner_w, lid_h, corner_r - wall + 0.1);
        // Display window
        translate([-disp_w/2, -disp_h/2 + disp_dy, -0.1])
            cube([disp_w, disp_h, wall + 0.2]);
        // I2C cable slot
        translate([outer_l/2 - wall - 0.1, -5.0, wall + 1.0])
            cube([wall + 0.2, 10.0, 4.0]);
    }
    // Snap tabs
    for (side = [-1, 1])
        translate([0, side*(inner_w/2 - tol), wall])
            rotate([0, 0, side > 0 ? 0 : 180])
                snap_tab();
    // Alignment lip
    difference() {
        translate([0, 0, wall])
            rounded_rect(inner_l - tol*2, inner_w - tol*2, 1.5, corner_r - wall);
        translate([0, 0, wall - 0.1])
            rounded_rect(inner_l - tol*2 - wall*2, inner_w - tol*2 - wall*2, 2.0, corner_r - wall*2);
    }
}

// Exploded view – comment out one for individual export
translate([0, 0, 0])       base();
translate([0, 0, base_h + 8]) lid();