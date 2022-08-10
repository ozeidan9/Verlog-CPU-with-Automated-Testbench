addiu $s1, $s0, -10  
bgezal $s1, 6
addiu $s1, $s0, 15
addu $v0, $s0, $s1
halt # pc = 5. branch condition not met. v0 = 11.
addiu $s1, $s0, 14 # will be jumped
addiu $s1, $s0, 16 # will be jumped
addu $v0, $s0, $ra
halt # never reaches here.