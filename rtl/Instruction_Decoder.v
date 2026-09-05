`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.08.2026 04:11:25
// Design Name: 
// Module Name: Instruction_Decoder
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


module Instruction_Decoder #(parameter IR_WIDTH = 4)(
input[IR_WIDTH-1:0] instr,

output bypass_sel,
output idcode_sel
    );
    localparam [IR_WIDTH-1:0] BYPASS = 4'b1010;
    localparam [IR_WIDTH-1:0] IDCODE = 4'b0001;
    assign bypass_sel = instr == BYPASS;
    assign idcode_sel = instr == IDCODE;
    
    
endmodule
