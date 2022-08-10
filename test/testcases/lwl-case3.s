lui $s0, 49088 # 0xBFC0
addiu $s0, $s0, 400
addiu $s3, $s2, 994 # 0000 03E2
sw $s3, 0($s0)
lwl $v0, 2($s0) # v0 = 03E2 0000
halt # v0 = 65142784