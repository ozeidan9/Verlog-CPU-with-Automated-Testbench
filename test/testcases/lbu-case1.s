lui $s0, 49088 # 0xBFC0
lui $s3, 58853 # 0xe5e5
addiu $s0, $s0, 400
addiu $s3, $s3, 5 
sw $s3, 0($s0)
lbu $v0, 3($s0) # v0 = 229 (0xe5)
halt 
