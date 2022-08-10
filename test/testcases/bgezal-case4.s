addiu $s1, $s0, 0
bgezal $s1, 7
addiu $s1, $s0, 16 # will be jumped
addu $v0, $s0, $s1 # will be jumped
halt # pc = 5. should not reach here
addiu $s1, $s0, 14 # will be jumped
addiu $s1, $s0, 15 # will be jumped
addiu $s1, $s0, 16 # will be jumped
addu $v0, $s0, $ra
halt