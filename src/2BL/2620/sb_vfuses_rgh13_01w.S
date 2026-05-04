# Builds SB 2620 patch set with vfuses enabled and RGH 1.3 SMC keep alive support

.set vfuses, 1
.set rgh13_01wire, 1

.include "sb_2620.S"
