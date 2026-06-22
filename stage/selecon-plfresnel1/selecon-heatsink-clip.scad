#region(); // variables
    /* [Global print settings] */

    // Smoothness for circles and cylinders
    $fn = 60;
    // 3D printing tolerance padding
    clearance             = 0.2;

    /* [Fan Constants (70mm profiles)] */

    // Outer frame width
    fan_outer_size   = 70.0;
    // Center cutout for air path
    fan_airflow_dia  = 66.0;
    // Center-to-center distance for screws
    fan_hole_spacing = 60.0;
    // Main plate floor thickness
    plate_thickness  = 4.0;

    /* [Self-tapping screw reinforcements] */

    // Sized tightly so self-tapping fan screws can bite
    screw_hole_dia   = 3.2;
    // Outer diameter of the upper reinforcement cylinders
    screw_boss_dia   = 10.0;
    // How far the cylinders extend upward from the plate face
    screw_boss_height = 3.0;

    /* [Reinforcing cross struts] */

    // Aerodynamic shape of the cross struts (0 = Rectangular, 1 = Aerodynamic Diamond, 2 = Asymmetric Pitch Foil)
    strut_profile = 2; // [0:Rectangular, 1:Aerodynamic Diamond, 2:Asymmetric Pitch Foil]
    // Width of the reinforcing cross struts crossing the air intake
    strut_width = 5.0;
    // Vertical thickness of the reinforcing cross struts
    strut_thickness = 3.0;
    // Aerodynamic angle of attack in degrees to match fan swirl rotation (positive for clockwise fans, negative for counter-clockwise)
    fan_swirl_angle = 15; // [-45:45]

    // Enable built-in thin sacrificial support walls under the struts for clean 3D printing
    enable_print_supports = 1; // [0:Disabled, 1:Enabled]

    /* [Selecon heatsink geometry] */

    // Width between the heatsink's side tracks
    heatsink_width        = 82.0;
    // Distance from top face down to the locking slot
    groove_depth_from_top = 5.0;
    // Structural thickness of the side walls
    moulding_wall_thick   = 3.0;
    // Distance the locking lip extends into the slot
    groove_tongue_inward  = 2.5;
    // Vertical thickness of the locking lips
    track_lip_height      = 3.0;


    // --- PRE-CALCULATED VALUES ---
    total_width  = heatsink_width + (2 * moulding_wall_thick);
    total_height = groove_depth_from_top + track_lip_height;
#end();

// --- CUSTOM MODULES ---

// Generates a single diagonal strut across the bore with advanced aerodynamic options
module generate_strut() {
    if (strut_profile == 2) {
        // Asymmetric Pitch Foil: Re-ordered points to ensure a valid clockwise path
        // The extruded profile is correctly rotated so it bridges the airflow gap
        translate([0, 0, plate_thickness - strut_thickness])
            rotate([90, 0, 90])
                linear_extrude(height = fan_airflow_dia, center = true)
                    polygon(points = [
                        [0, -strut_width/2],                                        // 1. Trailing Edge (Bottom)
                        [strut_thickness, tan(fan_swirl_angle) * strut_thickness],   // 2. Pitched Leading Edge (Top shifted by fan swirl)
                        [strut_thickness/2, strut_width/2],                          // 3. Right Flank
                        [-strut_thickness/2, strut_width/2]                          // 4. Left Flank
                    ]);
    } else if (strut_profile == 1) {
        // Aerodynamic Diamond Profile (Symmetric top and bottom)
        translate([0, 0, plate_thickness - strut_thickness])
            rotate([90, 0, 90])
                linear_extrude(height = fan_airflow_dia, center = true)
                    polygon(points = [
                        [0, -strut_width/2],        // Bottom center trailing edge
                        [strut_thickness/2, 0],     // Right vertex
                        [strut_thickness, 0],       // Top center leading edge
                        [-strut_thickness/2, 0]     // Left vertex
                    ]);
    } else {
        // Standard Rectangular Profile
        translate([-fan_airflow_dia/2, -strut_width/2, plate_thickness - strut_thickness])
            cube([fan_airflow_dia, strut_width, strut_thickness]);
    }
}

// --- MAIN ASSEMBLY ---
difference() {
    union() {
        // Main Base Plate
        translate([-total_width/2, -fan_outer_size/2, 0])
            cube([total_width, fan_outer_size, plate_thickness]);
        
        // Left Side Wall and Inward Locking Lip
        translate([-(heatsink_width/2 + moulding_wall_thick), -fan_outer_size/2, -total_height])
            cube([moulding_wall_thick + groove_tongue_inward - clearance, fan_outer_size, total_height]);
        
        // Right Side Wall and Inward Locking Lip
        translate([heatsink_width/2 - groove_tongue_inward + clearance, -fan_outer_size/2, -total_height])
            cube([moulding_wall_thick + groove_tongue_inward - clearance, fan_outer_size, total_height]);
            
        // Cylindrical Upper Bosses for Screw Engagement
        translate([fan_hole_spacing/2, fan_hole_spacing/2, plate_thickness])
            cylinder(d = screw_boss_dia, h = screw_boss_height);
        translate([-fan_hole_spacing/2, fan_hole_spacing/2, plate_thickness])
            cylinder(d = screw_boss_dia, h = screw_boss_height);
        translate([fan_hole_spacing/2, -fan_hole_spacing/2, plate_thickness])
            cylinder(d = screw_boss_dia, h = screw_boss_height);
        translate([-fan_hole_spacing/2, -fan_hole_spacing/2, plate_thickness])
            cylinder(d = screw_boss_dia, h = screw_boss_height);
    }
    
    // Central Airflow Borehole
    translate([0, 0, -total_height - 1])
        cylinder(d = fan_airflow_dia, h = total_height + plate_thickness + screw_boss_height + 2);
    
    // Core Sliding Channel Clearance (Milled track for the heatsink base)
    translate([-heatsink_width/2 - clearance, -fan_outer_size/2 - 1, -groove_depth_from_top])
        cube([heatsink_width + (clearance * 2), fan_outer_size + 2, groove_depth_from_top + 1]);
        
    // Continuous Screw Holes (Drilled straight through bosses and plate)
    translate([fan_hole_spacing/2, fan_hole_spacing/2, -total_height - 1])
        cylinder(d = screw_hole_dia, h = total_height + plate_thickness + screw_boss_height + 2);
        
    translate([-fan_hole_spacing/2, fan_hole_spacing/2, -total_height - 1])
        cylinder(d = screw_hole_dia, h = total_height + plate_thickness + screw_boss_height + 2);
        
    translate([fan_hole_spacing/2, -fan_hole_spacing/2, -total_height - 1])
        cylinder(d = screw_hole_dia, h = total_height + plate_thickness + screw_boss_height + 2);
        
    translate([-fan_hole_spacing/2, -fan_hole_spacing/2, -total_height - 1])
        cylinder(d = screw_hole_dia, h = total_height + plate_thickness + screw_boss_height + 2);
}

rotate([0, 0, 45])
    generate_strut();
        
rotate([0, 0, -45])
    generate_strut();

