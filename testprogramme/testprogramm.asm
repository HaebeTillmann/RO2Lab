# Initialize test result register x31 to zero
    addi  x31, x0, 0

_start:
# Test 1: LUI
    lui   x1, 0x12345      # x1 = 0x12345000
    addi  x2, x0, 0x123    # Construct expected result:
    slli  x2, x2, 12       #    Shift x2 left by 12
    addi  x2, x2, 0x450    #    x2 = 0x123450
    slli  x2, x2, 8        #    x2 = 0x12345000
    xor   x3, x1, x2       # x3 = x1 ^ x2
    sltu  x3, x0, x3       # x3 = 1 if x1 != x2, else 0
    slli  x31, x31, 1      # Shift x31 left by 1
    or    x31, x31, x3     # Accumulate test result

# Test 2: AUIPC
    auipc x3, 0x54321      # x3 = 0x54321000
    addi  x4, x0, 0x6e3    # Construct expected result:
    slli  x4, x4, 12       #    Shift x4 left by 12
    addi  x4, x4, 0x210    #    x4 = 0x6e3210
    slli  x4, x4, 8        #    x4 = 0x6e321000
    addi  x4, x4, 0x28     #    x4 = 0x6e321028
    xor   x5, x3, x4       # x5 = x3 ^ x4
    sltu  x5, x0, x5       # x5 = 1 if x3 != x4, else 0
    slli  x31, x31, 1      # Shift x31 left by 1
    or    x31, x31, x5     # Accumulate test result

# Test 3: ADDI
    li    x5, 10
    addi  x6, x5, 5        # x6 = 15
    li    x7, 15           # Expected result
    xor   x8, x6, x7       # x8 = x6 ^ x7
    sltu  x8, x0, x8       # x8 = 1 if x6 != x7, else 0
    slli  x31, x31, 1
    or    x31, x31, x8

# Test 4: SLTI
    li    x9, 10
    slti  x10, x9, 20      # x10 = 1
    li    x11, 1           # Expected result
    xor   x12, x10, x11    # x12 = x10 ^ x11
    sltu  x12, x0, x12     # x12 = 1 if x10 != x11, else 0
    slli  x31, x31, 1
    or    x31, x31, x12

# Test 5: SLTIU
    li    x13, 10
    sltiu x14, x13, 20     # x14 = 1
    li    x15, 1           # Expected result
    xor   x16, x14, x15    # x16 = x14 ^ x15
    sltu  x16, x0, x16     # x16 = 1 if x14 != x15, else 0
    slli  x31, x31, 1
    or    x31, x31, x16

# Test 6: XORI
    li    x17, 0xFF0
    xori  x18, x17, 0x0FF  # x18 = 0xF0F
    li    x19, 0xF0F       # Expected result
    xor   x20, x18, x19    # x20 = x18 ^ x19
    sltu  x20, x0, x20     # x20 = 1 if x18 != x19, else 0
    slli  x31, x31, 1
    or    x31, x31, x20

# Test 7: ORI
    li    x21, 0xFF0
    ori   x22, x21, 0x0FF  # x22 = x21 | 0xFFF
    li    x23, 0xFFF       # Expected result
    xor   x24, x22, x23    # x24 = x22 ^ x23
    sltu  x24, x0, x24     # x24 = 1 if x22 != x23, else 0
    slli  x31, x31, 1      # Shift x31 left by 1
    or    x31, x31, x24    # Accumulate test result

# Test 8: ANDI
    li    x25, 0xFF0
    andi  x26, x25, 0x0FF  # x26 = x25 & 0x00FF
    li    x27, 0x0F0       # Expected result
    xor   x28, x26, x27    # x28 = x26 ^ x27
    sltu  x28, x0, x28     # x28 = 1 if x26 != x27, else 0
    slli  x31, x31, 1
    or    x31, x31, x28

# Test 9: SLLI
    li    x29, 0x001
    slli  x30, x29, 4      # x30 = x29 << 4
    li    x1, 0x010        # Expected result
    xor   x2, x30, x1      # x2 = x30 ^ x1
    sltu  x2, x0, x2       # x2 = 1 if x30 != x1, else 0
    slli  x31, x31, 1
    or    x31, x31, x2

# Test 10: SRLI
    li    x3, 0x010
    srli  x4, x3, 4        # x4 = x3 >> 4 (logical)
    li    x5, 0x001        # Expected result
    xor   x6, x4, x5       # x6 = x4 ^ x5
    sltu  x6, x0, x6       # x6 = 1 if x4 != x5, else 0
    slli  x31, x31, 1
    or    x31, x31, x6

# Test 11: SRAI
    li    x7, -16          # x7 = 0xFFFFFFF0
    srai  x8, x7, 4        # x8 = x7 >> 4 (arithmetic)
    li    x9, -1           # Expected result
    xor   x10, x8, x9      # x10 = x8 ^ x9
    sltu  x10, x0, x10     # x10 = 1 if x8 != x9, else 0
    slli  x31, x31, 1
    or    x31, x31, x10

# Test 12: ADD
    li    x11, 20
    li    x12, 22
    add   x13, x11, x12    # x13 = 42
    li    x14, 42          # Expected result
    xor   x15, x13, x14    # x15 = x13 ^ x14
    sltu  x15, x0, x15     # x15 = 1 if x13 != x14, else 0
    slli  x31, x31, 1
    or    x31, x31, x15

# Test 13: SUB
    li    x16, 50
    li    x17, 8
    sub   x18, x16, x17    # x18 = 42
    li    x19, 42          # Expected result
    xor   x20, x18, x19    # x20 = x18 ^ x19
    sltu  x20, x0, x20     # x20 = 1 if x18 != x19, else 0
    slli  x31, x31, 1
    or    x31, x31, x20

# Test 14: SLL
    li    x21, 0x001
    li    x22, 4
    sll   x23, x21, x22    # x23 = x21 << x22
    li    x24, 0x010       # Expected result
    xor   x25, x23, x24    # x25 = x23 ^ x24
    sltu  x25, x0, x25     # x25 = 1 if x23 != x24, else 0
    slli  x31, x31, 1
    or    x31, x31, x25

# Test 15: SLT
    li    x26, 10
    li    x27, 20
    slt   x28, x26, x27    # x28 = 1 if x26 < x27
    li    x29, 1           # Expected result
    xor   x30, x28, x29    # x30 = x28 ^ x29
    sltu  x30, x0, x30     # x30 = 1 if x28 != x29, else 0
    slli  x31, x31, 1
    or    x31, x31, x30

# Test 16: SLTU
    li    x1, -1           # x1 = 0xFFFFFFFF
    li    x2, 0            # x2 = 0x00000000
    sltu  x3, x1, x2       # x3 = 0
    li    x4, 0            # Expected result
    xor   x5, x3, x4       # x5 = x3 ^ x4
    sltu  x5, x0, x5       # x5 = 1 if x3 != x4, else 0
    slli  x31, x31, 1
    or    x31, x31, x5

# Test 17: XOR
    li    x6, 0xFF0
    li    x7, 0x0FF
    xor   x8, x6, x7       # x8 = x6 ^ x7
    li    x9, 0xF0F        # Expected result
    xor   x10, x8, x9      # x10 = x8 ^ x9
    sltu  x10, x0, x10     # x10 = 1 if x8 != x9, else 0
    slli  x31, x31, 1
    or    x31, x31, x10

# Test 18: SRL
    li    x11, 0x800
    li    x12, 1
    srl   x13, x11, x12    # x13 = x11 >> x12 (logical)
    li    x14, 0x400       # Expected result
    xor   x15, x13, x14    # x15 = x13 ^ x14
    sltu  x15, x0, x15     # x15 = 1 if x13 != x14, else 0
    slli  x31, x31, 1
    or    x31, x31, x15

# Test 19: SRA
    li    x16, -4
    li    x17, 1
    sra   x18, x16, x17    # x18 = x16 >> x17 (arithmetic)
    li    x19, -2          # Expected result
    xor   x20, x18, x19    # x20 = x18 ^ x19
    sltu  x20, x0, x20     # x20 = 1 if x18 != x19, else 0
    slli  x31, x31, 1
    or    x31, x31, x20

# Test 20: OR
    li    x21, 0xF0F
    li    x22, 0x0FF
    or    x23, x21, x22    # x23 = x21 | x22
    li    x24, 0xFFF       # Expected result
    xor   x25, x23, x24    # x25 = x23 ^ x24
    sltu  x25, x0, x25     # x25 = 1 if x23 != x24, else 0
    slli  x31, x31, 1
    or    x31, x31, x25

# Test 21: AND
    li    x26, 0xF0F
    li    x27, 0x0FF
    and   x28, x26, x27    # x28 = x26 & x27
    li    x29, 0x00F       # Expected result
    xor   x30, x28, x29    # x30 = x28 ^ x29
    sltu  x30, x0, x30     # x30 = 1 if x28 != x29, else 0
    slli  x31, x31, 1
    or    x31, x31, x30

#Blatt 6

#Test 22: JAL
	li    x2, 0x0
    jal   x1, jal_target
    li    x2, 0xFFF
    j jal_end
jal_target:
    sltu  x2, x0, x2
    slli  x31, x31, 1
    or    x31, x31, x2
    jr    x1
    
#Test 23: JAL rd
jal_end:
	li x3, 0xFFF
    xor x1, x2, x3
    sltu x1, x0, x1
    slli x31, x31, 1
    or x31, x31, x1
    
#Test 24 JALR
    la    x5, jalr_target
    jalr  x6, x5, 0
jalr_target:
    auipc x7, 0
    xor   x8, x6, x7
    sltu  x8, x0, x8
    slli  x31, x31, 1
    or    x31, x31, x8

#Test 25 BEQ
    li x10, 100
    li x11, 100
    li x12, 0x0
    beq x10, x11, beq_target
    li x12, 0xFFF
beq_target:
    sltu x12, x0, x12
    slli x31, x31, 1
    or x31, x31, x12

#Test 26 BNE 
    li    x15, 200
    li    x16, 201
    li    x17, 0x0
    bne   x15, x16, bne_target
    li    x17, 0xFFF       
bne_target:   
    sltu  x17, x0, x17       
    slli  x31, x31, 1
    or    x31, x31, x17

#Test 27 BLT 
    li    x20, -5
    li    x21, 5
    li	  x22, 0x0
    blt   x20, x21, blt_target
    li    x22, 0xFFF        
blt_target:   
    sltu  x22, x0, x22       
    slli  x31, x31, 1
    or    x31, x31, x22

#Test 28 BGE
    li    x25, 10
    li    x26, 5
    li    x27, 0x0
    bge   x25, x26, bge_target
    li    x27, 0xFFF        
bge_target:     
    sltu  x27, x0, x27       
    slli  x31, x31, 1
    or    x31, x31, x27

#Test 29 BLTU 
    li    x1, 0x001
    li    x2, 0xFFF
    li    x3, 0x0
    bltu  x1, x2, bltu_target
    li    x3, 0xFFF          
bltu_target:         
    sltu  x3, x0, x3          
    slli  x31, x31, 1
    or    x31, x31, x3

#Test 30 BGEU 
    li    x6, 0xFFF
    li    x7, 0x001
    li    x8, 0x0
    bgeu  x6, x7, bgeu_target
    li    x8, 0xFFF       
bgeu_target:       
    sltu  x8, x0, x8        
    slli  x31, x31, 1
    or    x31, x31, x8

#Test 31 LW/SW	
	li	  x1, 2
    li    x11, 0x123    
    sw    x11, 8(x1)          
    lw    x12, 8(x1)          
    xor   x13, x11, x12       
    sltu  x13, x0, x13        
    slli  x31, x31, 1
    or    x31, x31, x13

# x31 now contains the test results
# for each 1 in x31: 31 - reg = failed test
