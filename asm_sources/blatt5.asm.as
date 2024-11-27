start:
addi x28, x0, 0 #fail register
addi x29, x0, 0 #count register
#x30 correct compare register
#x4 result register
#x5,x6 data register

#lui
addi x5, x0, 2047
addi x5, x5, 1
lui x31, 1 
sub x28,x5,x31
addi x29,x29,1

#auipc
#auipc
#sub x28,x30,x4
#addi x29,x29,1

addi x5, x0, 10
addi x6, x0, 8
addi x29,x29,1

#addi
addi x5, x0, 2
addi x30, x0, 4
addi x31, x5, 2
sub x28,x30,x4
addi x29,x29,1

#slti
addi x5, x0, 8
addi x30, x0, 0
slti x31, x5, 3
sub x28,x30,x4
addi x29,x29,1

#sltiu
addi x5, x0, 4
addi x30, x0, 0
sltiu x31, x5, 2
sub x28,x30,x4
addi x29,x29,1

#xori
addi x5, x0, 4
addi x30, x0, 5
xori x31, x5, 1
sub x28,x30,x4
addi x29,x29,1

#ori
addi x5, x0, 1
addi x30, x0, 5
ori x31, x5, 4
sub x28,x30,x4
addi x29,x29,1

#andi
addi x5, x0, 3
addi x30, x0, 2
andi x31, x5, 2
sub x28,x30,x4
addi x29,x29,1

#slli
addi x5, x0, 4
addi x30, x0, 8
slli x31, x5, 1
sub x28,x30,x4
addi x29,x29,1

#srli
addi x5, x0, 8
addi x30, x0, 4
srli x31, x5, 1
sub x28,x30,x4
addi x29,x29,1

#srai
addi x5, x0, 4
addi x30, x0, 2
srai x31, x5, 1
sub x28,x30,x4
addi x29,x29,1

#add
addi x5, x0, 6
addi x6, x0, 2
addi x30, x0, 8
add x31, x5, x6
sub x28,x30,x4
addi x29,x29,1

#sub
addi x5, x0, 8
addi x6, x0, 2
addi x30, x0, 6
sub x31, x5, x6
sub x28,x30,x4
addi x29,x29,1

#sll
addi x5, x0, 4
addi x6, x0, 1
addi x30, x0, 8
sll x31, x5, x6
sub x28,x30,x4
addi x29,x29,1

#slt
addi x5, x0, 4
addi x6, x0, 8
addi x30, x0, 1
slt x31, x5, x6
sub x28,x30,x4
addi x29,x29,1

#sltu
addi x5, x0, 4
addi x6, x0, 8
addi x30, x0, 1
sltu x31, x5, x6
sub x28,x30,x4
addi x29,x29,1

#xor
addi x5, x0, 5
addi x6, x0, 1
addi x30, x0, 4
xor x31, x5, x6
sub x28,x30,x4
addi x29,x29,1

#srl
addi x5, x0, 4
addi x6, x0, 1
addi x30, x0, 2
srli x31, x5, 1
sub x28,x30,x4
addi x29,x29,1

#sra
addi x5, x0, -4
addi x6, x0, 1
addi x30, x0, -2
sra x31, x5, x6
sub x28,x30,x4
addi x29,x29,1

#or
addi x5, x0, 1
addi x6, x0, 4
addi x30,x0, 5
or x31, x5, x6
sub x28,x30,x4
addi x29,x29,1

#and
addi x5, x0, 5
addi x6, x0, 3
addi x30,x0, 1
and x31, x5, x6
sub x28,x30,x4
addi x29,x29,1