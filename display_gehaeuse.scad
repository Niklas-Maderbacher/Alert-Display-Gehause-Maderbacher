// ============================================================
//  Housing for D1 Mini (ESP8266) + 0.96" SSD1306 OLED
//  FINAL VERSION – fixed fit, stronger snaps, better clearances
// ============================================================

$fn = 48;

// ---------------- PARAMETERS ----------------

// Printer tuning
tol        = 0.30;
wall       = 2.4;

// D1 Mini
d1_l   = 34.2;
d1_w   = 25.6;
d1_h   = 10.5;
d1_bot =  1.6;

// USB
usb_w  = 10.0;
usb_h  =  4.5;
usb_clear_w = 2.0;
usb_clear_h = usb_h;   // doubles height

// OLED
oled_pcb_l = 27.0;
oled_pcb_w = 27.0;
oled_pcb_h =  7.0;

disp_w = 23.0;
disp_h = 13.0;
disp_dy = 4.0;
bezel = 1.0;
disp_extra_h = 1.5;

// Layout
gap_between = 1.5;
height_extra = 2.0;

// Snap system
snap_w   = 8.0;
snap_t   = 1.0;
snap_lip = 0.8;
snap_len = 10.0;
snap_tol = 0.2;

// ---------------- DERIVED ----------------

inner_l = max(d1_l, oled_pcb_l) + 2*tol + 1.0;
inner_w = max(d1_w, oled_pcb_w) + 2*tol + 1.0;

outer_l = inner_l + 2*wall;
outer_w = inner_w + 2*wall;

// FIXED HEIGHTS
base_h = wall + d1_bot + d1_h + gap_between;
lid_h  = wall + oled_pcb_h + height_extra + 1.5;

corner_r = 3.0;
corner_inner = corner_r - wall + 0.5;

inner_edge_x = outer_l/2 - wall;

// ---------------- MODULES ----------------

module rounded_rect(l, w, h, r) {
    hull() {
        for (x = [-l/2+r, l/2-r])
        for (y = [-w/2+r, w/2-r])
            translate([x, y, 0])
                cylinder(r=r, h=h);
    }
}

module standoff(h, od=3.5, id=1.8) {
    difference() {
        cylinder(d=od, h=h);
        cylinder(d=id, h=h+0.2);
    }
}

// FLEXIBLE SNAP TAB (FIXED)
module snap_tab() {
    translate([-snap_w/2, 0, 0])
    union() {

        // flexible arm
        cube([snap_w, snap_t, snap_len]);

        // angled hook
        translate([0, snap_t, snap_len - 1.5])
            rotate([25,0,0])
                cube([snap_w, snap_lip, 1.5]);

        // base reinforcement
        cylinder(d=snap_w, h=0.6);
    }
}

// PCB clip
module pcb_clip() {
    union() {
        cube([2, 4, 3]);
        translate([0, 0, -wall])
            cube([2, 4, wall]);
    }
}

// ---------------- BASE ----------------

module base() {

    difference() {

        rounded_rect(outer_l, outer_w, base_h, corner_r);

        translate([0, 0, wall])
            rounded_rect(inner_l, inner_w, base_h, corner_inner);

        // USB CUTOUT (FIXED)
        translate([-outer_l/2 - 0.1,
                   -usb_w/2 - usb_clear_w/2,
                   wall + d1_bot - 0.5])
            cube([wall + 2.5,
                  usb_w + usb_clear_w,
                  usb_h + usb_clear_h]);

        // Ventilation
        for (side = [-1,1])
        for (y = [-6,-2,2,6])
            translate([side*(inner_edge_x + 0.1),
                       y,
                       wall + 4])
                cube([wall + 0.3, 2.0, 8.0]);

        // Snap recess
        for (side = [-1, 1])
            translate([0,
                       side*(outer_w/2 - wall/2),
                       base_h - snap_t - snap_lip])
                cube([snap_w,
                      wall + 0.3,
                      snap_t + snap_lip + 0.2],
                      center=true);
    }

    // PCB standoffs
    for (x = [-d1_l/2 + 2, d1_l/2 - 2])
    for (y = [-d1_w/2 + 2, d1_w/2 - 2])
        translate([x, y, wall])
            standoff(wall + 0.8);

    // PCB clips
    translate([ d1_l/2 - 3, 0, wall + 1])
        pcb_clip();
    translate([-d1_l/2 + 1, 0, wall + 1])
        pcb_clip();
}

// ---------------- LID ----------------

module lid() {

    difference() {

        rounded_rect(outer_l, outer_w, lid_h, corner_r);

        translate([0, 0, wall])
            rounded_rect(inner_l, inner_w, lid_h, corner_inner);

        // DISPLAY OPENING (FIXED HEIGHT)
        translate([-disp_w/2 + bezel/2,
                   -disp_h/2 + disp_dy - disp_extra_h/2,
                   -0.1])
            cube([disp_w - bezel,
                  disp_h + disp_extra_h,
                  wall + 0.2]);

        // Cable slot
        translate([inner_edge_x + 0.1,
                   -5,
                   wall + 1])
            cube([wall + 0.3, 10, 4]);
    }

    // SNAP TABS (WITH TOLERANCE)
    for (side = [-1, 1])
        translate([0,
                   side*(inner_w/2 - tol + snap_tol),
                   wall])
            rotate([0, 0, side > 0 ? 0 : 180])
                snap_tab();

    // Alignment lip
    difference() {
        translate([0, 0, wall])
            rounded_rect(inner_l - tol*2,
                         inner_w - tol*2,
                         1.5,
                         corner_inner);

        translate([0, 0, wall - 0.1])
            rounded_rect(inner_l - tol*2 - wall*2,
                         inner_w - tol*2 - wall*2,
                         2.0,
                         corner_inner - 1);
    }
}

// ---------------- EXPORT ----------------

// Comment ONE out before exporting STL

// base();
// lid();

// Exploded view
translate([0,0,0]) base();
translate([0,0,base_h+8]) lid();