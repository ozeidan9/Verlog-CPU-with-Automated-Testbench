lui $s0, 49088 # 0xBFC0
addiu $s0, $s0, 400
addiu $s3, $s2, 321 
sw $s3, 0($s0)
lw $v0, 0($s0) # v0 = 321
halt 