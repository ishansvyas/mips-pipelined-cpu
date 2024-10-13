# ALU
## Name
Ishan Vyas
## Description of Design
For the 32 bit result, I used a mux with the op-code as the select bits. I took the outputs of the adder/subtractor, bitwise AND, bitwise OR, SLL, and SRA modules. The first level of the adder is a 2-input mux between B and !B. The last digit of the opcode decides the output and is the carry-in for the adder. The other input to the adder is A. This allows the module to use the negated B only when subtracting. 

The overflow bit is only on when the MSB of the output does not match either of the MSBs of the inputs. This is calculated by a series of ANDs, ORs, and NOTs, but could also be calculated by a MUX if desired.

The isNotEqual bit only needs to be correct when subtracting. We know that when subtracting equal numbers, the result should be 0 completely. Thus, if the result of the subtraction is anything other than 0, the inputs are not equal. The consequence of that is that we can OR all the bits of the result together, and if all the bits are 0, we know the inputs were equal. Otherwise, isNotEqual will output 1. 

The isLessThan bit takes a bit more manipulation. We know that subtracting a higher number from a lower one should always give a negative result. However, with the carry-out bit of the subtraction, it might turn a negative number positive or vice versa. The solution I came up with is to use a 4-input mux. The select bits are the MSBs of the A and B operands. When AB==00 OR AB==11, we use the result of the subtraction to determine the isLessThan result. However, when AB==01 or AB==10, we know immediately which number is larger, and we can then just directly wire the bit.  

The bitwise AND, bitwise OR, SLL, and SRA are all intuitive, and there is no design to consider. I used the slides as reference FWIW. 
## Bugs
Currently, no bugs are known in my code - last I checked with the autograder, it gave full marks. However, if you see any issues with the code, please let me know!