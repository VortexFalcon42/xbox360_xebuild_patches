# Builds SB 1835 patch set with copyfuses patch and RGH 1.3 SMC keep alive support

.set vfuses, 0
.set copyfuses, 1
.set rgh13_01wire, 1

.include "sb_1835.S"
