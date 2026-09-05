`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.08.2026 05:30:41
// Design Name: 
// Module Name: JTAG_tap
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module JTAG_tap(
input TCK,
input TRST,
input TDI,
output TDO,
input TMS
    );
  
  wire shift_ir,capture_ir, update_ir,shift_dr,capture_dr, update_dr;
  tap_fsm FSM(TCK, TMS, TRST, shift_ir, capture_ir,  update_ir, shift_dr, capture_dr, update_dr);
  
    wire ir_tdo;
    wire [3:0] instr;
    instruction_register IR (TCK, TRST, TDI, shift_ir, update_ir, capture_ir,ir_tdo, instr);
    
    wire bypass_sel;
    wire idcode_sel;
    Instruction_Decoder ID (instr,
    bypass_sel,
    idcode_sel);
    
    wire idcode_tdo;
    IDCODE_Register IDR(TCK,
    TRST,
    TDI,
    shift_dr,
    capture_dr,
    update_dr,
    idcode_sel,
    idcode_tdo
    );
    
    wire bypass_tdo;
    BYPASS_register BPR (TCK,
    TRST,
    TDI,
    shift_dr,
    capture_dr,
    update_dr,
    bypass_sel,
    bypass_tdo);
    
    TDO_Mux MUX(idcode_tdo,bypass_tdo,TDO,idcode_sel,bypass_sel,ir_tdo,shift_ir);
    
    
    
endmodule
