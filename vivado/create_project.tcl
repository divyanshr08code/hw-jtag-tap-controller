# Recreate the JTAG TAP Controller Vivado project from the GitHub repository.
# Run from the repository root with Vivado in batch mode or source this file in Vivado.

set repo_root [file normalize [file join [file dirname [info script]] ..]]
set project_dir [file join $repo_root vivado generated]
set project_name "JTAG_TAP_Controller"
set part "xczu7ev-ffvc1156-2-e"

file mkdir $project_dir

create_project $project_name $project_dir -part $part -force

add_files [glob -nocomplain [file join $repo_root rtl *.v]]
add_files -fileset sim_1 [file join $repo_root tb tap_tb.v]

set_property top JTAG_tap [get_filesets sources_1]
set_property top tap_tb [get_filesets sim_1]

update_compile_order -fileset sources_1
update_compile_order -fileset sim_1

puts "JTAG TAP Controller project created at: $project_dir"
