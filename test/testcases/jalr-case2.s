lui $s3, 49088 # 0xBFC0
addiu $s3, $s3, 20
jalr $s2, $s3   # $ra = pc  pc = 14
addiu $v0, $s0, 10
halt
addu $v0, $s0, $s3   # $v0 = $ra 
halt
addiu $v0, $s0, 15
halt