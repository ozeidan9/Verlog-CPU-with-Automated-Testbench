addiu $s2, $s0, 15 # s2=15
addiu $s3, $s0, 15 # s3=15
addiu $s1, $s0, 10 # s1=10
j 3   # pc = 20 + 8 = 26
addiu $s1, $s0, 4
addiu $v0, $s1, 10
halt
addiu $v0, $s0, 20   # $v0 = $ra = 2
halt