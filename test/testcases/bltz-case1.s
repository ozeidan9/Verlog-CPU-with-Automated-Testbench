addiu $s1, $s0, -10
bltz $s1, 5
addiu $s3, $s0, 11 # will be jumped
addiu $s1, $s0, 12 # will be jumped
addiu $s1, $s0, 13 # will be jumped
addiu $s1, $s0, 14 # will be jumped
addiu $s2, $s0, 15 # arrives here
addu $v0, $s0, $s2
halt # pc = 2 + (1 * 4) = 6, pc = 8 and v0 = -10