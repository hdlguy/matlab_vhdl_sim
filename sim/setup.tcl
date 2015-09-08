# This file sets up the simulation environment.
create_project -part xc7a50t-ftg256-1 -force proj 
set_property target_language VHDL [current_project]
set_property "default_lib" "work" [current_project]
create_fileset -simset simset

read_ip [ glob ../ip/halfband0/halfband0.xci ]
generate_target {all} [get_ips *]

add_files -fileset simset [glob ../hdl/halfband0_matlab_tb.vhd]

current_fileset -simset [ get_filesets simset ]

set_property -name {xsim.elaborate.debug_level} -value {all} -objects [current_fileset -simset]
set_property -name {xsim.simulate.runtime} -value {600ns} -objects [current_fileset -simset]

close_project


