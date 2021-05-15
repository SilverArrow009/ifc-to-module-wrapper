#!/usr/bin/tclsh
# read the interface file
set fp [open [lindex $argv 0] "r"]
set lock 0

while {[gets $fp line] >= 0} {\
    if {[regexp {interface.*;} $line]} {\
        set ifname [string trim [lindex [regexp -inline {interface (.*);} $line] 1]]
    }
    if {[regexp {logic | bit| wire | reg} $line]} {\
        lappend terms $line
    } elseif {[regexp {modport .*;} $line]} {\
        lappend modport [lindex [regexp -inline {modport (.*) \((.*)\);} $line] 1] [lindex [regexp -inline {modport (.*) \((.*)\);} $line] 2]
        # modport contains modport name and ports as list
    } elseif {[regexp {modport .*} $line]} {\
        lappend modport [lindex [regexp -inline {modport (.*) \(} $line] 1]
        set port_string ""
        set lock 1
    }
    if {[regexp {input|output} $line] && ($lock == 1)} {\
        set port_string [concat $port_string "_DEL_" $line]
    } elseif {[regexp {\);} $line] && ($lock == 1)} {\
        lappend modport $port_string;
    }
}

close $fp
puts $modport
set mp_name [lindex $argv 2]
array set modport_arr $modport

if {$lock} {\
    set port_list [split $modport_arr($mp_name) "_DEL_"]
} else {\
    set port_list $modport_arr($mp_name)
}

foreach term $terms {\
    lappend term_names [lindex [regexp -inline {.* (.*);} [string trim $term]] 1]
}
# bit to generate combinational or sequential logic for wrapper
set comb [lindex $argv 3]

# Create the hdl wrapper

set mod_name [lindex $argv 1]
set file_name "$mod_name\_wrapper.sv"
set fp [open $file_name "w"]

# Output
# Format module ports in single line or multi line format
if {$lock == 1} {\
    lappend data "module $mod_name ("
    foreach port $port_list {\
        lappend data $port
    }
    lappend data ");\n"
} else {\
    lappend data "module $mod_name ($port_list);\n"
}
# Redeclaration of all the ports. uncomment to print, but may cause errors in generated output
# foreach port $terms {\
#     lappend data $port
# }
lappend data "\n\t$ifname if0;"

if {$comb} {\
    lappend data "\n\talways_comb begin"
} else {\
    lappend data "\n\talways_ff @(posedge clk) begin"
}
foreach term $term_names {\
    lappend data "\t\tif0.$term\t=\t$term;"
}
lappend data "\tend\n"
lappend data "\t[concat $mod_name "inst0 (if0.$mp_name);"]\n"
lappend data "endmodule : $mod_name"

#Write the data and close the file
foreach line $data {\
    puts $fp $line
}
close $fp