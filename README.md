Some simulators like verilator and fex Xilinx IPs do not support having an interface on the top module. This tcl script is to generate a wrapper to such modules so they can be used to simulate in verilator.
This script has been primarily used to support my work on the repository alu-cores. I shall add more features as I require them. Contributions and ideas for the betterment of the script are most welcome.
---------------------------
The script assumes that the interface is in a separate file with ONLY in one of the formats. EXECUTION NOT GUARANTEED in other coding styles.

interface sample_ifc;
    logic a;
    logic [1:0] b;
    modport id (
        input a,
        output b
    );
endinterface //sample_ifc

interface sample_ifc;
    logic a;
    logic [1:0] b;
    modport id (input a, output b);
endinterface //sample_ifc

Usage:
    ifc2mod.tcl <interface_file_name> <module_name> <modport_name> <comb>