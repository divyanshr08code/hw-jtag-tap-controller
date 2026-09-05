`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.08.2026 01:28:40
// Design Name: 
// Module Name: tap_fsm
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


module tap_fsm(
input TCK, input TMS, input TRST, output shift_ir, output capture_ir, output update_ir,output shift_dr, output capture_dr, output update_dr
    );
    reg [3:0] state,next_state;
    localparam [3:0] RESET = 4'b0000, 
    RUN_TEST_IDLE = 4'b0001, 
    SELECT_IR = 4'b0010,
    CAPTURE_IR = 4'b0011,
    SHIFT_IR = 4'b0100,
    UPDATE_IR = 4'b0101,
    EXIT1_IR = 4'b0110,
    PAUSE_IR = 4'b0111,
    EXIT2_IR = 4'b1000,
    SELECT_DR = 4'b1001,
    CAPTURE_DR = 4'b1010,
    SHIFT_DR = 4'b1011,
    UPDATE_DR = 4'b1100,
    EXIT1_DR = 4'b1101,
    PAUSE_DR = 4'b1110,
    EXIT2_DR = 4'b1111;
    
    always @ (*) begin
        case(state)
          RESET: next_state = TMS ? RESET: RUN_TEST_IDLE;
          RUN_TEST_IDLE: next_state = TMS ? SELECT_DR: RUN_TEST_IDLE;
          SELECT_DR: next_state = TMS ? SELECT_IR:CAPTURE_DR;
          CAPTURE_DR: next_state = TMS ? EXIT1_DR: SHIFT_DR;
          SHIFT_DR: next_state = TMS ? EXIT1_DR: SHIFT_DR;
          EXIT1_DR: next_state = TMS ? UPDATE_DR: PAUSE_DR;
          PAUSE_DR: next_state = TMS ? EXIT2_DR: PAUSE_DR;
          EXIT2_DR: next_state = TMS ? UPDATE_DR: SHIFT_DR;
          UPDATE_DR: next_state = TMS ? SELECT_DR: RUN_TEST_IDLE;
          SELECT_IR: next_state = TMS ? RESET:CAPTURE_IR;
          CAPTURE_IR: next_state = TMS ? EXIT1_IR: SHIFT_IR;
          SHIFT_IR: next_state = TMS ? EXIT1_IR: SHIFT_IR;
        EXIT1_IR: next_state = TMS ? UPDATE_IR: PAUSE_IR;
        PAUSE_IR: next_state = TMS ? EXIT2_IR: PAUSE_IR;
        EXIT2_IR: next_state = TMS ? UPDATE_IR: SHIFT_IR;
        UPDATE_IR: next_state = TMS ? SELECT_DR: RUN_TEST_IDLE;
        default: next_state = RESET;
       endcase
            
    
    end
    
    
        
    always @ (posedge TCK or negedge TRST) begin
    
        if(!TRST) begin
              state <=   RESET;
            end
        else begin
            state <= next_state;
        end
    end
    
    assign shift_ir = state == SHIFT_IR;
    assign capture_ir = state == CAPTURE_IR;
    assign update_ir =  state == UPDATE_IR;
    assign shift_dr = state == SHIFT_DR;
    assign capture_dr = state ==CAPTURE_DR;
    assign update_dr = state == UPDATE_DR;
    
endmodule
