lui $s1, 49088
lui $s2, 49088
lui $s3, 49088
addiu $s1, $s0, 10
addiu $s2, $s0, 5
beq $s1, $s2, 5
addiu $s3, $s0, 15
addiu $s2, $s0, 11
addiu $v0, $s0, 12
halt # Should stop here
addiu $s1, $s0, 12
addu $v0, $s0, $s1
halt