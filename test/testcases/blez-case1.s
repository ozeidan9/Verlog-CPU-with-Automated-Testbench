addiu $s1, $s0, -10
blez $s1, 5
addiu $s1, $s0, 11 # will be jumped
addiu $s1, $s0, 12 # will be jumped
addiu $s1, $s0, 13 # will be jumped
addiu $s1, $s0, 10 # will be jumped
addiu $s3, $s0, 14 # arrives here
addu $v0, $s0, $s3
halt # pc = 2 + (1 * 4) = 6, pc = 8 and v0 = -10