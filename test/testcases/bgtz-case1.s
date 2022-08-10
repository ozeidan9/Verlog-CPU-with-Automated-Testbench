addiu $s1, $s0, 10
addiu $s3, $s1, 5
bgtz $s1, 4 # 12 + 32 = 44
addiu $s1, $s0, 11 # will be jumped
addiu $v0, $s0, 13 # will be jumped
addiu $v0, $s0, 14 # will be jumped
addu $v0, $s0, $s3
halt # pc = 2 + (1 * 4) = 6, pc = 8 and v0 = 15