lui $s0, 49088 # 0xBFC0
addiu $s0, $s0, 400
addiu $s3, $s2, 994 # 0x0000 03E2
sw $s3, 0($s0)
lwl $v0, 3($s0) # v0 = E200 0000
halt # v0 = 3791650816