# Processor
## Ishan Vyas (isv4)

## Description of Design
5 stage pipelined CPU designed to implement MIPS ISA. CPU includes support for multi-cycle multiplication and division using modified Booth's algorithm and Non-restoring division. CPU also includes support for multiple branching features, including jump, JAL, JR, BNE, and BLT. The 5 stages include the following:
1. **FETCH:** The fetch stage includes calculations for subsequent instructions. This stage takes results from the execute stage to determine what the next program counter should be, and fetches that instruction from the instruction memory (ROM). 
2. **DECODE:** The decode stage is dominated by the register file. This stage also decodes the instruction, determining which registers should be read from the register file, and reading those values into the D/X latch. 
3. **EXECUTE:** The execute stage does all the calculations. This includes branch/jump calculations for subsequent PCs; ALU operations such as addition, subtraction, shifting, anding, and oring; multiplying and dividing; and instruction reconstruction for setx instructions. 
4. **MEMORY:** The memory stage interfaces with the memory (memory architecture not designed in this project). Given the relatively high latency associated with memory accesses, nothing more than a memory access is completed in this step. Only relavent for lw or sw instructions. 
5. **WRITEBACK:** This stage also interfaces with the register file, this time controlling the ctrl_writeEnable and data_writeReg variables. The resultant calculation is written back and updated in the register file. 

## Bypassing
There are multiple conditions for bypassing an earlier value into a later instruction. I implemented 5 bypasses; 2 bypasses from the writeback stage into the execute stage for data dependencies; 1 bypass from the writeback to the memory stage for data dependencies on the data input; and 2 bypasses from the memory (or execute_output) stage into the A & B inputs of the execute stage. 

## Stalling
There are two stalling conditions that are implemented in the CPU. The first stalling condition is for multi-cycle multiplication and division, given that any one of those operations takes either 16 or 32 clock cycles. This stalling condition stalls the *entire* CPU, waiting for the data_RDY signal to resume operation. The second condition is based on data dependencies, where the result of a lw is needed for a subsequent execute. Since we cannot bypass the result of a lw into the start of an execute (given that they would both be calculated in the same clock cycle), we must stall the fetch stage for an operation to allow for bypassing. 

## Optimizations
I made a few optimizations related to spatial and temporal constraints. Some of these optimizations are related to earlier checkpoints, including the decision to use a modified Booth's algorithm and a non-restoring division algorithm over the slower normal Booth's algorithm and the less efficient restoring division algorithm. Other optimizations include using purposely wide muxes, including 4-input and 8-input muxes to reduce how deep the processor is. I also use parallel adders for branch and jump calculations to avoid deep levels of muxes before the ALU in the execute stage. Finally, I use a positive edge-triggered pulse generator at the onset of a multiplication or division to generate a ctrl_MULT or ctrl_DIV value that starts the operations. 

## Bugs
None that I know of!!