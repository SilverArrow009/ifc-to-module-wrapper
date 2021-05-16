# Interface to Module port converter

-----------------------------------------

## About

Some simulators like verilator and few Xilinx IPs do not support having a SystemVerilog interface on the top module. This Tcl script is to generate a wrapper to such modules have conventional verilog-style signals. The script assumes that the interface is in a separate file with ONLY in one of the formats. **EXECUTION IS NOT GUARANTEED** in other coding styles

```verilog
interface sample_ifc;`
    logic a;
    logic [1:0] b;
    modport id (
    input a,
    output b
    );
endinterface //sample_ifc
```

**OR**

```verilog
interface sample_ifc;
    logic a;
    logic [1:0] b;
    modport id (input a, output b);
endinterface //sample_ifc
```

## Usage

`ifc2mod.tcl interface_file_name.sv module_name modport_name comb`

- `interface_file_name.sv` is the file containing the interface
- `module_name` is the name of the module we wish to generate the wrapper
- `modport_name` is the modport used by `module_name` defined in `interface_file_name.sv`
- `comb` is either a `0 or 1`. It dictates if the mapping between module signals and interfaces are combinatorial or sequential in nature. you should use `1` if you are generating the wrapper for a combinatorial circuit (such as full adder) or `0` otherwise. The `always_ff` block is triggered at `posedge clk`. Please make sure you **update the clock signal name, clock polarity and sensitivity list** according to your requirement.  

## Scope

This script has been primarily used to support my work on the repository `alu-cores`. For now, it supports the wrapper generation for those interfaces only with signals and modports. Other elements like structs, enums, typedefs, functions and tasks, nested interfaces are **not supported**. I shall add more features as I require them. Contributions and ideas for the betterment of the script are welcome
