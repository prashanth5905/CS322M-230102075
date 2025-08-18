# 4-Phase Handshake FSM Design

## Overview

This project implements a 4-phase handshake protocol between two finite state machines (FSMs) - a Master and a Slave - connected via a request/acknowledge interface with an 8-bit data bus. The system transfers 4 bytes of data sequentially using a robust handshaking mechanism.

## Architecture

### System Components

1. *link_top.v* - Top-level module connecting Master and Slave FSMs
2. *master_fsm.v* - Master FSM that initiates data transfers
3. *slave_fsm.v* - Slave FSM that receives and acknowledges data
4. *tb_link_top.v* - Testbench for system verification

### Signal Interface

| Signal | Width | Direction | Description |
|--------|-------|-----------|-------------|
| clk | 1 | Input | Common clock for both FSMs |
| rst | 1 | Input | Synchronous active-high reset |
| req | 1 | Master→Slave | Request signal |
| ack | 1 | Slave→Master | Acknowledge signal |
| data[7:0] | 8 | Master→Slave | Data bus |
| done | 1 | Output | Transfer completion indicator |
| last_byte[7:0] | 8 | Internal | Last received byte storage |

## 4-Phase Handshake Protocol

The protocol follows these steps for each byte transfer:

1. *Request Phase*: Master drives data and raises req
2. *Acknowledge Phase*: Slave latches data and asserts ack (held for 2 cycles)
3. *Request Drop*: Master sees ack, drops req
4. *Acknowledge Drop*: Slave sees req low, drops ack

## Master FSM Design

### States

- *IDLE (00)*: Initial state, drives first data byte and asserts req
- *WAIT_ACK (01)*: Waits for slave acknowledgment
- *WAIT_ACK_LOW (10)*: Waits for ack to go low before next transfer
- *DONE_STATE (11)*: Asserts done signal for one cycle

### State Transitions


IDLE → WAIT_ACK: Always (start transfer)
WAIT_ACK → WAIT_ACK_LOW: When ack=1
WAIT_ACK_LOW → WAIT_ACK: When ack=0 and more bytes to send
WAIT_ACK_LOW → DONE_STATE: When ack=0 and all bytes sent
DONE_STATE → IDLE: Always (one cycle pulse)


### Memory Contents

The master contains 4 predefined data bytes:
- mem[0] = 8'hA0
- mem[1] = 8'hA1
- mem[2] = 8'hA2
- mem[3] = 8'hA3

## Slave FSM Design

### Operation

The slave FSM uses edge detection rather than explicit states:

1. *Edge Detection*: Monitors req for rising edge using prev_req
2. *Data Capture*: Latches data_in to last_byte on rising edge of req
3. *Acknowledge Generation*: Asserts ack for exactly 2 clock cycles
4. *Handshake Completion*: Waits for req to go low before clearing ack

### Timing Control

- ack_cnt: 2-bit counter ensuring ack is held for exactly 2 cycles
- prev_req: Previous clock cycle's req value for edge detection

## Reset Behavior

*Synchronous Active-High Reset*:
- All state registers return to initial values
- Master starts in IDLE state with index 0
- Slave clears all control signals
- Output signals (req, ack, done) are deasserted

## Timing Characteristics

- *Clock Period*: 10ns (100MHz in testbench)
- *Reset Duration*: 20ns (2 clock cycles)
- *Acknowledge Duration*: 2 clock cycles minimum
- *Total Transfer Time*: ~16-20 clock cycles for 4 bytes

## File Descriptions

### link_top.v
Top-level module that instantiates and connects the master and slave FSMs. Provides the main interface signals (clk, rst, done) to the external world.

### master_fsm.v
Implements the master FSM with:
- 4-state design using localparam encoding
- Internal memory array with predefined data
- Combinational next-state logic
- Sequential state update with synchronous reset

### slave_fsm.v
Implements the slave FSM with:
- Edge-detection based operation
- Precise 2-cycle acknowledge timing
- Data latching capability
- Robust handshake completion detection

### tb_link_top.v
Comprehensive testbench featuring:
- Clock generation (100MHz)
- Reset sequence
- Signal monitoring with formatted output
- VCD dump for waveform analysis
- Automatic simulation termination on completion

## Simulation Results

The waveform analysis shows:
1. *4 Complete Handshakes*: Each data byte (A0, A1, A2, A3) is successfully transferred
2. *Proper Timing*: ack is held for exactly 2 cycles per handshake
3. *Protocol Compliance*: Clean request/acknowledge transitions
4. *Done Pulse*: Single-cycle done assertion after all transfers

## Usage Instructions

### Compilation and Simulation

bash
# Using Icarus Verilog
iverilog -o sim tb_link_top.v link_top.v master_fsm.v slave_fsm.v
vvp sim

# View waveforms
gtkwave dump.vcd


### Expected Output

```
time  clk  req   ack   ack_cnt    data     last_byte   done
20    1    1     0     0          a0       00          0
30    1    1     1     1          a0       a0          0
40    1    1     1     10         a0       a0          0
50    1    0     1     10         a0       a0          0
60    1    0     0     0          a0       a0          0
70    1    1     0     0          a1       a0          0
[... continues for all 4 bytes ...]