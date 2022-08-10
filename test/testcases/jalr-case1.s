lui $s3, 49088 # 0xBFC0
addiu $s3, $s3, 28
jalr $s2, $s3 # $s2 = pc, pc = $s3
addiu $s1, $s0, 10
halt
addiu $v0, $s0, 15
halt
addu $v0, $s0, $s2   # $v0 = $s2
halt