lui $s0, 49088 # 0xBFC0
addiu $s0, $s0, 400
addiu $s3, $s2, 3795 # 0000 0ED3
addiu $s4, $s2, 321  # 0000 0141
sw $s3, 0($s0)
sh $s4, 2($s0)
lw $v0, 0($s0) 
halt # $v0 = 266 # 0x1D3