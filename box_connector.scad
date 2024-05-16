include <BOSL2/std.scad>
include <./connector_pin.scad>


//--------------------------------------------Parameters--------------------------------------------
/* [Setup Parameters] */

// render resolution
$fn = 128;
// $fn = $preview ? 64 : 256;

/* [Connector Size] */
panel_x = 5;
panel_y = 6;


/* [CONSTANTS] */

// DO NOT CHANGE unless you want to omit compatibility with default printy plate components
connector_height = 12;
connector_thickness = 3;

connector_distance = 32;

chamfer = 0.4;
outer_radius = 1;
inner_radius = 3;

outer_size = [32 * panel_x + 3, 32 * panel_y + 3, connector_height];
inner_size = [32 * panel_x - 3, 32 * panel_y - 3, connector_height];

module box_connector_rim() {
	difference() {
		fillet_chamfer(chamfer, rounding=outer_radius, edges=TOP, anchor=BOTTOM) {
			chamfered_cuboid(outer_size);
		}

		cuboid(inner_size, rounding=inner_radius, edges="Z", anchor=BOTTOM) {
			// inner chamfer
			position(TOP)
			zmove(-chamfer)
			fillet_chamfer(chamfer, rounding=inner_radius, edges=BOTTOM, anchor=BOTTOM)
				chamfered_cuboid([inner_size.x + chamfer*2, inner_size.y + chamfer*2, inner_size.z]);
		}
	}
}

module connector_pins() {
	for (x=[-(panel_x-1)/2:(panel_x-1)/2]) {
		ymove(outer_size.y/2) {
			xmove(x * connector_distance)
			connector_pin();
		}
		ymove(-outer_size.y/2) {
			xmove(x * connector_distance)
			zrot(180) connector_pin();
		}
	}

	for (y=[-(panel_y-1)/2:(panel_y-1)/2]) {
		xmove(outer_size.x/2) {
			ymove(y * connector_distance)
			zrot(-90) connector_pin();
		}
		xmove(-outer_size.x/2) {
			ymove(y * connector_distance)
			zrot(90) connector_pin();
		}
	}
}


//-----------------------------------------------Main-----------------------------------------------

module main() {
	box_connector_rim();
	connector_pins();
}

render()
main();

//----------------------------------------------Utils-----------------------------------------------

function chamfer_shrink(size, chamfer=1, rounding=0, edges=TOP) = [
	(is_list(size) ? size.x : size) - (chamfer + rounding)*2 + EPSILON,
	(is_list(size) ? size.y : size) - (chamfer + rounding)*2 + EPSILON,
	(is_list(size) ? size.z : size) - (edges.z == 0 ? chamfer*2 : chamfer) + EPSILON
];

module chamfered_cuboid(size, shrink=true) {
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
