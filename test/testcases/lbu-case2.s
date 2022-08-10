lui $s0, 49088 # 0xBFC0
addiu $s0, $s0, 400
addiu $s3, $s3, 80
sw $s3, 0($s0)
lbu $v0, 0($s0) 
halt 