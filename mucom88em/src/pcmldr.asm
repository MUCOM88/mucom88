;==========================================================================
; MUCOM88 Extended Memory Edition (MUCOM88em)
; t@C¼ : pcmldr.asm (Z80AZu\[X)
; @\ : TEh{[h2pADPCMf[^ Ç[`
; XVúF2019/10/25
;==========================================================================
; ¦{\[XÍMUSICLALF Ver.1.0`1.2¤ÊÌpcmldr.asmð³Éì¬µ½¨Å·B
;==========================================================================
	
	
	;                               0.1sec=&HDA
	;              [ADPCM]
	
DATA:EQU 03000H
DADR:EQU 0BFFEH
KEY:EQU 0BFFDH
VOLUME:EQU 0BFFCH
REPEAT:EQU 0BFFBH
;STADR1:EQU 0000H
;ENADR1:EQU 01000H
STADR1:EQU 0BFF0H
ENADR1:EQU 0BFF2H
BDAT1:EQU 0BFFEH
BDAT2:EQU 0BFFCH
BDAT3:EQU 0BFFAH
	
SETUP:	EQU	0C000H
BLOAD:	EQU	0EEBFH
BSAVE:	EQU	0EEC2H
CLS1:	EQU	05F0EH
ADR2:	EQU	0E300H
ISET:	EQU	0EEAAH
	
MAXNUM:	EQU	0E000H
	
	ORG	9000H
	
MAIN:
	JP	START
	JP	PLAY
	JP	PRINT
	
DRIVE:
	DB	1
	
START:
	LD	A,11H			;¡ÇÁFg£RAM(64KBÈã)¶Ý`FbN
	OUT	(0E2H),A		;¡
	LD	B,2			;¡
	LD	A,1			;¡
X0001:	OUT	(0E3H),A		;¡
	LD	A,0FFH			;¡
	LD	(0000H),A		;¡
	LD	A,(0000H)		;¡
	INC	A			;¡
	JR	NZ,X0002		;¡
	INC	A			;¡
	LD	(0000H),A		;¡
	LD	A,(0000H)		;¡
	DEC	A			;¡
	JR	NZ,X0002		;¡
	DJNZ	X0001			;¡
	JR	X0005			;¡
X0002:	LD	HL,X0004		;¡
	LD	DE,0F3C8H		;¡
	LD	BC,49			;¡
	LDIR				;¡
X0003:	JR	X0003			;¡
X0004:	DB	'¶¸Á®³RAM(64KB²¼Þ®³) ¶Þ Ä³»² »ÚÃ ²Å²ÀÒ ·ÄÞ³ ÃÞ·Ï¾Ý'	;¡
X0005:	XOR	A			;¡
	OUT	(0E2H),A		;¡
	
	CALL	CHK
	RET	C
	DI
	LD	(ED1+1),SP
	LD	SP,STACE
	EI
	
; ---	DRIVE No.INIT	---
	
	LD	A,(DRIVE)
	OR	A
	JR	NZ,ST2
	INC	A
ST2:
	CP	3
	JR	C,ST3
	LD	A,1
ST3:
	ADD	A,30H
	LD	HL,ISETNUM
	LD	(HL),A
	CALL	ISET
	
	
; ---	INIT BLOAD	---
	
	CALL	CLS1
	LD	HL,0
	LD	(VN),HL
	LD	(ADR1),HL
	
	LD	HL,MSG003
	CALL	DSPMSG
	LD	HL,FILE5
	CALL	BLOAD
	CALL	SETUP
	LD	HL,FILE1
	CALL	BLOAD
	
	CALL	R_MAIN
	
ED1:
	LD	SP,0
	RET
	
	
	
; ---	SAVE ADDRESS	---
SAVE:
	;LD	HL,MSG002
	;CALL	DSPMSG
	;LD	HL,SDATA
	;CALL	BSAVE
	;RET
	
	
; --	READ MAIN	---
	
R_MAIN:
	
	LD	A,(MAXNUM)
	
RELP:
	PUSH	AF
	
	IN	A,(9)
	BIT	6,A
	JP	Z,EXIT
	
	LD	HL,(VN)
	INC	HL
	LD	(VN),HL
	
	LD	HL,(VN)
	DEC	HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL	;*20H(32)
	
	LD	DE,0D000H
	ADD	HL,DE
	LD	(ADV),HL
	LD	DE,VNAME
	LD	BC,16
	LDIR
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	INC	HL
	LD	(ADRL),DE
	LD	E,(HL)
	INC	HL
	LD	D,(HL)
	LD	(ADRH),DE
	
	EX	DE,HL
	AND	A
	LD	DE,(ADRL)
	SBC	HL,DE
	LD	(WHL),HL
	
	SRL	H
	RR	L
	SRL	H
	RR	L	;HL=1/4
	LD	DE,(ADR1)
	ADD	HL,DE
	LD	(ADRE1),HL
	
	LD	HL,(VN)
	CALL	READM
	
	LD	HL,(ADR1)
	LD	(BDAT1),HL
	LD	HL,(ADRE1)
	LD	(BDAT2),HL
	
	LD	HL,(ADRL)
	LD	DE,3000H
	ADD	HL,DE
	LD	(BDAT3),HL
	
	CALL	PRINT
	
	LD	HL,(VN)
	DEC	HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL	;*8
	LD	DE,ADR2
	ADD	HL,DE
	LD	DE,(ADR1)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	LD	DE,(ADRE1)
	LD	(HL),E
	INC	HL
	LD	(HL),D
	INC	HL
	INC	HL
	INC	HL
	
	LD	DE,(ADV)
	LD	A,1BH
	ADD	A,E
	LD	E,A
	ADC	A,D
	SUB	E
	LD	D,A
	LD	A,(DE)
	LD	(HL),A
	
	
	LD	HL,(ADRE1)
	LD	DE,4
	ADD	HL,DE
	LD	(ADR1),HL
	
	POP	AF
	
	DEC	A
	JP	NZ,RELP
	RET
	
	
EXIT:
	POP	DE
	POP	DE
	LD	HL,MSG001
	CALL	DSPMSG
	JP	ED1
	
	
READM:
	CALL	CCHR
	LD	A,H
	OR	A
	JR	NZ,RL2
	LD	H,020H
RL2:
	LD	(VNUM),HL
	LD	(VNUM2),HL
	
	LD	HL,FILE3
	CALL	DSPMSG
	LD	HL,FILE32
	CALL	DSPMSG
	LD	HL,FILE2
	CALL	BLOAD
	LD	HL,FILE4
	CALL	DSPMSG
	RET
	
; **	NUMBER=>CHR CODE	**
	
	;IN:HL
CCHR:
	CALL	21FDH
	CALL	28D0H
	INC	HL
	LD	A,(HL)
	INC	HL
	LD	H,(HL)
	LD	L,A
	RET
	
	
; **	PRINT TO DISPLAY	**
	
DSPMSG:
	LD	A,(HL)
	AND	A
	RET	Z
	RST	18H
	INC	HL
	JR	DSPMSG
	
	
; **	ÎÞ°ÄÞ Áª¯¸	*
	
CHK:
	DI
	LD	C,044H
	CALL	STT1
	DEC	A
	JR	Z,STTE
	LD	C,0A8H
	CALL	STT1
	DEC	A
	JR	Z,STTE
	SCF
STTE:
	EI
	RET
	
; --	CHECK BORD TYPE	--
	
STT1:
	LD	A,0FFH
	OUT	(C),A
	PUSH	BC
	POP	BC
	INC	BC
	IN	A,(C)
	RET
	
	
; **	PCM WRITE	**
	
	
PRINT:
	DI
	LD	A,(0E6C2H)
	OR	2
	OUT	(031H),A
	;
	CALL HANDAN
	
	
	;
	LD HL,(BDAT1)
	LD (ADRS1),HL
	LD HL,(BDAT2)
	LD (ADRS2),HL
	;
	LD HL,(BDAT3)
	LD (ADRS3),HL
	CALL PCMWRITE
	
	LD	A,(0E6C2H)
	OUT	(031H),A
	EI
	RET
HANDAN:
	LD BC,0044H
PR2:
	IN      A,(C)
	JP      M,PR2
	
	LD	A,0FFH
	OUT	(C),A
	PUSH	BC
	POP	BC
	INC	BC
	IN	A,(C)
	DEC	A
	JR	Z,PR3
	
	LD	A,0ACH
	LD	(PORT1),A
	RET
PR3:
	LD	A,046H
	LD	(PORT1),A
        RET
	
	
	
	
	
	                ;PLAY/RECORD  0.1SEC=01000H/10
	                ;
	                ;READ/WRITE   0.1SEC=01000H*4
	                ;
PLAY:
	CALL HANDAN
	;
	LD A,(0BFFFH)
	LD L,A
	LD H,0
	ADD HL,HL
	ADD HL,HL
	ADD HL,HL
	LD DE,0A000H
	ADD HL,DE
	;
	LD E,(HL)
	INC HL
	LD D,(HL)
	INC HL
	LD (ADRS1),DE
	LD E,(HL)
	INC HL
	LD D,(HL)
	INC HL
	LD (ADRS2),DE
	LD E,(HL)
	INC HL
	LD D,(HL)
	LD (RPADR1),DE
	;
	LD DE,049BBH
	LD (RATE),DE
	LD A,200
	LD (LEVEL),A
	CALL PCMPLAY
	RET
	
;-------------------------------------------------------------------------------
ADRS1:
	DW 0
ADRS2:
	DW 0
ADRS3:
	DW 0
ADRS4:
	DW 0
RPADR1:
	DW 0
RATE:
	DW 0
LEVEL:
	DB 0
PORT1:
	DB 0ACH
	;DB 046H
;-------------------------------------------------------------------------------
;
;			ADPCM RAM READ
;
;-------------------------------------------------------------------------------
PCMREAD:
				;[INITIALIZE]
	
	LD DE,021H
	CALL WRITE
	LD DE,020H
	CALL WRITE
	LD DE,0
	CALL WRITE
	LD DE,01000H    	;FLAG ENABLE
	CALL WRITE
	LD DE,01080H            ;FLAG RESET
	CALL WRITE
	LD DE,021H              ;RESET
	CALL WRITE
	LD DE,028H              ;MEMORY READ MODE
	CALL WRITE
	LD DE,0100H             ;MEMORY TYPE
	CALL WRITE
	;
	LD HL,(RATE)
	LD E,L
	LD D,09H
	CALL WRITE
	LD E,H
	INC D
	CALL WRITE
	LD DE,0CFFH             ;LIMIT ADDRESS (L)
	CALL WRITE
	INC D                   ;LIMIT ADDRESS (H)
	CALL WRITE
	;
	LD HL,(ADRS1)
	LD E,L
	LD D,02H
	CALL WRITE              ;START ADDRESS (L)
	LD E,H
	INC D
	CALL WRITE              ;START ADDRESS (H)
	LD HL,(ADRS2)
	LD E,L
	INC D
	CALL WRITE              ;STOP ADDRESS (L)
	LD E,H
	INC D
	CALL WRITE              ;STOP ADDRESS (H)
	;
	LD HL,(ADRS3)           ;MAIN RAM (DATA START)
	CALL READSUB            ;DUMMY READ *2
	CALL READSUB
	;
	LD HL,(ADRS3)
LOOP1:
	CALL READSUB
	INC HL
	AND 4
	JR Z,LOOP1
	;
	LD DE,0                 ;REGISTER RESET
	CALL WRITE
	RET
	
READSUB:
	LD A,(PORT1)
	LD C,A
WAIT2:
	IN A,(C)                ;FLAG CHECK
	JP M,WAIT2
	;
	LD A,08H                ;READ COMMAND
	OUT (C),A
WAIT21:
	IN A,(C)                ;FLAG CHECK
	JP M,WAIT21
	BIT 3,A
	JR Z,WAIT21
	;
	INC C
	IN A,(C)
	LD (HL),A
	;
	DEC C
WAITX1:
	IN A,(C)
	BIT 3,A
	JR Z,WAITX1
	RET
	
;-------------------------------------------------------------------------------
;
;			ADPCM RAM WRITE
;
;-------------------------------------------------------------------------------
PCMWRITE:
				;[INITIALIZE]
	
	LD DE,020H
	CALL  WRITE
	LD DE,021H
	CALL WRITE
	LD DE,0
	CALL WRITE
	LD DE,01000H    	;FLAG ENABLE
	CALL WRITE
	LD DE,01080H            ;FLAG RESET
	CALL WRITE
	LD DE,061H              ;RESET
	CALL WRITE
	LD DE,068H              ;MEMORY WRITE MODE
	CALL WRITE
	LD DE,0100H             ;MEMORY TYPE
	CALL WRITE
	;
	LD DE,0CFFH             ;LIMIT ADDRESS (L)
	CALL WRITE
	INC D                   ;LIMIT ADDRESS (H)
	CALL WRITE
	;
	LD HL,(ADRS1)
	LD E,L
	LD D,02H
	CALL WRITE              ;START ADDRESS (L)
	LD E,H
	INC D
	CALL WRITE              ;START ADDRESS (H)
	LD HL,(ADRS2)
	LD E,L
	INC D
	CALL WRITE              ;STOP ADDRESS (L)
	LD E,H
	INC D
	CALL WRITE              ;STOP ADDRESS (H)
	;
	LD A,(PORT1)
	LD C,A
SCHK:
	IN A,(C)
	AND 8
	JR Z,SCHK
	;
	LD HL,(ADRS3)           ;MAIN RAM (DATA START)
	;
LOOP2:
	LD D,08H
	LD E,(HL)
	INC HL
	CALL WRITE
	;
	LD A,(PORT1)
	LD C,A
FLAG21:
	IN A,(C)
	BIT 3,A                 ;BRDY FLAG CHECK
	JR Z,FLAG21
	AND 4                   ;EOS FLAG CHECK
	JR Z,LOOP2
	;
	LD E,0                  ;REGISTER RESET
	CALL WRITE
	RET
;-------------------------------------------------------------------------------
;
;                       PORT OUT
;
;------------------------------------------------------------------------------
WRITE:
 	PUSH BC
 	LD A,(PORT1)
 	LD C,A
WRLP1:
 	IN A,(C)
 	JP M,WRLP1
 	OUT (C),D
WRLP2:
 	IN A,(C)
 	JP M,WRLP2
 	;
 	INC C
 	OUT (C),E
 	POP BC
 	RET
;-------------------------------------------------------------------------------
;
;                       ADPCM PLAY (D/A)
;
;-------------------------------------------------------------------------------
	
PCMPLAY:
	                        ;[INITIALIZE]
	
	LD DE,021H              ;RESET
	CALL WRITE
	LD E,020H
	CALL WRITE
	LD E,0
	CALL WRITE
	LD DE,01000H            ;FLAG ENABLE
	CALL WRITE
	LD DE,01080H            ;FLAG RESET
	CALL WRITE
	LD DE,020H              ;MEM DATA SET
	CALL WRITE
	LD DE,01C0H             ;[LEFT,RIGHT,MIDLE],RAM TYPE,ROM
	CALL WRITE
	;
	LD HL,(ADRS1)           ;START ADDRESS (L)
	LD E,L
	LD D,02H
	CALL WRITE
	LD E,H                  ;START ADDRESS (H)
	INC D
	CALL WRITE
	LD HL,(ADRS2)           ;STOP ADDRESS (L)
	LD E,L
	INC D
	CALL WRITE              ;STOP ADDRESS (H)
	LD E,H
	INC D
	CALL WRITE
	LD D,0CH                ;LIMIT ADDRESS (L)
	LD E,0FFH
	CALL WRITE
	INC D                   ;LIMIT ADDRESS (H)
	LD E,0FFH
	CALL WRITE
	;
	LD HL,(RATE)            ;SUMPLING RATE (L)
	LD E,L
	LD D,09H
	CALL WRITE
	LD E,H                  ;SUMPLING RATE (H)
	INC D
	CALL WRITE
	LD A,(LEVEL)            ;OUT PUT LEVEL
	LD E,A
	LD D,0BH
	CALL WRITE
	LD DE,0A0H              ;PCM PLAY
	LD HL,0FFFFH
	LD BC,(RPADR1)
	AND A
	SBC HL,BC
	CALL NZ,RPSUB
	CALL WRITE
	;
	LD HL,(RPADR1)
	LD A,H
	INC A
	JP Z,HAN
	;
HAN2:
	LD D,02H
	LD E,L
	CALL WRITE
	INC D
	LD E,H
	CALL WRITE
	RET
HAN:
	LD A,L
	INC A
	JP NZ,HAN2
	RET
RPSUB:
	LD DE,0B0H
	RET
	
ISETNUM:
	DB	0,0
FILE1:
	DB	'"DATA"',0
FILE2:
	DB	'"VOICE . '
VNUM:	DB	'  "',0
FILE3:
	DB	'PCM NO.'
VNUM2:
	DB	'  :'
VNAME:
	DS	16
	DB	0
FILE32:
	DB	'NOW LOADING...',0
FILE4:
	DB	'...Done',0AH,0
FILE5:
	DB	'"setup"',0
VN:
	DW	0
SDATA:
	DB	'"PCM.adr",&H6000,&H100',0
MSG001:
	DB	'PCM LOADING SKIP!!',0
MSG002:
	;DB	'NOW SAVING PCM ADDRESS...',0
MSG003:
	DB	'SPACE KEY/SKIP LOADING',0AH,0
	
ADR1:	DW	0
ADRE1:	DW	0
ADRL:	DW	0
ADRH:	DW	0
WHL:	DW	0
ADV:	DW	0
	
	
STAC:
	DS	250,0
STACE:
