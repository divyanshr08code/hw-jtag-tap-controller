`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.08.2026 05:12:18
// Design Name: 
// Module Name: TDO_Mux
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


module TDO_Mux(
input idcode_TDO,
input bypass_TDO,
output reg TDO,
input idcode_sel,
input bypass_sel,
input ir_tdo,

input shift_ir
    );
    
    always @ (*) begin
        if(shift_ir)
            TDO = ir_tdo;
        else if(idcode_sel ) 
            TDO = idcode_TDO;
        else if (bypass_sel)
            TDO = bypass_TDO;
        else
            TDO = 0;
            
    end
endmodule
