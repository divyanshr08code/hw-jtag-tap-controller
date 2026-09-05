`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.08.2026 05:03:44
// Design Name: 
// Module Name: BYPASS_register
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


module BYPASS_register(
input TCK,
input TRST,
input TDI,

input shift_dr,
input capture_dr,
input update_dr,
input bypass_sel,
output TDO

    );
    
    reg bypass_ff;
    
    always @ (posedge TCK or negedge TRST) begin
    
        if(!TRST) 
            bypass_ff <= 0;
        else if (capture_dr && bypass_sel) 
            bypass_ff <= 0;
        else if (shift_dr && bypass_sel)
            bypass_ff <= TDI; 
    end
    
    assign TDO = bypass_ff;
    
endmodule
