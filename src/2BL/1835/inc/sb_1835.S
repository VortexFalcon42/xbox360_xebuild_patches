.include "macros.S"

#============================================================================
#  SB 1835 RGH 1.3 0 wire patches, many bricks later
#============================================================================

#.globl _start
#_start:

#============================================================================
#  change header to point to new entry point at 0x3C0
#============================================================================
MAKEPATCH 0x8
0:
	.long 0x000003C0
9:

#============================================================================
#  xeBuild expects 0x3B0 - 0x3BC to be empty, so zero it out
#============================================================================
MAKEPATCH 0x3B0
0:
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
	.long 0x00000000
9:

#============================================================================
#  branch from new entry point (0x3C0) to trampoline at 0x27C8
#============================================================================
MAKEPATCH 0x3C0
0:
	b 0x2408
9:

#============================================================================
#  since we patch out calls to RotSumSha, we'll use some of its space for
#  our trampoline from 0x3C0
#============================================================================
MAKEPATCH 0x27C8
0:
    lis %r3, 0x100
	.long 0x7C201A24 # tlbiel r3,r1,0,0,0
	sync
	li %r3, 0x200
	oris %r3, %r3, 0x8000
    rldicr %r3, %r3, 0x20, 0x1f
    oris %r3, %r3, 0x6 # initial r3 setup is done, so we can jump back
    b -0x241C # jump back to 0x3CC to continue execution as normal
9:

#============================================================================
#  hwinit interpreter trampoline
#============================================================================
MAKEPATCH 0xAB4
0:
    b 0x1D34 # 0x27E8
9:

#============================================================================
#  This replicates part of the functionality of later 2BL HWINIT interpreters.
#  With the existing logic, HWINIT will appear to succeed
#  but the kernel will not boot.
#============================================================================
MAKEPATCH 0x27E8
0:
ab4_trampoline: # replacing existing logic at 0xAB4
    cmplwi %r6, 0x1
    beq ad4_trampoline
    rlwinm %r8, %r18, 0x2, 0xe, 0x1d
    add %r16, %r3, %r8
    rldimi %r18, %r27, 0x0, 0x30
    rldimi %r27, %r28, 0x0, 0x30
    rldicl %r18, %r18, 0x30, 0x0
    rldicl %r27, %r27, 0x30, 0x0
    rldicl %r28, %r28, 0x30, 0x10
    cmpld %r16, %r3
    bne -0x1EA8 # 0x968
    b -0x192C # 0xEE8

ad4_trampoline: # replacing existing logic at 0xAD4
    subf %r7, %r3, %r16
    rlwinm %r7, %r7, 0x1e, 0x10, 0x1f
    rldicl %r8, %r28, 0x10, 0x30
    cmpldi %r8, 0x0
    bne return_failure_goto_epilogue
    rldicl %r28, %r28, 0x10, 0x0
    rldicl %r27, %r27, 0x10, 0x0
    rldicl %r18, %r18, 0x10, 0x0
    rldimi %r28, %r27, 0x0, 0x30
    rldimi %r27, %r18, 0x0, 0x30
    rldimi %r18, %r7, 0x0, 0x30
    rlwinm %r8, %r17, 0x2, 0xe, 0x1d
    add %r16, %r3, %r8
    b -0x1EE4 # 0x968

return_failure_goto_epilogue:
    li %r5, 0x1
    b -0x1968 # 0xEEC
9:

#============================================================================
#  hwinit register setup trampoline
#============================================================================
MAKEPATCH 0xEB0
0:
    b 0x19A8 # 0x2858
9:

#============================================================================
#  we must also initialise r27/r28 as part of the register setup
#============================================================================
MAKEPATCH 0x2858
0:
    li %r18, 0x0 # init r18 as we patched over it
    li %r27, 0x0
    li %r28, 0x0
    b -0x19B0 # jump back to 0xEB4
9:

.ifdef copyfuses
#============================================================================
#  CopyFuses (Thanks to Scar!)
#============================================================================
.set CopyFusesLegacy, 0x1194
.set CopyFusesOpt, 0x1538

MAKEPATCH CopyFusesLegacy
0:
    b 0x1D0
9:

MAKEPATCH CopyFusesOpt
0:
    b 0x20
9:
.endif

#============================================================================
# patch out call to RotSumSha from SHA_COMPUTE_3BL
# this saves a small amount of time before HWINIT starts
# so we don't exceed the IPC 0x12 timeout
#============================================================================
MAKEPATCH 0x1970
0:
    nop
9:

#============================================================================
# patch out call to RotSumSha from SHA_COMPUTE_4BL
#============================================================================
MAKEPATCH 0x1BCC
0:
    nop
9:

.ifdef vfuses
#============================================================================
#	Vfuses patch #1 credits to cOz
#============================================================================
MAKEPATCH 0x1194
0:
	ld %r3, 0x258(%r29)	#Flashaddr in SB top
	lwz %r4, 0x64(%r3)	#addr to patch slot	
	lwz %r5, 0x70(%r3)	#patch slot size
	add %r3, %r3, %r4
	add %r4, %r3, %r5
	mr %r3, %r10	
	li %r5, 0xc	#number of fuse rows
	bl 0xB00 # 0x1cb0
	ld %r31, 0xa0(%r1)
	rldicr %r11, %r31, 0, 1
	cmpldi %cr6, %r11, 0
	nop 

9:

#============================================================================
# li r4, 0x600 > li r4, 0x601
#============================================================================
MAKEPATCH 0x00000408
0:
	li %r4, 0x601
9:
.endif

#============================================================================
# skip the entirety of the fusecheck routine at 0x1140
#============================================================================
MAKEPATCH 0x4C4
0:
   nop
9:

.ifdef vfuses
#============================================================================
#	Vfuses patch #2 credits to cOz
#============================================================================
MAKEPATCH 0x1538
0:
	ld %r3, 0x258(%r26)	#Flashaddr in SB top
	lwz %r4, 0x64(%r3)	#addr to patch slot	
	lwz %r5, 0x70(%r3)	#patch slot size
	add %r3, %r3, %r4
	add %r4, %r3, %r5
	mr %r3, %r10
	li %r5, 0xc
	bl 0x75C # 0x1cb0
9:
.endif

#============================================================================
# make SC/SD RSA verification return success
#============================================================================
MAKEPATCH 0x3370
0:
    li %r3, 0x1
    blr
9:

#============================================================================
#  patch out panic 0xAB
#============================================================================
MAKEPATCH 0x1AF8
0:
	nop
9:

.ifdef rgh13_01wire
#============================================================================
# RGH 1.3 SMC keep alive branches
#============================================================================
MAKEPATCH 0x964 # branch to register setup function
0:
	b -0x6D8 # instead, branch to hwinit_init (0x28C)
9:

MAKEPATCH 0x9B8
0:
	b -0x718 # continue delay loop (0x2A0)
9:

MAKEPATCH 0xEE8 # hwinit branches here when complete
0:
	b -0xC28 # go to hwinit_done instead (0x2C0)
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
hwinit_register_setup_function:
	b 0xC00 # 0xE80
hwinit_interpreter_top:
	b 0x6E4 # 0x968
hwinit_exit:
	b 0xC64 # 0xEEC

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
.long 0x00000000
.long 0x00000000
.long 0x00000000
9:
.endif

#============================================================================
	.long 0xFFFFFFFF
	.end
#============================================================================



