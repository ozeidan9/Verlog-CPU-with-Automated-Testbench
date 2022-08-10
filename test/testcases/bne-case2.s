addiu $s1, $s0, 10
addiu $s2, $s0, 10
bne $s1, $s2, 8 # condition not met.
addiu $s3, $s0, 60
addu $v0, $s0, $s3
halt
addiu $s4, $s0, 11
addiu $s1, $s0, 12
addiu $s1, $s0, 13
addiu $s1, $s0, 14
addiu $s1, $s0, 15
addiu $s1, $s0, 16
addu $v0, $s0, $s1
halt