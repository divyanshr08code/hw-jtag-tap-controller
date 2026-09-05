# JTAG TAP Controller — Verilog RTL

A synthesizable Verilog implementation of a **JTAG Test Access Port (TAP) controller** based on the IEEE 1149.1 TAP state-machine concept.

The project implements the TAP finite-state machine, instruction register, instruction decoding, IDCODE and BYPASS data registers, and a TDO multiplexer. A self-checking Verilog testbench exercises the major TAP transitions and verifies IDCODE and BYPASS operation.

## Features

- 16-state JTAG TAP controller FSM
- Asynchronous active-low test reset (`TRST`)
- 4-bit instruction register
- `IDCODE` instruction: `4'b0001`
- `BYPASS` instruction: `4'b1010`
- 32-bit IDCODE value: `32'h12345678`
- IDCODE capture and serial shifting through TDI/TDO
- 1-bit BYPASS register
- Instruction decoder and data-path selection
- TDO multiplexer for instruction/data shifting
- Self-checking Verilog testbench

## Architecture

```text
                    +----------------+
        TCK ------>|                |
        TMS ------>|    TAP FSM     |---- capture/shift/update controls
        TRST ----->|                |
                    +-------+--------+
                            |
                            v
                    +---------------+
        TDI ------->| Instruction   |----> Instruction
                    | Register      |          |
                    +-------+-------+          v
                            |           +---------------+
                            +---------->| Instruction   |
                                        | Decoder       |
                                        +---+-------+---+
                                            |       |
                                      IDCODE |       | BYPASS
                                            v       v
                                      +-----+--+ +--+-----+
                                      | IDCODE | | BYPASS |
                                      |  Reg   | |  Reg   |
                                      +----+---+ +---+----+
                                           |         |
                                           +----+----+
                                                v
                                           +---------+
                                           | TDO Mux |
                                           +----+----+
                                                |
                                                v
                                               TDO
```

## Repository Structure

```text
JTAG-TAP-Controller/
├── README.md
├── .gitignore
├── rtl/
│   ├── JTAG_tap.v
│   ├── tap_fsm.v
│   ├── instruction_register.v
│   ├── Instruction_Decoder.v
│   ├── IDCODE_Register.v
│   ├── BYPASS_register.v
│   └── TDO_Mux.v
├── tb/
│   └── tap_tb.v
└── vivado/
    └── JTAG_TAP_Controller.xpr
```

## RTL Modules

| Module | Purpose |
|---|---|
| `JTAG_tap` | Top-level integration of the TAP controller and data paths |
| `tap_fsm` | Implements the 16-state JTAG TAP state machine |
| `instruction_register` | Captures, shifts, and updates the active instruction |
| `Instruction_Decoder` | Generates `IDCODE` and `BYPASS` select signals |
| `IDCODE_Register` | 32-bit IDCODE capture and serial shift register |
| `BYPASS_register` | 1-bit BYPASS data register |
| `TDO_Mux` | Selects the source driving TDO |
| `tap_tb` | Self-checking simulation testbench |

## TAP State Machine

The controller contains the standard 16 TAP states:

```text
Test-Logic-Reset
      |
Run-Test/Idle
      |
Select-DR-Scan --> Capture-DR --> Shift-DR --> Exit1-DR
      |                                      |
      |                                      v
      |                                  Pause-DR
      |                                      |
      |                                      v
      |                                  Exit2-DR
      |                                      |
      +------------------------------ Update-DR

Run-Test/Idle --> Select-DR-Scan --> Select-IR-Scan
                                      |
                                      v
                                  Capture-IR
                                      |
                                      v
                                   Shift-IR
                                      |
                                      v
                                  Exit1-IR
                                      |
                                      v
                                   Pause-IR
                                      |
                                      v
                                   Exit2-IR
                                      |
                                      v
                                  Update-IR
```

The actual state transitions are controlled by `TMS` sampled on the rising edge of `TCK`, while `TRST` asynchronously forces the FSM into `Test-Logic-Reset`.

## Instruction/Data Flow

After an instruction is shifted into the instruction register and updated:

- `4'b0001` selects the IDCODE register.
- `4'b1010` selects the BYPASS register.
- During `SHIFT_IR`, the instruction register drives TDO.
- During data shifting, the selected data register drives TDO.

The current implementation uses `32'h12345678` as the IDCODE value for demonstration and verification.

## Verification

The testbench `tb/tap_tb.v` performs the following checks:

1. TAP reset
2. Transition to `SHIFT_IR`
3. Loading the `IDCODE` instruction (`0001`)
4. Instruction decoder verification
5. IDCODE capture
6. Serial shifting of the first eight IDCODE bits (`0x78`)
7. Loading the `BYPASS` instruction (`1010`)
8. BYPASS data-path verification
9. Final pass/fail summary using an error counter

The testbench is written to be self-checking: failures increment an error counter and the simulation reports the final test status.

## Running in Vivado

1. Open Vivado.
2. Open `vivado/JTAG_TAP_Controller.xpr`.
3. Ensure `rtl/` files are added as design sources and `tb/tap_tb.v` is added as the simulation source if Vivado does not resolve the relocated paths automatically.
4. For the most portable setup, source `vivado/create_project.tcl` to recreate the project from `rtl/` and `tb/`.
5. Alternatively, open `vivado/JTAG_TAP_Controller.xpr`; because the original `.xpr` was generated on another machine, Vivado may prompt you to relocate or re-add the source files.
6. Set `JTAG_tap` as the design top and `tap_tb` as the simulation top.
7. Run **Run Simulation → Run Behavioral Simulation**.
8. Inspect the console for the test summary and the waveform for `TCK`, `TMS`, `TDI`, and `TDO`.

> Note: Generated Vivado directories are intentionally excluded from version control. `vivado/create_project.tcl` is the canonical reproducible way to recreate the project.

## Tools

- Verilog HDL
- AMD/Xilinx Vivado
- XSim

## Future Improvements

Possible extensions for a more complete JTAG implementation include:

- Standard JTAG `BYPASS`, `IDCODE`, and additional IEEE 1149.1 instructions
- More rigorous instruction-register capture behavior
- A parameterized IDCODE/register architecture
- Explicit assertions for TAP state-transition verification
- Functional coverage for all 16 TAP states and transitions
- Boundary-scan register and `EXTEST` support
- Improved TDO timing aligned with the JTAG interface specification
- Automated simulation using a simulator-independent build flow

## License

This project is provided for educational and portfolio purposes. Add a project-specific license before redistributing it as open-source software.
