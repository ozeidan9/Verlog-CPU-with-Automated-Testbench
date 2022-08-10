addiu $s1, $s0, 0
bgtz $s1, 6
addiu $s1, $s0, 11
addu $v0, $s0, $s1
halt # pc = 5. v0 = 11
addiu $s1, $s0, 14 # will be jumped
addiu $s1, $s0, 15 # will be jumped
addiu $s1, $s0, 16 # will be jumped
addiu $v0, $s0, 17 # will be jumped
halt # should not reach here