# REGFILE
## Name
Ishan Vyas
## Description of Design
Using the given DFF design, I first created a module that resembled a register. The register includes output, input, clock, enable, and clear bits synonymous with those from the DFF. I then use a genvar to generate 32 DFFs, allowing the register to store a 32bit value. 

I also include a simple 5:32 decoder. I use simple decoder syntax (<<) in Verilog to create the decoder.

Finally is the full register file. I decode the RD value and AND each output with the WE input. The subsequent output is fed into the enable of each register. The RDVal is fed into the data of each register. I store the output of the registers in a 32x32 wire bus, represented as a flat 1024 wire array. I decode RS1 and RS2, and use the decoded wires as inputs to the tri-state buffers. The outputs of the tri-state buffers are fed into RS1Val and RS2Val and outputted out of the register file. 

## Bugs
Currently, no bugs are known in my code - last I checked with the autograder, it gave full marks. However, if you see any issues with the code, please let me know!