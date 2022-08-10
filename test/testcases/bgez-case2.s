addiu $s1, $s0, -10
bgez $s1, 6
addiu $s1, $s0, 11 # will be jumped
addiu $v0, $s1, 12 # will be jumped
halt
addiu $s1, $s0, 13 # will be jumped
addiu $s1, $s0, 14 # will be jumped
addiu $s1, $s0, 15 # will be jumped
addiu $s1, $s0, 16 # will be jumped
addiu $s1, $s0, 17 # will be jumped
addiu $v0, $s0, 18 # will be jumped
halt # pc = 2 + (2 * 4) = 10, pc = 11