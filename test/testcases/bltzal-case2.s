addiu $s1, $s0, 10
bltzal $s1, 6
addiu $s1, $s0, 11 
addu $v0, $s0, $s1
halt
addiu $s1, $s0, 12 
addiu $s1, $s0, 13 
addiu $s1, $s0, 14 
addu $v0, $s0, $s1
halt # pc = 2 + (1 * 4) = 6, pc = 8 and v0 = 14