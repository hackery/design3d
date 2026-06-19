from solid import *
from solid.utils import *

# Dimensions
plate_length = 54
plate_width = 22
plate_thickness = 2
hole_diameter = 12
hole_radius = hole_diameter / 2
flat_offset = 1
hole_spacing = 24

def flat_hole():
    """Create a 12mm round hole with 1mm flat on one side."""
    cyl = cylinder(d=hole_diameter, h=plate_thickness + 2, segments=100)
    flat = cube([hole_diameter, hole_diameter, plate_thickness + 2])
    flat = translate([flat_offset, -hole_radius, 0])(flat)
    return difference()(cyl, flat)

def make_plate():
    # Base plate
    base = cube([plate_length, plate_width, plate_thickness])

    # Hole positions
    x1 = plate_length / 2 - hole_spacing / 2
    x2 = plate_length / 2 + hole_spacing / 2
    y = plate_width / 2

    # Holes with flats facing outward along long axis
    hole1 = translate([x1, y, -1])(flat_hole())
    hole2 = mirror([1, 0, 0])(translate([-x2, y, -1])(flat_hole()))

    return difference()(base, hole1, hole2)

scad_render_to_file(make_plate(), 'rect_plate_with_flat_holes.scad')
