addiu $s1, $s0, 10
addiu $s2, $s0, 20
bne $s1, $s2, 7
addiu $s3, $s0, 11 # will be jumped
addiu $s1, $s0, 12 # will be jumped
addiu $v0, $s0, 13 # will be jumped
halt
addiu $s1, $s0, 14 # will be jumped
addiu $s1, $s0, 15 # will be jumped
addiu $s1, $s0, 16 # arrives here
addu $v0, $s1, $s2
halt # pc = 3 + (2 * 4) = 11, pc = 13 and v0 = 10