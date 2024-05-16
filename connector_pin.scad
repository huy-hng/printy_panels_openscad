include <BOSL2/std.scad>

module connector_pin() {

	module rotated_outer_part(side) {
		// dont mind these weird operations, I'm bad at openscad
		position(LEFT * side[0]+BACK)
		zrot(-45 * side[0])
		xmove(-0.366 * side[0])
		zrot(-45 * side[0])
			cuboid([2, 1.58, connector_height], anchor=RIGHT * side[0]+BACK);
	}

	module remove_sharp_corners(side) {
		cuboid([2, 2, connector_height], anchor=LEFT*side[0]+FRONT) {
			position(TOP+LEFT*side[0]) zmove(-1) yrot(-45*side[0])
				cuboid(2, anchor=BOTTOM+LEFT*side[0]);
		};
	}

	connector_height = 6;

	diff() {
		cuboid([2.8, 3.1, connector_height], anchor=BOTTOM+FRONT) {
			// left side
			position(FRONT+LEFT)
			zrot(45) cuboid([2, 2, connector_height])
				rotated_outer_part(LEFT);
			
			// right side
			position(FRONT+RIGHT)
			zrot(-45) cuboid([2, 2, connector_height])
				rotated_outer_part(RIGHT);

			
			// remove sharp corners
			tag("remove") {
				xmove( 2.5197) remove_sharp_corners(RIGHT);
				xmove(-2.5197) remove_sharp_corners(LEFT);
			}

			// remove excess
			tag("remove") {
				position(FRONT) cuboid(10, anchor=BACK);
				position(BACK)  cuboid(10, anchor=FRONT);
			}
		}
	}

}
