include <BOSL2/std.scad>

//--------------------------------------------Parameters--------------------------------------------

/* [Setup Parameters] */

// render resolution
$fn = 128;
// small value to help with Z fighting
epsilon = 0.001;

/* [General Settings] */

// size in X direction
panel_x = 4;
// size in Y direction
panel_y = 4;

/* [Window Settings] */
// set this to a negative value to get the biggest window size, otherwise a positive value will create the desired size
window_size_x = 2;
window_size_y = 2;

// setting this to 0 will put the window at the corner, creating a non rectangular panel
window_location_x = 1;
window_location_y = 1;


/* [CONSTANTS] */

//DO NOT CHANGE unless you want to omit compatibility with default printy plate components
base_length = 29;
base_padding = 3;
base_thickness = 3;

base_chamfer = 0.6;
base_radius = 3;

cutout_chamfer = 1.4;
cutout_wall_distance = 5.5;
cutout_plus_distance = 14;

cutout_short_length = 6;
cutout_long_length = cutout_short_length * 3;
cutout_center_size = 8.485;


module plus_cutout() {
	
	module chamfer_cutout() {
		cuboid(plus_size_x, chamfer=cutout_chamfer, edges="X");
		cuboid(plus_size_y, chamfer=cutout_chamfer, edges="Y");
	}

	plus_size_y = [cutout_short_length, cutout_long_length, cutout_chamfer * 2];
	plus_size_x = [cutout_long_length, cutout_short_length, cutout_chamfer * 2];

	zmove( base_thickness/2) chamfer_cutout();
	zmove(-base_thickness/2) chamfer_cutout();

	cuboid([plus_size_x.x, plus_size_x.y - cutout_chamfer*2, base_thickness]);
	cuboid([plus_size_y.x - cutout_chamfer*2, plus_size_y.y, base_thickness]);

	zrot(45) cuboid(cutout_center_size);
}


module panel(x, y) {
	function panel_size(size) = (base_length + base_padding) * size - base_padding;

	difference() {
		x_len = panel_size(x);
		y_len = panel_size(y);

		fillet_chamfer(chamfer=base_chamfer, rounding=base_radius-base_chamfer, anchor=BOTTOM+FRONT+LEFT)
			chamfered_cuboid([x_len, y_len, base_thickness]);

		for (x_off = [0:x-1], y_off = [0:y-1]) {
			x_distance = cutout_long_length/2 + cutout_wall_distance + (cutout_plus_distance + cutout_long_length) * x_off;
			y_distance = cutout_long_length/2 + cutout_wall_distance + (cutout_plus_distance + cutout_long_length) * y_off;
			move([x_distance, y_distance, base_thickness/2 + epsilon])
				plus_cutout();
		}
	}
}

module window_cutout() {
	function calc_window_size(size) = (base_length + base_padding) * size + base_padding;
	function calc_window_offset(location) = (base_length + base_padding) * location - base_padding;

	window_size_x = (window_size_x < 0) ? panel_x - 2 : window_size_x;
	window_size_y = (window_size_y < 0) ? panel_y - 2 : window_size_y;

	window_size = [
		calc_window_size(window_size_x),
		calc_window_size(window_size_y),
		base_thickness + epsilon
	];
	chamfer_size = [window_size.x + base_chamfer*2, window_size.y + base_chamfer*2, base_chamfer*2];
	window_offset = [calc_window_offset(window_location_x), calc_window_offset(window_location_y)];

	move(window_offset) {
		cuboid(window_size, rounding=base_radius, edges="Z", anchor=BOTTOM+FRONT+LEFT) {
			zmove(base_thickness/2)
				fillet_chamfer(chamfer=base_chamfer, rounding=base_radius)
					chamfered_cuboid(chamfer_size, shrink=true);

			zmove(-base_thickness/2)
				fillet_chamfer(chamfer=base_chamfer, rounding=base_radius)
					chamfered_cuboid(chamfer_size, shrink=true);
		}
	}
}

//----------------------------------------------Utils-----------------------------------------------

function chamfer_shrink(size, chamfer=1, rounding=0, edges=TOP) = [
	(is_list(size) ? size.x : size) - (chamfer + rounding)*2 + EPSILON,
	(is_list(size) ? size.y : size) - (chamfer + rounding)*2 + EPSILON,
	(is_list(size) ? size.z : size) - (edges.z == 0 ? chamfer*2 : chamfer) + EPSILON
];

module chamfered_cuboid(size, shrink=true) {
	echo(chamfer_shrink(size, $chamfer, $rounding, $edges));
	if (shrink)
		cuboid(chamfer_shrink(size, $chamfer, $rounding, $edges), anchor=$anchor) children();
	else
		cuboid(size, anchor=$anchor) children();
}

module fillet_chamfer(chamfer=1, rounding=0, edges=TOP+BOTTOM, anchor=CENTER) {
	$chamfer = chamfer;
	$rounding = rounding;
	$anchor = anchor;
	$edges = edges;

	z_adjust1 = -(anchor.z + edges.z) / 2;
	z_adjust = (edges.z == 0) ? z_adjust1 * 2 : z_adjust1;

	minkowski() {
		children();

		move([
			(chamfer + rounding) * -anchor.x,
			(chamfer + rounding) * -anchor.y,
			z_adjust * chamfer
		])
		union() {
			if (edges.z >= 0)
				cyl(h=chamfer, r1=chamfer + rounding, r2=rounding, anchor=BOTTOM);
			if (edges.z <= 0)
				cyl(h=chamfer, r1=rounding, r2=chamfer + rounding, anchor=TOP);
		}
	}
}

//-----------------------------------------------Main-----------------------------------------------

module main() {
	difference() {
		panel(panel_x, panel_y);
		if (window_size_x != 0 && window_size_y != 0)
			window_cutout();
	}
}

render()
main();
