lui $s0, 49088 # 0xBFC0
addiu $s0, $s0, 400
lui $s3, 58338 #  E3E2 0000
sw $s3, 0($s0)
sw $s3, 4($s0)
lwl $v0, 3($s0) # E3E2 0000
lwr $v0, 3($s0) # E3E2 0000
halt # v0=3823239168

#mem403 : E 3 
#mem402 : E 2
#mem401 : 0 0
#mem400 : 0 0
#mem407 : E 3
#mem406 : E 2
#mem405 : 0 0
#mem404 : 0 0