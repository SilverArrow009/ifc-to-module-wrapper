#!/usr/bin/tclsh
# read the interface file
set fp [open [lindex $argv 0] "r"]
set lock 0
array set lock_arr {}

while {[gets $fp line] >= 0} {\
    if {[regexp {interface.*;} $line]} {\
        set ifname [string trim [lindex [regexp -inline {interface (.*);} $line] 1]]
    }
    if {[regexp {logic | bit| wire | reg} $line]} {\
        lappend terms $line
    } elseif {[regexp {modport .*;} $line]} {\
        set lock 0
        lappend modport [lindex [regexp -inline {modport (.*) \((.*)\);} $line] 1] [lindex [regexp -inline {modport (.*) \((.*)\);} $line] 2]
        set lock_arr([lindex [regexp -inline {modport (.*) \((.*)\);} $line] 1]) $lock
        # modport contains modport name and ports as list
    } elseif {[regexp {modport .*} $line]} {\
        lappend modport [lindex [regexp -inline {modport (.*) \(} $line] 1]
        set port_string ""
        set lock 1
        set lock_arr([lindex [regexp -inline {modport (.*) \(} $line] 1]) $lock
    }
    if {[regexp {input|output} $line] && ($lock == 1)} {\
        set port_string [concat $port_string "*" $line]
    } elseif {[regexp {\);} $line] && ($lock == 1)} {\
        lappend modport [string trimleft $port_string "*"]
    }
}

close $fp
set mp_name [lindex $argv 2]
array set modport_arr $modport
set lock $lock_arr($mp_name)
array set dir_of {}
array set type_of {}

if {$lock} {\
    set port_list [split $modport_arr($mp_name) "*"]
    foreach tmp $port_list {\
        set tmp [string trim $tmp ", "]
        set tmp_lst1 [split $tmp " "]
        set dir_of([lindex $tmp_lst1 1]) [lindex $tmp_lst1 0]
        lappend active_term_names [lindex $tmp_lst1 1]
    }
} else {\
    set port_list $modport_arr($mp_name)
    set tmp_lst [split $port_list ","]
    foreach tmp $tmp_lst {\
        set tmp [string trim $tmp]
        set tmp_lst1 [split $tmp " "]
        set dir_of([lindex $tmp_lst1 1]) [lindex $tmp_lst1 0]
        lappend active_term_names [lindex $tmp_lst1 1]     
    }
}
#debug parray dir_of
foreach term $terms {\
    set match_str [lindex [regexp -inline {.* (.*);} [string trim $term]] 1]
    set match_str "$match_str;"
    set blank ""
    regsub -all $match_str $term $blank type
    set type_of([string trimright $match_str ";"]) $type
}
#debug parray type_of
# bit to generate combinational or sequential logic for wrapper
set comb [lindex $argv 3]

# Create the hdl wrapper

set mod_name [lindex $argv 1]
set file_name "$mod_name\_wrapper.sv"
set fp [open $file_name "w"]

# Output
# Format module ports in single line or multi line format

lappend data "module $mod_name\_wrapper ("
foreach term $active_term_names {\
    lappend data "\t$dir_of($term) $type_of($term) $term,"
}
set temp [string trimright [lindex $data end] ","]
set data [lreplace $data end end $temp]
lappend data ");\n"
lappend data "\n\t$ifname if0;"

if {$comb} {\
    lappend data "\n\talways_comb begin"
} else {\
    lappend data "\n\talways_ff @(posedge clk) begin"
}
foreach term $active_term_names {\
    lappend data "\t\tif0.$term\t=\t$term;"
}
lappend data "\tend\n"
lappend data "\t[concat $mod_name "inst0 (if0.$mp_name);"]\n"
lappend data "endmodule : $mod_name\_wrapper"

#Write the data and close the file
foreach line $data {\
    puts $fp $line
}
close $fp