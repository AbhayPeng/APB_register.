# APB Register Bank using Verilog

## Project Overview
Designed and implemented a simple APB (Advanced Peripheral Bus) Register Bank using Verilog HDL in AMD Xilinx Vivado. The design consists of four 32-bit memory-mapped registers and supports read and write operations using address decoding.

## Features
- Four 32-bit registers mapped to addresses `0x00`, `0x04`, `0x08`, and `0x0C`.
- Read and write operations following APB SETUP and ACCESS phases.
- Active-low synchronous reset.
- Invalid-address detection using `PSLVERR`.
- Always-ready peripheral with no wait states.
- Functional verification using a Verilog testbench.

## Tools & Technologies
- **HDL:** Verilog
- **EDA Tool:** AMD Xilinx Vivado
- **Verification:** Behavioral Simulation

## Key Learnings
Gained practical experience in RTL design, memory-mapped registers, address decoding, synchronous logic, APB transaction handling, and simulation-based verification.

**Project Domain:** VLSI Design | RTL Design | Digital Design | Bus Protocols
