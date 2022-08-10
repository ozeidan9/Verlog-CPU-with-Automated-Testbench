lui $s1, 49088
lui $s2, 49088
lui $s3, 49088
addiu $s1, $s0, 10
addiu $s2, $s0, 10
beq $s1, $s2, 5
addiu $s3, $s0, 15 # jumped
addiu $s2, $s0, 11 # jumped
addiu $v0, $s0, 12
halt
addu $v0, $s0, $s1
halt # pc = 3, no change because offset = 0