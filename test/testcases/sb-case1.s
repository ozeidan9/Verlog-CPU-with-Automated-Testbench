lui $s0, 49088 # 0xBFC0
addiu $s0, $s0, 400
addiu $s3, $s2, 321 
addiu $s4, $s2, 10 
sw $s3, 0($s0)
sb $s4, 0($s0)
lw $v0, 0($s0) 
halt #$v0 = 266