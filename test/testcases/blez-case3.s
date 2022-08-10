addiu $s1, $s0, 0
blez $s1, 8
addiu $s1, $s0, 20 # will be jumped
addiu $s1, $s0, 12 # will be jumped
addiu $s1, $s0, 13 # will be jumped
addiu $s1, $s0, 14 # will be jumped
addiu $s1, $s0, 15 # will be jumped
addiu $s1, $s0, 16 # will be jumped
addiu $s1, $s0, 17 # will be jumped
addiu $s3, $s0, 30 # arrives here
addu $v0, $s0, $s3
halt # pc = 2 + (2 * 4) = 10, pc = 12 and v0 = 0