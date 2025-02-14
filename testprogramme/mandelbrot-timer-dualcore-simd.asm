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

csrrs t0, x0, 0xC01 # get starting time
lui t1, 0x1C008
sw t0, 0(t1) # store in memory

start:
# fixed point -> x << 8 , except for mult/div
#   32 Bit: 24MSB -> Int-Part, 8LSB -> fraction
# s0 : current four pixels
# s1 : fp_x
# s2 : fp_x_end
# s3 : fp_y
# s4 : fp_y_end
# s5 : fp_tresh
# s6 : max_iter
# s7 : frame_adr
# s9 : bytes per write - 1
li s2, 128

# fp_y = fp_y_startbge
li s3, -180

li s4, 180
li s5, 1024
li s6, 31
li s7, 0x1D000000
li s9, 3

dualcore_init:
	csrrs t5, x0, 0xF14
    beq t5, x0, y_loop
    addi s7, s7, 0x4

y_loop:
  # fp_x = fp_x_start
    li s1, -512
    iop0 s1, x0, 0b1000010 # 1 00 0010 erhöt s1 in alu2 um 1
    csrrs t5, x0, 0xF14
    beq t5, x0, x_loop
    addi s1, s1, 4

x_loop:
  # init to zero
  li s10, 0 #s10 : iter
  li s11, 0 #s11 : x
  li a7, 0 #a7 : y
  li a6, 0 #a6 : sx
  li a5, 0 #a5 : sy
  li a3, 0 #a3 : mask bit
  li a4, 0 #a4 : sum off bit masks
  
iter_loop:
  # if (sx+sy) >= fp_tresh then leave iter_loop  
  #set inverted mask to a3 if (sx+sy) >= fp_tresh
  add a0, a5, a6
  SLT a3, a0, s5
  
  add a4, x0, a3 #füge a3 alu1 zu mask summ hinzu
  iop0 a4, a3, 0b010001 #füge a3 alu2 zu mask summ hinzu
  beq x0, a4, iter_end

  # if iter = max_iter then leave iter_loop
  beq s10, s6, iter_end
  #get s10 from reg2
  iop1 t5, s10, 0b010001
  beq t5, s6, iter_end
  
  # sx = x * x
  add a1, x0, s11
  add a2, x0, s11
  jal ra, fp_mul  
  add a6, a0, x0
  
  # sy = y * y
  add a1, x0, a7
  add a2, x0, a7
  jal ra, fp_mul  
  add a5, a0, x0
  
  # y = 2 * x * y
  add a1, x0, s11
  add a2, x0, a7
  jal ra, fp_mul
  slli a7, a0, 1
  
  # y += fp_y
  add a7, a7, s3
  # x = sx - sy
  sub s11, a6, a5
  # x = x + fp_x
  add s11, s11, s1
  # iter = iter + 1
  add s10, s10, a3  
  jal x0, iter_loop
  
iter_end:
  # make space for another 2 pixel
  #first pixel
  srli s0, s0, 8
  slli s10, s10, 24
  or s0, s0, s10


  #second pixel
  srli s0, s0, 8
  iop1 t5, s10, 0b010001
  or s0, s0, t5
    
  # don't write if not 4 pixels computed
  addi s9, s9, -2
  bge s9, x0, iter_loop_header
  
  # store
  sw s0, 0(s7)
  # restore pixel cnt
  addi s9, x0, 3
  # incr frame pointer by 4*8 bit pixels
  addi s7, s7, 8 # asgfsagdfawdh fawhsasdf asgef awgef gzuasdgfuzasgdfgasdfghsadgfhasdgfh asgdf
  addi s1, s1, 4
  
  #reset mask register
  li a3, 0 #a3 : mask bit
  li a4, 0 #a4 : sum off bit masks
  
iter_loop_header:
  # fp_x += 2
  addi s1, s1, 2
  # if fp_x < fp_x_end then goto x_loop
  blt s1, s2, x_loop
  
  # fp_y = fp_y + fp_y_inc
  addi s3, s3, 1
  # if fp_y < fp_y_end then goto y_loop
  blt s3, s4, y_loop
  
  
  lui t1, 0x1C008
  lw t0, 0(t1) # load starting time
  csrrs a0, x0, 0xC01 # get current time
  sub a0, a0, t0 # calculate difference

  li a4, 0x1D000800
  call disp_ms


done:
  jal x0, done

fp_mul:
  mul a0, a1 , a2
  srai a0, a0, 8
  jalr x0, ra, 0


disp_ms: # write a0 milliseconds on screen left of position a4, formatted as X.XXXs
addi s0, ra, 0 # store return address

li t1, 0x00ffff00 # write "s"
li t2, 0xff000000
li t3, 0x000000ff
addi t4, a4, 1920
sw t1, -640(t4)
sw t3, 0(t4)
sw t1, 640(t4)
sw t2, 1280(t4)
sw t1, 1920(t4)
addi a4, a4, -6

addi a2, x0, 10 # we always divide by 10 here
addi s1, x0, 3 # decimal point countdown

disp_ms_loop:
addi a1, a0, 0 # take input or last quotient as new numerator
call intdiv
call digit
addi a4, a4, -6 # offset for next digit
addi s1, s1, -1 # countdown for decimal point
bne s1, x0, disp_ms_loop_end # write decimal point only at exact right place
addi t2, x0, 0x0ff # pixel value of decimal point
addi t3, a4, 1920
sb t2, 1923(t3) # write to correct pixel position
addi a4, a4, -3 # offset next digit by another 3 pixels to make space for decimal point
disp_ms_loop_end:
bgt a0, x0, disp_ms_loop

addi ra, s0, 0 # restore return address
ret


digit: # write digit a3 at location a4
addi t0, x0, 0 # top segment
addi t1, x0, 0 # top left/right segments
addi t2, x0, 0 # mid segment
addi t3, x0, 0 # bottom left/right segments
addi t4, x0, 0 # bottom segment

addi t5, x0, 1
sll t5, t5, a3 # encode digit as one-hot encoding

# digit_check_t:
andi t6, t5, 0b0000010010
bne t6, x0, digit_check_tr
li t0, 0x00ffff00

digit_check_tr:
andi t6, t5, 0b0001100000
bne t6, x0, digit_check_tl
lui t1, 0xff000

digit_check_tl:
andi t6, t5, 0b0010001110
bne t6, x0, digit_check_m
addi t1, t1, 0x0ff

digit_check_m:
andi t6, t5, 0b0010000011
bne t6, x0, digit_check_br
li t2, 0x00ffff00

digit_check_br:
andi t6, t5, 0b0000000100
bne t6, x0, digit_check_bl
lui t3, 0xff000

digit_check_bl:
andi t6, t5, 0b1010111010
bne t6, x0, digit_check_b
addi t3, t3, 0x0ff

digit_check_b:
andi t6, t5, 0b0010010010
bne t6, x0, digit_end
li t4, 0x00ffff00

digit_end:
addi t6, a4, 0
lw t5, 0(t6)
or t5, t5, t0
sw t5, 0(t6)
addi t6, t6, 640
lw t5, 0(t6)
or t5, t5, t1
sw t5, 0(t6)
addi t6, t6, 640
lw t5, 0(t6)
or t5, t5, t1
sw t5, 0(t6)
addi t6, t6, 640
lw t5, 0(t6)
or t5, t5, t2
sw t5, 0(t6)
addi t6, t6, 640
lw t5, 0(t6)
or t5, t5, t3
sw t5, 0(t6)
addi t6, t6, 640
lw t5, 0(t6)
or t5, t5, t3
sw t5, 0(t6)
addi t6, t6, 640
lw t5, 0(t6)
or t5, t5, t4
sw t5, 0(t6)
ret

intdiv: # a0 = a1 / a2, remainder a3
addi a0, x0, 0
addi a3, x0, 0
li t0, 0x80000000 #bitmask
divloop:
slli a3, a3, 1
and t1, a1, t0
beq t1, x0, div_noinc
ori a3, a3, 1
div_noinc:
blt a3, a2, divend
sub a3, a3, a2
or a0, a0, t0
divend:
srli t0, t0, 1
bne t0, x0, divloop
ret

