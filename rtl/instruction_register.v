`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.08.2026 03:27:04
// Design Name: 
// Module Name: instruction_register
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


module instruction_register #(parameter size = 4)(

input TCK,
input TRST,
input TDI,

input shift_ir,
input update_ir,
input capture_ir,

output  TDO,
output reg [size - 1: 0] instruction

    );
    localparam IDCODE_OPCODE = 4'b0001; //assumes 4 bit IR   [BETTER TO CHANGE FOR PARAMETERIZATION]
    localparam BYPASS_OPCODE = 4'b1010;
    reg [size - 1:0] shift_reg;
    //reg [size-1:0] instruction_reg;
    
    
    always @ (posedge TCK or negedge TRST) begin
        if(!TRST) begin
            shift_reg <= 0;
            instruction <= IDCODE_OPCODE;
            
        end
        else if (capture_ir)
                    shift_reg <= instruction;
        
        else if (shift_ir) begin
            shift_reg <= {TDI,shift_reg[size-1:1]};
           
        end
        else if (update_ir) begin
            
            instruction <= shift_reg;
        end
        
    end
    
    assign TDO = shift_reg[0];
    
endmodule
