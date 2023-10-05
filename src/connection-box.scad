// Connection box
//
// First configuration: Power connectors 4mm and USB-A / USB-A mini
//
// This is intended for easily connecting USB powered devices to a
// labor power supply with 4mm connectors.
//
// Torsten Paul <Torsten.Paul@gmx.de>, October 2023
// CC BY-SA 4.0
// https://creativecommons.org/licenses/by-sa/4.0/

/* [Part Selection] */
selection = 0; // [ 0:Assembly, 1:Base, 2:Top ]

eps = 0.01;
eps2 = 0.05;
tolerance = 0.3;

width = 80;
length = 60;
height = 28;
rounding = 5;
wall = 2;

screw_offset = 8;

conn_4mm_dia = 11.8;
conn_4mm_spacing = 24;

bottom_thickness = 2 * wall;
bottom_screw_dia = 3;
bottom_screw_head_h = 2;
bottom_screw_head_dia = 6;

parts = [
    [ "assembly", [0, 0,  0 ], [ 0,   0, 0], undef],
    [ "base",     [0, 0,  0 ], [ 0,   0, 0], undef],
    [ "top",      [0, 0, 60 ], [ 0, 180, 0], undef]
];

module base_shape(o = 0) {
	translate([-width / 2, 0])
		offset(rounding + o)
			offset(-rounding)
				square([width, length]);
}

module screw_hole(d = 3, o = 1) {
	polygon([for (a = [0:359]) (d/2 + o * sin(a * 5)) * [ -sin(a), cos(a) ]]);
}

module screw_pos(z = 0) {
	ox = width / 2 - screw_offset;
	oy = length / 2 - screw_offset;
	translate([0, length / 2, z])
		for (x = [-1, 1], y = [-1, 1])
			translate([x * ox, y * oy])
				children();
}

module conn_pos(o, z = 0) {
	translate([12, o, z]) children(0);
	translate([-12, o, z]) children(1);
}

module usb_mini_a() {
	w = 20;
	l = 20;
	h = height * 2 / 3 - 3.5;
	o = 5.5;
	s = 8.5;
	difference() {
		if (is_undef($select) || $select == POS) { 
			translate([-w / 2, 0, 0]) cube([w, l, h]);
		}
		if (is_undef($select) || $select == NEG) { 
			translate([s / 2, o, h + eps])
				rotate([0, 180, 0])
					linear_extrude(h - wall, scale = 0.8, convexity = 3)
						screw_hole(bottom_screw_dia, tolerance);
			translate([-s / 2, o, h + eps])
				rotate([0, 180, 0])
					linear_extrude(h - wall, scale = 0.8, convexity = 3)
						screw_hole(bottom_screw_dia, tolerance);
			translate([-4.5, -o - 1.8, h - 3 + tolerance])
				cube([9, 2 * o, 3]);
			translate([-7.5, -eps, h - 3.2])
				rotate([90, 0, 0]) linear_extrude(20)
					offset(1) offset(-1) square([15, 5]);
		}
	}
}

module usb_a($select = undef) {
	w = 20;
	l = 20;
	s = 15 - 3.2;
	o = 14;
	h = height * 2 / 3 - 9.5;
	pins_offset = 3.5; // grove for pins
	pins_spacing = 10;
	case_offset = 6; // offset for the 2 big connector case pins
	case_spacing = 12;
	difference() {
		if (is_undef($select) || $select == POS) { 
			linear_extrude(h)
				translate([-w / 2, 0]) square([w, l]);
		}
		if (is_undef($select) || $select == NEG) { 
			translate([s / 2, o, h + eps])
				rotate([0, 180, 0])
					linear_extrude(h - wall, scale = 0.8, convexity = 3)
						screw_hole(bottom_screw_dia, tolerance);
			translate([-s / 2, o, h + eps])
				rotate([0, 180, 0])
					linear_extrude(h - wall, scale = 0.8, convexity = 3)
						screw_hole(bottom_screw_dia, tolerance);
			x = 2;
			translate([-pins_spacing/2, o - pins_offset - x / 2, h - 2]) cube([pins_spacing, x, 3]);
			translate([case_spacing / 2, o - case_offset, h - 2]) cylinder(d = 3, h = 3);
			translate([-case_spacing / 2, o - case_offset, h - 2]) cylinder(d = 3, h = 3);
			translate([-7.5, -eps, h + 1.5])
				rotate([90, 0, 0]) linear_extrude(20)
					offset(1) offset(-1) square([15, 7.5]);
		}
	}
}

module top() {
	f = 3;
	h = height - bottom_thickness;
	screw_dia = bottom_screw_dia + 2 * tolerance;
	difference() {
		union() {
			// top of case
			linear_extrude(wall, convexity = 3)
				base_shape();
			// wall of case
			linear_extrude(height, convexity = 3) difference() {
				base_shape();
				base_shape(-wall);
			}
			// screw pillars
			screw_pos()
				cylinder(h = h, d = screw_dia + 2 * wall);
			// chamfer at the bottom of the screw pillars
			difference() {
				screw_pos(eps)
					cylinder(h = wall + f, d = screw_dia + 2 * wall + 2 * f);
				screw_pos(wall + f + 0.2)
					rotate_extrude()
						translate([screw_dia / 2 + wall + f, 0])
							circle(r = f);
			}
		}
		// 4mm connectors
		translate([0, length, height / 2]) {
			rotate([90, 0, 0]) {
				translate([conn_4mm_spacing / 2, 0, 0])
					cylinder(h = 10 * wall, d = conn_4mm_dia + 2 * tolerance, center = true);
				translate([-conn_4mm_spacing / 2, 0, 0])
					cylinder(h = 10 * wall, d = conn_4mm_dia + 2 * tolerance, center = true);
			}
		}
		screw_pos(h + eps)
			rotate([0, 180, 0])
				linear_extrude(h - wall, scale = 0.8, convexity = 3)
					screw_hole(bottom_screw_dia, tolerance);
		conn_pos(wall + eps2, height) {
			rotate([0, 180, 0]) usb_mini_a($select = NEG);
			rotate([0, 180, 0]) usb_a($select = NEG);
		}
	}
}

module base() {
	difference() {
		union() {
			linear_extrude(bottom_thickness) base_shape(-wall - tolerance);
			conn_pos(wall + tolerance) {
				usb_a($select = POS);
				usb_mini_a($select = POS);
			}
		}
		conn_pos(wall + tolerance) {
			usb_a($select = NEG);
			usb_mini_a($select = NEG);
		}
		screw_pos()
			cylinder(h = 2 * bottom_screw_head_h, d = bottom_screw_head_dia, center = true);
		screw_pos()
			cylinder(h = 10 * wall, d = bottom_screw_dia + 2 * tolerance, center = true);
	}
}

module part_select() {
    for (idx = [0:1:$children-1]) {
        if (selection == 0) {
            col = parts[idx][3];
            translate(parts[idx][1])
                rotate(parts[idx][2])
                    if (is_undef(col))
                        children(idx);
                    else
                        color(col[0], col[1])
                            children(idx);
        } else {
            if (selection == idx)
                children(idx);
        }
    }
}

part_select() {
	union() {}
	base();
    top();
}

POS = 0;
NEG = 1;

$fa = 2; $fs = 0.2;
