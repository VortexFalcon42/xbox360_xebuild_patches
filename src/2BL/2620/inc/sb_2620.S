.include "macros.S"

#============================================================================
# SB 2620 patches for use with XDKBuild/J-Runner RGL.
# This 2BL is slightly faster than SB 14352 in my testing, so it's used to 
# adhere to default RGH 1.3 0 wire SMC time outs.
# RGH 1.3 2 wire support is NOT implemented yet, and 1 wire support
# is not tested. (test console - RGH 1.3 0 wire Jasper BB)
#============================================================================

#.globl _start
#_start:

.ifndef rgh13_01wire
#============================================================================
# The following 3 patches (and the HdrFixer patch) are here for building
# with compatibility for RGH 1.2, however XDKBuild timings may not work, so
# I wouldn't recommend doing so.
#============================================================================

#============================================================================
# change magic bytes so CB_A 9188 will load the bootloader like retail
# not needed with RGH 1.3 as CB_Y doesn't check the header
#============================================================================
.long 0x00000000
.long 0x00000001
.long 0x43420a3c

#============================================================================
# extend the ldr size to include header fixer
#============================================================================
MAKEPATCH 0xc
0:
    .long 0x4030
9:

#============================================================================
#   Branch To Header Fixer
#============================================================================
MAKEPATCH 0x3C0
0:
    b 0x3C48
9:
.endif

.ifdef vfuses
#============================================================================
# vfuses patch #1 credits to cOz
#============================================================================
MAKEPATCH 0x11d4
0:
	ld %r3, 0x258(%r29)	#Flashaddr in SB top
	lwz %r4, 0x64(%r3)	#addr to patch slot	
	lwz %r5, 0x70(%r3)	#patch slot size
	add %r3, %r3, %r4
	add %r4, %r3, %r5
	mr %r3, %r10	
	li %r5, 0xc	#number of fuse rows
	bl 0xb20 # 0x1d10
	ld %r31, 0xa0(%r1)
	rldicr %r11, %r31, 0, 1
	cmpldi %cr6, %r11, 0
	nop 

9:

#============================================================================
# li r4, 0x600 > li r4, 0x601
#============================================================================
MAKEPATCH 0x00000418
0:
	li %r4, 0x601
9:
.endif

#============================================================================
# skip the entirety of the fusecheck routine at 0x1180
#============================================================================
MAKEPATCH 0x4D4
0:
    nop
9:

.ifdef vfuses
#============================================================================
# vfuses patch #2 credits to cOz
#============================================================================
MAKEPATCH 0x1590
0:
	ld %r3, 0x258(%r26)	#Flashaddr in SB top
	lwz %r4, 0x64(%r3)	#addr to patch slot	
	lwz %r5, 0x70(%r3)	#patch slot size
	add %r3, %r3, %r4
	add %r4, %r3, %r5
	mr %r3, %r10
	li %r5, 0xc
	bl 0x764 # 0x1d10
9:
.endif

#============================================================================
# patch out call to RotSumSha from SHA_COMPUTE_3BL
# this saves a small amount of time before HWINIT starts
# so we don't exceed the IPC 0x12 timeout
#============================================================================
MAKEPATCH 0x19C8
0:
    nop
9:

#============================================================================
# make SC/SD RSA verification return success
#============================================================================
MAKEPATCH 0x33D0
0:
    li %r3, 0x1
    blr
9:

#============================================================================
# patch out panic 0xAB
#============================================================================
MAKEPATCH 0x1B50
0:
    nop
9:

.ifndef rgh13_01wire
#============================================================================
#  HdrFixer (not needed with rgh 1.3)
#============================================================================
MAKEPATCH 0x4000
    .set HdrFixer, PatchAddr
0:
    .long 0x53420a3c
    .long 0x00000000

    li %r9, 0x4000 # address of new header
    addis %r9, %r9, 1 # make it addr in soc ram 0x14000
	addis %r10, %r10, 1 # dest addr in soc ram 0x10000
	ld %r8, 0(%r9)
	std %r8, 0(%r10)
	li %r8, 0 # reg clean up r8 r9 r10 so it never happend
	li %r9, 0
	li %r10, 0
	lis %r3, 0x100 # first inst in sb
    b -0x3C68 #branch back to next inst	
9:
.endif

.ifdef rgh13_01wire
#============================================================================
# RGH 1.3 SMC keep alive branches
#============================================================================
MAKEPATCH 0x974 # branch to register setup function
0:
	b -0x6F4 # instead, branch to hwinit_init (stub at 0x280)
9:

MAKEPATCH 0x9C8
0:
	b -0x744 # continue delay loop (stub at 0x284)
9:

MAKEPATCH 0xF2C # hwinit branches here when complete
0:
	b -0xCA4 # go to hwinit_done instead (stub at 0x288)
9:

#============================================================================
# RGH 1.3 SMC keep alive (patch over pub RSA key) slightly modified
# from https://github.com/wurthless-elektroniks/modern-loadfare/blob/main/ppc/hwinit_smc_keepalive.s
#============================================================================
	MAKEPATCH 0x280
	.set HWINIT_MINIMUM_PC_VALUE, 0x01D0 # first IPC call happens later in the SC17489 hwinit bytecode

	.set SMC_HWINIT_KEEPALIVE_MSGID_0, 0xA2
	.set SMC_HWINIT_KEEPALIVE_MSGID_1, 0xE2

	.set SMC_HWINIT_DONE_MSGID, 0xA4

	.set BASE_AND, 0x100
0:
# stubs for branching
hwinit_init_branch:
	b hwinit_init
hwinit_delay_case_branch:
	b hwinit_delay_case
hwinit_done_branch:
	b hwinit_done

hwinit_register_setup_function:
	b 0xC30 # 0xEBC
hwinit_interpreter_top:
	b 0x6E8 # 0x978
hwinit_exit:
	b 0xC9C # 0xF30

	# ------------------------------------------------------------------------------------------------

hwinit_init:
    # in contrast to the postcounter code this only reads the timebase counter.
    # we can't talk to the SMC until the hwinit program has set up the BARs and sent command 0x12
    # so we'll wait until that happens before sending the keepalive messages
    mfspr   %r6,0x10c              # read timebase counter
    andis. %r6,%r6,BASE_AND
    std    %r6,-0xA8(%r1)   # store in safe space on stack

    bl hwinit_register_setup_function

    b hwinit_interpreter_top

# ------------------------------------------------------------------------------------------------

hwinit_delay_case:
    # normal hwinit code
    mulli %r6,%r6,50
    mfspr  %r8,0x10c
	add   %r8,%r8,%r6

_hwinit_delay_loop:
    mfspr %r7,0x10c
    cmpld %r7,%r8
    bgt hwinit_interpreter_top            # original instruction is a ble

    bl smc_ipc_tick

    b _hwinit_delay_loop # and keep running the delay

hwinit_done:
    lis %r5,0x8000                      # point r5 at southbridge (0x80000200EA000000)
    ori %r5,%r5,0x0200
    rldicr %r5,%r5,32,31
    oris %r5,%r5,0xEA00

    lis %r6,0x0400                      # set FIFO tx active

    # wait for SMC to acknowledge any message in its inbox
_hwinitdone_wait_fifo_free:
    lwz %r7,0x1084(%r5)
    and %r7,%r7,%r6
    cmpw %r7,%r6
    bne _hwinitdone_wait_fifo_free

    stw %r6,0x1084(%r5)
    
    lis %r6,(SMC_HWINIT_DONE_MSGID << 8) # write command to FIFO (SMC will not reply)
    stw %r6,0x1080(%r5)
    li %r6,0                            # release FIFO
    stw %r6,0x1084(%r5)                       

    # return success and go to epilogue as normal
    li %r5,0
    b hwinit_exit

# ------------------------------------------------------------------------------------------------

smc_ipc_tick:
    # do NOT touch %r8 during this function!!
    # %r5, %r6, %r7 are fair game

    # check that hwinit interpreter is past a certain point before sending SMC messages.
    # during hwinit, %r16 is the program counter and %r3 is the program base.
    subf %r5,%r3,%r16
    cmpwi %r5,HWINIT_MINIMUM_PC_VALUE
    blt _smc_ipc_tick_exit

    # otherwise, check timebase against last poll
    ld     %r6,-0xA8(%r1)               # read last poll
    andis. %r7,%r7,BASE_AND             # check bit (%r7 was last timebase poll in delay loop)
    cmpld  %r6,%r7                      # has the bit flipped?
    beq    _smc_ipc_tick_exit           # if it hasn't, exit
    std   %r7,-0xA8(%r1)                # update last poll state

    lis %r5,0x8000                      # point r5 at southbridge (0x80000200EA000000)
    ori %r5,%r5,0x0200
    rldicr %r5,%r5,32,31
    oris %r5,%r5,0xEA00

    lis %r7,0x0400                      # r7 = 0x04000000 (sets FIFO active)
_smcipctick_wait_fifo_free:
    lwz %r9,0x1084(%r5)
    and %r9,%r9,%r7
    cmpw %r9,%r7
    bne _smcipctick_wait_fifo_free

    stw %r7,0x1084(%r5)                 # start talking on FIFO
    lis %r7,(SMC_HWINIT_KEEPALIVE_MSGID_0 << 8)
    cmpwi %r6,0          # if the bit we checked earlier was 0, leave as-is
    beq _toggle_post_send_post
    lis %r7,(SMC_HWINIT_KEEPALIVE_MSGID_1 << 8)
_toggle_post_send_post:
    stw %r7,0x1080(%r5)                 # send SMC command (we don't care if it's acknowledged or not)
    li %r7,0                            # release FIFO
    stw %r7,0x1084(%r5)

_smc_ipc_tick_exit:
    blr
# zero out up to 0x380
.long 0x00000000
.long 0x00000000
.long 0x00000000
.long 0x00000000
9:
.endif

#============================================================================
	.long 0xFFFFFFFF
	.end
#============================================================================
