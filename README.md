# Interface to Module port converter

-----------------------------------------

## About

Some simulators like verilator and fex Xilinx IPs do not support having an interface on the top module. This Tcl script is to generate a wrapper to such modules have conventional verilog-style signals. The script assumes that the interface is in a separate file with ONLY in one of the formats. **EXECUTION IS NOT GUARANTEED** in other coding styles

`interface sample_ifc;`
`    logic a;`
`   logic [1:0] b;`
`    modport id (`
`        input a,`
`        output b`
`    );`
`endinterface //sample_ifc`
**OR**
`interface sample_ifc;`
`    logic a;`
`    logic [1:0] b;`
`    modport id (input a, output b);`
`endinterface //sample_ifc`

## Usage

`ifc2mod.tcl` <interface_file_name> <module_name> <modport_name> <comb>

## Scope

This script has been primarily used to support my work on the repository `alu-cores`. For now, it supports the wrapper generation for those interfaces only with signals and modports. Other elements like structs, enums, typedefs, functions and tasks, nested interfaces are **not supported**. I shall add more features as I require them. Contributions and ideas for the betterment of the script are welcome
