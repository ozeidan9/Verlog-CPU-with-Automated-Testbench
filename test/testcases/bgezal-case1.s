lui $s1, 49088
lui $s2, 49088
lui $s3, 49088
addiu $s1, $s0, 10
addiu $s3, $s1, 5
bgezal $s1, 4
addiu $s1, $s0, 11 
addiu $s1, $s0, 12 # will be jumped
addiu $s1, $s0, 13 # will be jumped
addu $v0, $s0, $ra
halt 