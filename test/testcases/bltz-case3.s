addiu $s1, $s0, 0
bltz $s1, 4
addiu $s1, $s0, 11 
addu $v0, $s0, $s1
halt # pc = 5, v0 = 11
addiu $s1, $s0, 14 # will be jumped
addu $v0, $s0, $s1
halt # should not reach here.