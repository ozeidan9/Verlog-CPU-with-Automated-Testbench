lui $s0, 49088 # 0xBFC0
lui $s3, 58853 # 0xe5e5
addiu $s0, $s0, 400
addiu $s3, $s3, 5 
sw $s3, 0($s0)
lhu $v0, 2($s0) # v0 = 500
halt 
