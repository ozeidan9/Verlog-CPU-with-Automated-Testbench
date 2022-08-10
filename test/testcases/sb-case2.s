lui $s0, 49088 # 0xBFC0
addiu $s0, $s0, 400
addiu $s3, $s2, 3795 #0x0ED3
addiu $s4, $s2, 321  #0x141 
sw $s3, 0($s0)
sb $s4, 3($s0)
lw $v0, 0($s0) 
halt #$v0 = 266 (#0x1D3)
