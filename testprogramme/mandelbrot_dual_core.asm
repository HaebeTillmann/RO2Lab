mret # Interrupt 0
mret # Interrupt 1
mret # Interrupt 2
mret # Interrupt 3
mret # Interrupt 4
mret # Interrupt 5
mret # Interrupt 6
mret # Interrupt 7
mret # Interrupt 8
mret # Interrupt 9
mret # Interrupt 10
mret # Interrupt 11
mret # Interrupt 12
mret # Interrupt 13
mret # Interrupt 14
mret # Interrupt 15
mret # Interrupt 16
mret # Interrupt 17
mret # Interrupt 18
mret # Interrupt 19
mret # Interrupt 20
mret # Interrupt 21
mret # Interrupt 22
mret # Interrupt 23
mret # Interrupt 24
mret # Interrupt 25
mret # Interrupt 26
mret # Interrupt 27
mret # Interrupt 28
mret # Interrupt 29
mret # Interrupt 30
mret # Interrupt 31

start:
  # Core-ID abrufen
  csrrs t0, x0,  0xf14 

  # Basiswerte setzen
  li s2, 128
  li s5, 1024
  li s6, 31
  li s9, 3

  # Unterscheidung der Cores
  beqz t0, core_0_setup
  j core_1_setup

core_0_setup:
  li s3, -180  # fp_y für oberen Teil
  li s4, 0     # fp_y Endwert für oberen Teil
  li s7, 0x1D000000  # Framebuffer-Adresse für Core 0
  j compute

core_1_setup:
  li s3, 0     # fp_y für unteren Teil
  li s4, 180   # fp_y Endwert für unteren Teil
  li s7, 0x1D002000  # Framebuffer-Adresse für Core 1
  j compute

compute:
y_loop:
  li s1, -512  # fp_x Startwert

x_loop:
  add s10, x0, x0  # iter = 0
  add s11, x0, x0  # x = 0
  add a7, x0, x0   # y = 0
  add a6, x0, x0   # sx = 0
  add a5, x0, x0   # sy = 0

iter_loop:
  add a0, a5, a6
  bge a0, s5, iter_end
  beq s10, s6, iter_end

  add a1, x0, s11
  add a2, x0, s11
  jal ra, fp_mul  
  add a6, a0, x0  # sx = x * x

  add a1, x0, a7
  add a2, x0, a7
  jal ra, fp_mul  
  add a5, a0, x0  # sy = y * y

  add a1, x0, s11
  add a2, x0, a7
  jal ra, fp_mul  
  slli a7, a0, 1  # y = 2 * x * y

  add a7, a7, s3  # y += fp_y
  sub s11, a6, a5 # x = sx - sy
  add s11, s11, s1 # x = x + fp_x

  addi s10, s10, 1
  j iter_loop

iter_end:
  srli s0, s0, 8
  slli s10, s10, 24
  or s0, s0, s10

  addi s9, s9, -1
  bge s9, x0, iter_loop_header

  sw s0, 0(s7)
  addi s9, x0, 3
  addi s7, s7, 4

iter_loop_header:
  addi s1, s1, 1
  blt s1, s2, x_loop

  addi s3, s3, 1
  blt s3, s4, y_loop

done:
  j done

fp_mul:
  mul a0, a1, a2
  srai a0, a0, 8
  jalr x0, ra, 0

