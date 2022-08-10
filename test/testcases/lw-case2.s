lui $s0, 49088 # 0xBFC0
addiu $s0, $s0, 400
addiu $s3, $s2, 1500 
sw $s3, 4($s0)
lw $v0, 4($s0) # v0 = 500
halt 
