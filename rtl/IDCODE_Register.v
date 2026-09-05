`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.08.2026 04:50:08
// Design Name: 
// Module Name: IDCODE_Register
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


module IDCODE_Register(
    
    input TCK,
    input TRST,
    input TDI,
    
    input shift_dr,
    input capture_dr,
    input update_dr,
    input idcode_sel,
    output TDO
    
    );
    
    localparam [31:0] IDCODE_Val = 32'h12345678;
    
    reg [31:0] shift_reg;
    
    
    always @ (posedge TCK or negedge TRST) begin
        if(!TRST)
            shift_reg <= 0;
        else if (capture_dr && idcode_sel)
            shift_reg <= IDCODE_Val;
        else if (shift_dr && idcode_sel) begin
            shift_reg <= {TDI,shift_reg[31:1]};
            end
        end
        
    assign TDO = shift_reg[0];
    
    
endmodule
