nop            # Specifically tests add into lw
nop            # Author: Philip Xue
nop
nop            # EDGE CASE: bypassing ALU result to address calculation for lw
nop
addi $1, $0, 830        # r1 = 830
nop
nop
sw $1, 4($0)         # mem[4] = r1 = 830
addi $5, $0, 2       # r5 = 2
lw $4, 2($5)         # r4 = mem[2+r5] = mem[2+2] = mem[4] = 830