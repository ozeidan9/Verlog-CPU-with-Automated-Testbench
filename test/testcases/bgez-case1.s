addiu $s1, $s0, 10
bgez $s1, 5
addiu $s3, $s0, 11 # will be jumped
addiu $v0, $s3, 12 # will be jumped
halt
addiu $s3, $s0, 15 # jump 
addiu $s2, $s0, 15 # arrive here
addu $v0, $s1, $s2
halt # pc = 2 + (2 * 4) = 10, pc = 11