addiu $s1, $s0, 10
blez $s1, 5
addiu $s1, $s0, 11 # will be executed
addu $v0, $s0, $s1
halt # pc = 5, v0 = 11
addiu $s1, $s0, 14 # will be jumped
addu $v0, $s0, $s1
halt # should not reach here