lui $s0, 49088 # 0xBFC0
addiu $s0, $s0, 400
lui $s3, 58338 #  E3E2 0000
sw $s3, 0($s0)
sw $s3, 4($s0)
lwr $v0, 2($s0) # 00E3 E200
halt # v0=14934528