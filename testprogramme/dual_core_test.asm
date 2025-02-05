csrrs x1, x0, 0xF14

beq x1, x0, core1

li x3, 1
beq x1, x3, core2

core1:
li x2, 1
j end

core2:
li x2, 2
j end

end:
