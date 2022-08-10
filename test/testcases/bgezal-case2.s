lui $s1, 49088
addiu $s1, $s0, 10
bgezal $s1, 6
addiu $s1, $s0, 11 # will be jumped
addiu $s1, $s0, 12 # will be jumped
addiu $s1, $s0, 13 # will be jumped
addiu $s1, $s0, 14 # will be jumped
addiu $s1, $s0, 15 # will be jumped
addu $v0, $s0, $ra
halt 