
# IEEE SSCS — RV32IM 5-Stage Pipelined CPU

**University of Texas at Dallas | IEEE Solid-State Circuits Society**

## Project Overview

The objective of this project is to design and implement a 32-bit RISC-V processor supporting the **RV32IM instruction set**, using Verilog HDL and AMD Vivado.

The processor follows a five-stage pipeline:

**Instruction Fetch (IF) → Instruction Decode (ID) → Execute (EX) → Memory (MEM) → Writeback (WB)**

Six teams will develop individual functional modules that integrate into a complete pipelined processor.

### Processor Specifications

| Parameter | Specification |
|---|---|
| Architecture | RISC-V RV32IM |
| Datapath Width | 32 bits |
| Instruction Width | 32 bits |
| Registers | 32 × 32-bit (x0–x31) |
| Pipeline | Five stages |
| HDL | Verilog |
| Development Environment | AMD Vivado |
| Instruction Memory | 256 × 32-bit words |
| Data Memory | 1 KiB |
| Memory Organization | Little-endian |

---

## 1. Team Assignments

Each team is responsible for implementing the logic inside its assigned RTL modules.

### Team 1 — Instruction Decode & Main Control

**Modules:**
- `instruction_decoder.v`
- `control_unit.v`

**Responsibilities:**
- Extract opcode, funct3, funct7, rs1, rs2, and rd.
- Identify RV32I and RV32M instruction types.
- Generate register-write and memory-control signals.
- Generate ALU operand-source selection signals.
- Generate branch, jump, JALR, and writeback controls.
- Determine immediate format.
- Identify invalid instruction encodings.

### Team 2 — Register File & Immediate Generator

**Modules:**
- `register_file.v`
- `immediate_generator.v`

**Responsibilities:**
- Implement 32 general-purpose, 32-bit registers.
- Support two simultaneous combinational register reads.
- Support one synchronous register write.
- Ensure register x0 always reads zero.
- Support register reset.
- Generate I-type, S-type, B-type, U-type, and J-type immediates.
- Implement correct sign extension and immediate-bit arrangement.

### Team 3 — Integer ALU

**Module:**
- `alu.v`

**Responsibilities:**
- Implement all specified arithmetic and logical operations.
- Support signed and unsigned comparisons.
- Support logical and arithmetic shifts.
- Implement the PASS B operation for LUI.
- Generate the zero-result flag.
- Follow the ALU operation encodings defined below.

### Team 4 — ALU Control & Datapath Selection

**Modules:**
- `alu_op_decoder.v`
- `operand_select.v`
- `writeback_mux.v`

**Responsibilities:**
- Decode ALU operations from instruction fields.
- Generate the four-bit ALU control signal.
- Select between register operands, immediate values, and PC.
- Preserve forwarded register operands.
- Select writeback data from ALU/RV32M results, memory data, or PC+4.
- Coordinate ALU encodings with Team 3.

### Team 5 — Branch & Jump Unit

**Module:**
- `branch_jump.v`

**Responsibilities:**
- Implement BEQ, BNE, BLT, BGE, BLTU, and BGEU comparisons.
- Distinguish signed and unsigned branches.
- Calculate branch targets.
- Calculate JAL and JALR target addresses.
- Clear bit 0 of JALR target addresses.
- Generate branch/jump redirect signals.

### Team 6 — Load/Store & Data Memory

**Modules:**
- `load_store_unit.v`
- `data_memory.v`

**Responsibilities:**
- Implement LB, LH, LW, LBU, and LHU.
- Implement SB, SH, and SW.
- Support byte-lane selection and byte-enable generation.
- Implement signed and unsigned load extension.
- Detect misaligned memory accesses.
- Implement synchronous memory writes and combinational memory reads.
- Support a 1 KiB byte-addressed, little-endian data memory.

---

## 2. ALU Operation Encodings

These encodings are taken from the existing RV32IM CPU implementation.

| ALU Control | Operation | Description |
|---|---|---|
| `4'd0` | ADD | A + B |
| `4'd1` | SUB | A - B |
| `4'd2` | AND | Bitwise AND |
| `4'd3` | OR | Bitwise OR |
| `4'd4` | XOR | Bitwise XOR |
| `4'd5` | PASS B | Result = B |
| `4'd6` | SLL | Logical left shift |
| `4'd7` | SRL | Logical right shift |
| `4'd8` | SRA | Arithmetic right shift |
| `4'd9` | SLT | Signed less-than |
| `4'd10` | SLTU | Unsigned less-than |

### Implementation Details

- Shift amounts use `b[4:0]`.
- SRA and SLT require signed operands.
- SLTU uses unsigned comparison.
- SLT and SLTU return 32-bit `1` or `0`.
- PASS B returns the second operand without modification.
- Undefined ALU operations produce zero.

Teams 3 and 4 use the same ALU operation encodings.

---

## 3. Immediate Generator Encodings

The three-bit `imm_sel` signal selects the instruction's immediate format.

| `imm_sel` | Immediate Type | Instructions |
|---|---|---|
| `3'd0` | I-type | Immediate arithmetic, loads, JALR |
| `3'd1` | S-type | Stores |
| `3'd2` | B-type | Conditional branches |
| `3'd3` | U-type | LUI, AUIPC |
| `3'd4` | J-type | JAL |

I-, S-, B-, and J-type immediates are sign-extended to 32 bits. U-type immediates have their lowest 12 bits set to zero.

---

## 4. Operand Selection

### ALU Operand A

| `alu_a_pc` | Source |
|---|---|
| `0` | Register rs1 |
| `1` | Program Counter |

### ALU Operand B

| `alu_src` | Source |
|---|---|
| `0` | Register rs2 |
| `1` | Immediate |

Store-data signals retain the rs2 value independently of ALU Operand B selection.

---

## 5. Writeback Selection

| `wb_sel` | Data Source |
|---|---|
| `2'd0` | Execution result (ALU or RV32M) |
| `2'd1` | Memory load data |
| `2'd2` | PC + 4 |
| `2'd3` | Reserved |

---

## 6. Forwarding Selection

| Selection | Source |
|---|---|
| `2'd0` | ID/EX register operand |
| `2'd1` | MEM/WB forwarded result |
| `2'd2` | EX/MEM forwarded result |
| `2'd3` | Reserved |

EX/MEM forwarding of load instructions requires special handling because loaded data is not available at the end of the EX stage.

A load-use stall allows the dependent instruction to receive the correct value.

---

## 7. RV32M Instruction Encodings

RV32M instructions use the R-type opcode `0110011` with `funct7 = 0000001`.

| `funct3` | Instruction |
|---|---|
| `000` | MUL |
| `001` | MULH |
| `010` | MULHSU |
| `011` | MULHU |
| `100` | DIV |
| `101` | DIVU |
| `110` | REM |
| `111` | REMU |

RV32M instructions use their own instruction fields, separate from the integer ALU's four-bit control encoding.

---

## 8. Branch and Memory Encodings

### Branch Instructions

| `funct3` | Instruction |
|---|---|
| `000` | BEQ |
| `001` | BNE |
| `100` | BLT |
| `101` | BGE |
| `110` | BLTU |
| `111` | BGEU |

### Load Instructions

| `funct3` | Instruction |
|---|---|
| `000` | LB |
| `001` | LH |
| `010` | LW |
| `100` | LBU |
| `101` | LHU |

### Store Instructions

| `funct3` | Instruction |
|---|---|
| `000` | SB |
| `001` | SH |
| `010` | SW |

### Memory Alignment

- Byte accesses support any byte address.
- Halfword accesses use even starting addresses.
- Word accesses use starting addresses divisible by four.
- The prototype flags misaligned halfword and word accesses.

---

## 9. RTL Development Guidelines

All team modules should follow these requirements:

1. Use Verilog HDL (`.v` files).
2. Preserve the existing module interfaces for integration.
3. Use `always @(*)` for combinational procedural logic.
4. Use nonblocking assignments (`<=`) for clocked sequential logic.
5. Assign default values to combinational outputs to prevent unintended latches.
6. Use signed operations where required by the RISC-V specification.
7. Keep each module compatible with the shared top-level processor architecture.

---

## 10. GitHub Collaboration Workflow

Each team develops its RTL using a separate Git branch.

### Repository

https://github.com/anindyaranindya-beep/IEEE-SSCS-RV32IM

### Branch Names

| Team | Branch |
|---|---|
| Team 1 | `team1-decode` |
| Team 2 | `team2-registers` |
| Team 3 | `team3-alu` |
| Team 4 | `team4-selection` |
| Team 5 | `team5-branch` |
| Team 6 | `team6-memory` |

### Cloning the Repository

```bash
git clone https://github.com/anindyaranindya-beep/IEEE-SSCS-RV32IM.git
cd IEEE-SSCS-RV32IM
```

### Creating a Branch

Example for Team 3:

```bash
git switch -c team3-alu
```

### Submitting RTL Changes

After completing the assigned module:

```bash
git add rtl/teams/team3_alu/
git commit -m "Implement Team 3 ALU"
git push -u origin team3-alu
```

Once the branch is pushed, open GitHub and create a **Pull Request** targeting `main`.

### Pull Request Requirements

Every submission should include:

- Completed assigned RTL module(s).
- A short description of implemented functionality.
- Any known incomplete behavior or assumptions.
- Questions concerning shared interfaces or integration.

Changes are reviewed before merging into `main`.

---

## 11. Running the Processor in Vivado

1. Create a new RTL project in AMD Vivado.
2. Add the `.v` files under **Design Sources**.
3. Set `rv32im_top` as the top-level module.
4. Add `tb_rv32im_top.v` under **Simulation Sources**.
5. Select the CPU testbench as the simulation top.
6. Run Behavioral Simulation.
7. Inspect simulation logs, register values, and waveforms.

The initial template includes placeholder logic, so the CPU will not function correctly until the implementations are completed.

The reference implementation requires compilation and functional verification before being considered complete.






