li a1, 4
li a2, -4

li a0, 0          # result
li t1, 0          # sign flag

bgez a1, check_a2   # If a1 >= 0, skip negation
neg a1, a1          # negate number
xori t1, t1, 1      # flip sign flag

check_a2:
    bgez a2, multiply  # If a2 >= 0, skip negation
    neg a2, a2         # negate number
    xori t1, t1, 1     # flip sign flag

multiply:
    mv t3, a2         # t3 = multiplier

multiply_loop:
    beqz t3, apply_sign # If t3 == 0
    add a0, a0, a1
    addi t3, t3, -1    # decrement multiplier
    j multiply_loop

apply_sign:
    beqz t1, done      # If sign flag 0
    neg a0, a0         # negate result

done:
