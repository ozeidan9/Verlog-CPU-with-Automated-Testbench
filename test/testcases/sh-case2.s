lui $s0, 49088 # 0xBFC0
addiu $s0, $s0, 400
addiu $s3, $s2, 3795 # 0000 0ED3
addiu $s4, $s2, 321  # 0000 0141
sw $s3, 0($s0)
sh $s4, 3($s0)
lw $v0, 0($s0) 
halt # $v0 = 266 # 0x1D3

# 4100 0ed3
# 0001 41d3

# offset = 1 -> cpu hex : 0000 0141
# offset = 3 -> cpu hex : 0141 0ED3