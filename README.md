<div align="center">

  ### 🎓 ELC3030 — Advanced Microprocessor — Cairo University

</div>

<div align="center">
  <h1 align="center">8-bit 5-Stage Pipelined RISC Processor</h1>
  <p align="center">
    <strong>RTL design, hazard resolution, and ASIC synthesis of a fully pipelined 8-bit RISC processor — transformed from a single-cycle baseline into a 5-stage pipeline with data forwarding, hazard detection, and interrupt support.</strong>
  </p>

  [![HDL](https://img.shields.io/badge/HDL-Verilog-blue.svg)](#-rtl-architecture)
  [![Simulator](https://img.shields.io/badge/Simulator-ModelSim-brightgreen.svg)](#-verification)
  [![ASIC](https://img.shields.io/badge/ASIC-TSMC_130nm-success.svg)](#-synthesis-results)
  [![Timing](https://img.shields.io/badge/Timing-Setup_%26_Hold_Met-orange.svg)](#-synthesis-results)
  [![Course](https://img.shields.io/badge/Course-ELC3030-lightgrey.svg)](#-project-overview)
</div>

<br />

## 📖 Table of Contents
- [Project Overview](#-project-overview)
- [Team Members](#-team-members)
- [From Single-Cycle to Pipelined](#-from-single-cycle-to-pipelined)
- [RTL Architecture](#-rtl-architecture)
- [Control Unit Design](#-control-unit-design)
- [Hazard Handling](#-hazard-handling)
- [Instruction Set Summary](#-instruction-set-summary)
- [Repository Structure](#-repository-structure)
- [How to Run](#-how-to-run)
- [Verification](#-verification)
- [Synthesis Results](#-synthesis-results)
- [Resources](#-resources)

<br />

## 🚀 Project Overview

This repository contains the complete **RTL design, functional verification, and ASIC synthesis** of an 8-bit RISC processor built for the ELC3030 (Advanced Microprocessor) course project at Cairo University. The processor was first implemented as a single-cycle datapath, then re-architected into a genuine **5-stage pipeline** (Fetch → Decode → Execute → Memory → Writeback) to improve instruction throughput while preserving full ISA compatibility.

The design implements the complete RISC-like ISA specified in the course project (32 instructions across A/B/L instruction formats), a single non-maskable interrupt with atomic 2-byte instruction handling, and a stack-based subroutine/interrupt mechanism — all resolved for pipeline hazards via dedicated **Forwarding** and **Hazard Detection** units.

### Key Specifications
- **ISA:** RISC-like, 1-byte and 2-byte variable-length instructions, 4 general-purpose 8-bit registers (`R0–R3`, with `R3` as SP), 256-byte byte-addressable unified memory.
- **Pipeline:** Classic 5-stage (IF → ID → EX → MEM → WB) with 4 pipeline registers (IF/ID, ID/EX, EX/MEM, MEM/WB).
- **Hazard Resolution:** Full data forwarding (EX/MEM → EX, MEM/WB → EX) plus a Hazard Detection Unit for load-use stalls and control-flow flushing.
- **Interrupts:** Single non-maskable interrupt, serviced only in the FSM's idle state to guarantee atomic execution of 2-byte instructions.
- **Control Unit:** FSM-based (2-state: `ideal` / `S2`) combined with combinational decode logic to support variable-length instruction fetch.
- **Verification:** ModelSim-based self-checking testbench (`top_tb.v`) exercising all instruction formats, branching, interrupts, and load-use hazards.
- **Synthesis:** Synopsys Design Compiler flow on the TSMC 130nm standard-cell library across SS/TT/FF PVT corners — all setup and hold constraints met.

<br />

## 👥 Team Members

| Name |
|------|
| Ali Yasser Ali Sayed |
| Abdullah Nasser Hammada Mostafa |
| Moamen Salah Abdelmoneam Abdelkader |
| Karim Wael Mohamed Gomaa |
| Martin Ashraf Rgaey Fahim |
| Keroloss Arwehla Fathy Mosaad |

<br />

## 🔄 From Single-Cycle to Pipelined

The project started from a single-cycle 8-bit RISC CPU where Fetch, Decode, Execute, Memory, and Writeback all resolve within one long clock period — simple to verify, but clock-limited by the slowest instruction path (loads/stores).

To raise throughput, the datapath was restructured into 5 pipeline stages separated by pipeline registers, letting up to 5 instructions be in flight simultaneously. This introduced classic **data hazards** (an instruction needing a result still in flight) and **control hazards** (branches/interrupts with an unresolved next-PC), which are resolved by:

- A **Forwarding Unit** that bypasses ALU/memory results from `EX/MEM` and `MEM/WB` directly to the ALU inputs, avoiding unnecessary stalls.
- A **Hazard Detection Unit** that stalls the pipeline for one cycle on unavoidable load-use hazards and inserts bubbles.
- **Pipeline-aware control logic** that flushes wrong-path instructions on taken branches and interrupts.

<br />

## 🏗 RTL Architecture

The processor is composed of five pipeline stages, four pipeline registers, and several shared support modules, all wired together under `Processor_Top.v`.

| Module | File | Role |
|---|---|---|
| Fetch Stage | `FetchStage.v` | PC management, instruction fetch, next-PC mux (sequential / branch / return), reset & interrupt vectors |
| IF/ID Register | `IF_ID_reg.v` | Isolates Fetch from Decode; supports stall/flush/reset |
| Decode & Writeback | `decode_wb_stage.v` | Instruction parsing, register file reads, writeback mux integration, 2-byte instruction `rb` latching |
| ID/EX Register | `ID_EX_register.v` | Forwards 28 signals (operands, SP, all control signals) from Decode to Execute |
| Execute Stage | `Execute_stage.v` | ALU operand forwarding muxes, effective-address calculation, branch condition evaluation |
| EX/MEM Register | `EX_M_register.v` | Forwards ALU result, flags, memory & writeback controls to Memory stage |
| Memory Stage | `MemoryStage.v` | Data memory read/write, address muxing (register/stack/direct), stack pointer path for CALL/RET/RTI |
| MEM/WB Register | `MEM_WB_Register.v` | Registers the memory output (`m_out`) for true pipelining — converts a combinational path into a clocked one |
| ALU | `ALU.v` | 12-operation arithmetic/logic unit (ADD, SUB, AND, OR, INC, DEC, NOT, NEG, RLC, RRC, LOOP, PASS) |
| CCR | `CCR.v` | Condition code register (Z, N, C, V), with interrupt save/restore support |
| Register File | `Register_File.v` | 4× 8-bit registers, dual read / single write, `R0` write-protected, SP management |
| Program Counter | `Program_Counter.v` | 8-bit PC with stall-freeze and reset/interrupt vector loading |
| Instruction Memory | `Instruction_Memory.v` | Program storage, reset/interrupt vector source |
| Control Unit | `Control_Unit.v` | FSM + combinational decode generating all datapath control signals |
| Hazard Detection Unit | `hazard_detection_unit.v` | Detects load-use hazards; drives `stall`, `IF_ID_write_en`, `control_mux_sel` |
| Forwarding Unit | `Forwarding_unit.v` | Detects RAW hazards on `EX_MEM_regwrite` / `MEM_WB_regwrite`; drives the ALU operand-forwarding muxes |
| Top Module | `Processor_Top.v` | Structural top level wiring all stages, registers, and support units together |

<br />

## 🧠 Control Unit Design

The Control Unit is implemented as a 2-state FSM to support variable-length (1-byte / 2-byte) instructions:

- **`ideal` state** — default opcode-fetch state; handles all 1-byte instructions and the first byte of any 2-byte instruction (`LDM` / `LDD` / `STD`, opcode 12).
- **`S2` state** — entered only after opcode 12 is detected; treats the next fetched byte as an operand (immediate value or effective address), then returns unconditionally to `ideal`.

**Interrupts are checked only in the `ideal` state.** This guarantees 2-byte instructions execute atomically — the operand byte can never be misinterpreted as an ISR return address, and no partially-executed `LDM`/`LDD`/`STD` is left in an inconsistent state.

<br />

## ⚡ Hazard Handling

| Hazard Type | Mechanism | Detail |
|---|---|---|
| RAW (EX hazard) | Forwarding, high priority | Result from `EX/MEM` bypassed directly to ALU inputs |
| RAW (MEM hazard) | Forwarding, lower priority | Result from `MEM/WB` bypassed to ALU inputs |
| Load-use hazard | 1-cycle stall + forward | PC and IF/ID frozen, NOP bubble inserted into ID/EX, then forwarded once available |
| Control hazard (branch/interrupt) | Pipeline flush | IF/ID cleared to NOP to discard the wrong-path instruction fetched during the interrupt/branch-resolution cycle |

<br />

## 📋 Instruction Set Summary

32 instructions across three formats — full detail in `Documentation/Report.pdf`:

- **A-Format (1 byte):** `NOP`, `MOV`, `ADD`, `SUB`, `AND`, `OR`, `RLC`, `RRC`, `SETC`, `CLRC`, `PUSH`, `POP`, `OUT`, `IN`, `NOT`, `NEG`, `INC`, `DEC`
- **B-Format (1 byte):** `JZ`, `JN`, `JC`, `JV`, `LOOP`, `JMP`, `CALL`, `RET`, `RTI`
- **L-Format (1–2 bytes):** `LDM`, `LDD`, `STD`, `LDI`, `STI`

<br />

## 📂 Repository Structure

```text
📁 8bit-Pipelined-Processor/
├── 📁 RTL/                       # Synthesizable Verilog source
│   ├── ALU.v
│   ├── CCR.v
│   ├── Control_Unit.v
│   ├── decode_wb_stage.v
│   ├── EX_M_register.v
│   ├── Execute_stage.v
│   ├── FetchStage.v
│   ├── Forwarding_unit.v
│   ├── hazard_detection_unit.v
│   ├── ID_EX_register.v
│   ├── IF_ID_reg.v
│   ├── Instruction_Memory.v
│   ├── MEM_WB_Register.v
│   ├── MemoryStage.v
│   ├── Processor_Top.v
│   ├── Program_Counter.v
│   └── Register_File.v
├── 📁 TB/                        # Testbench & test programs
│   ├── top_tb.v
│   ├── program1_format_A.txt
│   ├── program2_format_A.txt
│   ├── program3_branching.txt
│   ├── program4_interrupt.txt
│   ├── program5_format_L.txt
│   └── program6_hazard.txt
├── 📁 ASIC flow/
│   └── 📁 SYNTHESIS/
│       ├── 📁 scripts/
│       │   ├── syn_script.tcl    # Design Compiler read/link/compile flow
│       │   └── cons.tcl          # SDC timing constraints
│       ├── 📁 reports/           # area / power / setup / hold / clocks / constraints
│       └── 📁 log/
├── 📁 Documentation/
│   └── Report.pdf                # Full architecture, verification & synthesis writeup
├── LICENSE
└── README.md
```

<br />

## ▶ How to Run

### Simulation (ModelSim / QuestaSim)

```bash
# Compile all RTL and the testbench
vlog -sv RTL/*.v TB/top_tb.v

# Run the full regression
vsim -c work.Processor_TB -do "run -all; quit"

# Or launch the GUI to inspect waveforms
vsim work.Processor_TB
add wave -r /*
run -all
```

Each test program under `TB/` (`program1_format_A.txt` → `program6_hazard.txt`) is loaded by the testbench to exercise a specific instruction format, branching, interrupt handling, or the load-use hazard path — see `Documentation/Report.pdf` §11 for the full expected-behavior breakdown of each.

### Synthesis (Synopsys Design Compiler)

```tcl
cd "ASIC flow/SYNTHESIS/scripts"
dc_shell-t -f syn_script.tcl
```

Reports (area, power, setup, hold, clocks, constraint violations) are written to `ASIC flow/SYNTHESIS/reports/`.

<br />

## ✅ Verification

Verified with a ModelSim self-checking testbench (`top_tb.v`) across six targeted programs:

| Program | Focus |
|---|---|
| 1–2 | A-Format instructions: ALU ops, forwarding (RAW), flag updates, register transfer, stack push/pop |
| 3 | Branching: conditional (`JZ`) not-taken and unconditional `JMP` |
| 4 | Interrupt handling: context save/restore, ISR entry via vector, `RTI` return |
| 5 | L-Format addressing modes: indirect (`STI`), direct (`STD`/`LDD`), immediate (`LDM`) |
| 6 | Hazard Detection Unit: load-use hazard, 1-cycle stall, and forwarding from `MEM/WB` |

All test programs passed with correct register, memory, flag, and PC behavior confirmed against ModelSim waveforms — see `Documentation/Report.pdf` for full waveform-by-waveform analysis.

<br />

## 📊 Synthesis Results

- **Technology:** TSMC 130nm standard-cell library, evaluated at SS (1.08V, 125°C), TT (1.2V, 25°C), and FF (1.32V, −40°C) PVT corners.
- **Clock:** 20 ns period (50 MHz), defined with realistic uncertainty, transition, and latency.
- **Timing Closure:** Positive slack on both setup (SS corner) and hold (FF corner) checks — no constraint violations reported.
- **Reports Generated:** hierarchical area breakdown, dynamic/leakage power distribution, setup/hold timing paths, clock summary, and a constraint-violation report (clean).
- **Outputs:** gate-level netlist (`.v`), Design Compiler database (`.ddc`), SDC constraints, and SDF delay file.

Full reports and analysis are in `Documentation/Report.pdf` §"Synthesis".

<br />

## 📎 Resources

- 📄 Full report with architecture diagrams, waveform analysis, and synthesis reports: `Documentation/Report.pdf`
- 🎥 Project demo video: see report appendix for link

---
*8-bit 5-Stage Pipelined RISC Processor — ELC3030, Cairo University, Fall 2025*
