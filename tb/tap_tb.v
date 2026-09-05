`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.08.2026 05:48:08
// Design Name: 
// Module Name: tap_tb
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


module tap_tb(
);

reg TCK;
reg TMS;
reg TDI;
reg TRST;

wire TDO;

integer errors = 0;
integer i;

//--------------------------------------------
// DUT
//--------------------------------------------

JTAG_tap DUT(
    .TCK(TCK),
    .TRST(TRST),
    .TDI(TDI),
    .TDO(TDO),
    .TMS(TMS)
);

//--------------------------------------------
// Clock
//--------------------------------------------

always #5 TCK = ~TCK;

//--------------------------------------------
// Apply one TCK cycle
//--------------------------------------------

task jtag_clock;

input tms;
input tdi;

begin

    TMS = tms;
    TDI = tdi;

    @(posedge TCK);
    #1;

end

endtask;

//--------------------------------------------
// Reset
//--------------------------------------------

task reset_tap;

begin

TRST = 0;

repeat(2)
@(posedge TCK);

TRST = 1;

end

endtask;

task check_reset;

begin

$display("--------------------------------");
$display("Checking Reset...");
$display("--------------------------------");

reset_tap();

if(DUT.FSM.state != 4'b0000)
begin
    $display("FAIL : Reset");
    errors = errors + 1;
end
else
begin
    $display("PASS : Reset");
end

end

endtask;

task goto_shift_ir;

begin

// RESET -> IDLE

jtag_clock(0,0);

if(DUT.FSM.state!=4'b0001)
begin
    $display("FAIL : IDLE");
    errors = errors+1;
end

// IDLE -> SELECT DR

jtag_clock(1,0);

if(DUT.FSM.state!=4'b1001)
begin
    $display("FAIL : SELECT_DR");
    errors=errors+1;
end

// SELECT DR -> SELECT IR

jtag_clock(1,0);

if(DUT.FSM.state!=4'b0010)
begin
    $display("FAIL : SELECT_IR");
    errors=errors+1;
end

// SELECT IR -> CAPTURE IR

jtag_clock(0,0);

if(DUT.FSM.state!=4'b0011)
begin
    $display("FAIL : CAPTURE_IR");
    errors=errors+1;
end

// CAPTURE IR -> SHIFT IR

jtag_clock(0,0);

if(DUT.FSM.state!=4'b0100)
begin
    $display("FAIL : SHIFT_IR");
    errors=errors+1;
end

$display("PASS : FSM Path to SHIFT_IR");

end

endtask;

//--------------------------------------------
// Load IDCODE Instruction (0001)
//--------------------------------------------

task load_idcode_instruction;

begin

$display("--------------------------------");
$display("Loading IDCODE Instruction...");
$display("--------------------------------");

// We are already in SHIFT_IR

// Shift LSB first because your IR outputs shift_reg[0]

// bit0 = 1
jtag_clock(0,1);

// bit1 = 0
jtag_clock(0,0);

// bit2 = 0
jtag_clock(0,0);

// Last bit -> Exit1_IR
jtag_clock(1,0);

if(DUT.FSM.state != 4'b0110)
begin
    $display("FAIL : EXIT1_IR");
    errors = errors + 1;
end

// Update IR
jtag_clock(1,0);

if(DUT.FSM.state != 4'b0101)
begin
    $display("FAIL : UPDATE_IR");
    errors = errors + 1;
end

// Back to Idle
jtag_clock(0,0);

if(DUT.FSM.state != 4'b0001)
begin
    $display("FAIL : RUN_TEST_IDLE");
    errors = errors + 1;
end

// Check instruction register

if(DUT.IR.instruction != 4'b0001)
begin
    $display("FAIL : Instruction Register");
    $display("Expected = 0001");
    $display("Actual   = %b",DUT.IR.instruction);
    errors = errors + 1;
end
else
begin
    $display("PASS : Instruction Register");
end

// Decoder

if(DUT.ID.idcode_sel != 1)
begin
    $display("FAIL : IDCODE Decoder");
    errors = errors + 1;
end
else
begin
    $display("PASS : Decoder");
end

end

endtask;

//--------------------------------------------
// Capture IDCODE Register
//--------------------------------------------

task capture_idcode;

begin

$display("--------------------------------");
$display("Capturing IDCODE...");
$display("--------------------------------");

// Idle -> Select DR

jtag_clock(1,0);

// Select DR -> Capture DR

jtag_clock(0,0);

if(DUT.FSM.state!=4'b1010)
begin
    $display("FAIL : CAPTURE_DR");
    errors = errors + 1;
end
#1;
$display("IDCODE Register = %h", DUT.IDR.shift_reg);
// Shift DR

jtag_clock(0,0);

if(DUT.FSM.state!=4'b1011)
begin
    $display("FAIL : SHIFT_DR");
    errors = errors + 1;
end

end

endtask;

//--------------------------------------------
// Shift first 8 bits
//--------------------------------------------

task shift_idcode;

reg [7:0] expected;

begin

expected = 8'h78;

$display("--------------------------------");
$display("Shifting IDCODE...");
$display("--------------------------------");

for(i=0;i<8;i=i+1)
begin

    if(TDO != expected[i])
    begin
        $display("FAIL : IDCODE bit %0d",i);
        errors = errors + 1;
    end

    jtag_clock(0,0);

end

    jtag_clock(1,0); // SHIFT_DR -> EXIT1_DR
    jtag_clock(1,0); // EXIT1_DR -> UPDATE_DR
    jtag_clock(0,0); // UPDATE_DR -> RUN_TEST_IDLE
$display("PASS : IDCODE Shift");

end

endtask;

//--------------------------------------------
// Load BYPASS Instruction
//--------------------------------------------

task load_bypass_instruction;

begin

$display("--------------------------------");
$display("Loading BYPASS...");
$display("--------------------------------");

// Idle -> Select DR
jtag_clock(1,0);

// Select DR -> Select IR
jtag_clock(1,0);

// Capture IR
jtag_clock(0,0);

// Shift IR
jtag_clock(0,0);

// 1010
// LSB first

jtag_clock(0,0);   // bit0
jtag_clock(0,1);   // bit1
jtag_clock(0,0);   // bit2
jtag_clock(1,1);   // bit3 + Exit1

// Update IR

jtag_clock(1,0);

// Idle

jtag_clock(0,0);
#1;
$display("Instruction = %b", DUT.IR.instruction);
$display("Bypass Sel = %b", DUT.ID.bypass_sel);
if(DUT.ID.bypass_sel != 1)
begin
    $display("FAIL : BYPASS Decoder");
    errors = errors + 1;
end
else
begin
    $display("PASS : BYPASS Decoder");
end

end

endtask;

//--------------------------------------------
// Verify BYPASS
//--------------------------------------------

task verify_bypass;

begin

$display("--------------------------------");
$display("Checking BYPASS...");
$display("--------------------------------");

// Idle -> Select DR

jtag_clock(1,0);

// Capture DR

jtag_clock(0,0);

// Shift DR

jtag_clock(0,0);

// Send a '1'

jtag_clock(0,1);

// Next clock should output previous value


if(TDO != 1'b1)
begin
    $display("FAIL : BYPASS Shift");
    errors = errors + 1;
end
else
begin
    $display("PASS : BYPASS");
end
jtag_clock(1,0); // SHIFT_DR -> EXIT1_DR
jtag_clock(1,0); // EXIT1_DR -> UPDATE_DR
jtag_clock(0,0); // UPDATE_DR -> RUN_TEST_IDLE
end

endtask;

//--------------------------------------------
// Main Test
//--------------------------------------------

initial
begin

TCK = 0;
TMS = 0;
TDI = 0;
TRST = 1;

check_reset();

goto_shift_ir();

load_idcode_instruction();

capture_idcode();

shift_idcode();

load_bypass_instruction();

verify_bypass();

$display("");
$display("=================================");
$display("      TEST SUMMARY");
$display("=================================");

if(errors==0)
begin
    $display("");
    $display(" ALL TESTS PASSED ");
    $display("");
end
else
begin
    $display("");
    $display(" TEST FAILED ");
    $display("Errors = %0d",errors);
    $display("");
end

$finish;

end

endmodule