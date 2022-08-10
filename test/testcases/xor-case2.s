addiu $s1, $s0, 4095
addiu $s2, $s0, 0
xor $v0, $s1, $s2
halt

# $v0 = 0