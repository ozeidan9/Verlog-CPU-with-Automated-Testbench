addiu $s1, $s0, -10
bltzal $s1, 6
addiu $s1, $s0, 11 # will be jumped
addiu $s1, $s0, 12 # will be jumped
addiu $s1, $s0, 13 # will be jumped
addiu $v0, $s0, 14 # will be jumped
halt
addu $v0, $s0, $ra
halt # pc = 2 + (1 * 4) = 6, pc = 8 and v0 = 2