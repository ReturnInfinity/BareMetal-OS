; =============================================================================
; UEFI loader for BareMetal
; Copyright (C) 2008-2022 Return Infinity -- see LICENSE.TXT
;
; Adapted from https://stackoverflow.com/questions/72947069/how-to-write-hello-world-efi-application-in-nasm
; and https://github.com/charlesap/nasm-uefi/blob/master/shoe-x64.asm
; PE https://wiki.osdev.org/PE
; GOP https://wiki.osdev.org/GOP
; Automatic boot: Assemble and save as /EFI/BOOT/BOOTX64.EFI
; =============================================================================

BITS 64
ORG 0x00400000

START:
PE:
HEADER:
DOS_HEADER:							; 128 bytes
DOS_SIGNATURE:			db 'MZ', 0x00, 0x00		; The DOS signature
DOS_HEADERS:			times 60-($-HEADER) db 0	; The DOS Headers
SIGNATURE_POINTER:		dd PE_SIGNATURE - START		; Pointer to the PE Signature
DOS_STUB:			times 64 db 0			; The DOS stub. Fill with zeros
PE_HEADER:							; 24 bytes
PE_SIGNATURE:			db 'PE', 0x00, 0x00		; This is the PE signature. The characters 'PE' followed by 2 null bytes
MACHINE_TYPE:			dw 0x8664			; Targeting the x86-64 machine
NUMBER_OF_SECTIONS:		dw 2				; Number of sections. Indicates size of section table that immediately follows the headers
CREATED_DATE_TIME:		dd 1670698099			; Number of seconds since 1970 since when the file was created
SYMBOL_TABLE_POINTER:		dd 0
NUMBER_OF_SYMBOLS:		dd 0
OHEADER_SIZE:			dw O_HEADER_END - O_HEADER	; Size of the optional header
CHARACTERISTICS:		dw 0x222E			; Attributes of the file

O_HEADER:
MAGIC_NUMBER:			dw 0x020B			; PE32+ (i.e. PE64) magic number
MAJOR_LINKER_VERSION:		db 0
MINOR_LINKER_VERSION:		db 0
SIZE_OF_CODE:			dd CODE_END - CODE		; The size of the code section
INITIALIZED_DATA_SIZE:		dd DATA_END - DATA		; Size of initialized data section
UNINITIALIZED_DATA_SIZE:	dd 0x00				; Size of uninitialized data section
ENTRY_POINT_ADDRESS:		dd EntryPoint - START		; Address of entry point relative to image base when the image is loaded in memory
BASE_OF_CODE_ADDRESS:		dd CODE - START			; Relative address of base of code
IMAGE_BASE:			dq 0x400000			; Where in memory we would prefer the image to be loaded at
SECTION_ALIGNMENT:		dd 0x1000			; Alignment in bytes of sections when they are loaded in memory. Align to page boundary (4kb)
FILE_ALIGNMENT:			dd 0x1000			; Alignment of sections in the file. Also align to 4kb
MAJOR_OS_VERSION:		dw 0
MINOR_OS_VERSION:		dw 0
MAJOR_IMAGE_VERSION:		dw 0
MINOR_IMAGE_VERSION:		dw 0
MAJOR_SUBSYS_VERSION:		dw 0
MINOR_SUBSYS_VERSION:		dw 0
WIN32_VERSION_VALUE:		dd 0				; Reserved, must be 0
IMAGE_SIZE:			dd END - START			; The size in bytes of the image when loaded in memory including all headers
HEADERS_SIZE:			dd HEADER_END - HEADER		; Size of all the headers
CHECKSUM:			dd 0
SUBSYSTEM:			dw 10				; The subsystem. In this case we're making a UEFI application.
DLL_CHARACTERISTICS:		dw 0
STACK_RESERVE_SIZE:		dq 0x200000			; Reserve 2MB for the stack
STACK_COMMIT_SIZE:		dq 0x1000			; Commit 4KB of the stack
HEAP_RESERVE_SIZE:		dq 0x200000			; Reserve 2MB for the heap
HEAP_COMMIT_SIZE:		dq 0x1000			; Commit 4KB of heap
LOADER_FLAGS:			dd 0x00				; Reserved, must be zero
NUMBER_OF_RVA_AND_SIZES:	dd 0x00				; Number of entries in the data directory
O_HEADER_END:

SECTION_HEADERS:
	SECTION_CODE:
		.name				db ".text", 0x00, 0x00, 0x00
		.virtual_size			dd CODE_END - CODE
		.virtual_address		dd CODE - START
		.size_of_raw_data		dd CODE_END - CODE
		.pointer_to_raw_data		dd CODE - START
		.pointer_to_relocations		dd 0
		.pointer_to_line_numbers	dd 0
		.number_of_relocations		dw 0
		.number_of_line_numbers		dw 0
		.characteristics		dd 0x70000020

	SECTION_DATA:
		.name				db ".data", 0x00, 0x00, 0x00
		.virtual_size			dd DATA_END - DATA
		.virtual_address		dd DATA - START
		.size_of_raw_data		dd DATA_END - DATA
		.pointer_to_raw_data		dd DATA - START
		.pointer_to_relocations		dd 0
		.pointer_to_line_numbers	dd 0
		.number_of_relocations		dw 0
		.number_of_line_numbers		dw 0
		.characteristics		dd 0xD0000040

times 1024-($-PE) db 0
HEADER_END:

CODE:	; The code begins here with the entry point
EntryPoint:
	; Save the values passed by UEFI
	mov [EFI_IMAGE_HANDLE], rcx
	mov [EFI_SYSTEM_TABLE], rdx
	mov [EFI_RETURN], rsp
	sub rsp, 6*8+8						; Fix stack

	; When calling an EFI function the caller must pass the first 4 integer values in registers
	; via RCX, RDX, R8, and R9
	; 5 and onward are on the stack

	; Save entry addresses
	mov rax, [EFI_SYSTEM_TABLE]
	mov rax, [rax + EFI_SYSTEM_TABLE_BOOTSERVICES]
	mov [BS], rax
	mov rax, [EFI_SYSTEM_TABLE]
	mov rax, [rax + EFI_SYSTEM_TABLE_RUNTIMESERVICES]
	mov [RTS], rax

	; Find the interface to output services via its GUID
	mov rcx, EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_GUID		; *Protocol
	mov rdx, 0						; *Registration OPTIONAL
	mov r8, OUTPUT						; **Interface
	mov rax, [BS]
	mov rax, [rax + EFI_BOOT_SERVICES_LOCATEPROTOCOL]
	call rax
	cmp rax, EFI_SUCCESS
	jne failure

	; Get current screen settings
	mov rcx, [OUTPUT]
	mov rdx, 0
	mov r8, Columns
	mov r9, Rows
	call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_QUERY_MODE]

	; Set screen colour attributes
	mov rcx, [OUTPUT]
	mov rdx, 0x7F						; Light grey background, white foreground
	call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_SET_ATTRIBUTE]

	; Clear screen
	mov rcx, [OUTPUT]
	call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_CLEAR_SCREEN]

	; Display starting message
	mov rcx, [OUTPUT]
	lea rdx, [msg_start]
	call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING]

	; Get Memory Map
	; IN OUT UINTN			*MemoryMapSize,
	;    OUT EFI_MEMORY_DESCRIPTOR	*MemoryMap,
	;    OUT UINTN			*MapKey,
	;    OUT UINTN			*DescriptorSize,
	;    OUT UINT32			*DescriptorVersion
get_memmap:
	lea rcx, [memmapsize]					; *MemoryMapSize
	lea rdx, 0x6000						; *MemoryMap
	lea r8, [memmapkey]					; *MapKey
	lea r9, [memmapdescsize]				; *DescriptorSize
	lea r10, [memmapdescver]				; *DescriptorVersion
	push r10
	mov rax, [BS]
	call [rax + EFI_BOOT_SERVICES_GETMEMORYMAP]
	cmp al, 5						; EFI_BUFFER_TOO_SMALL
	je get_memmap						; Attempt again as the memmapsize was updated by EFI
	cmp rax, EFI_SUCCESS
	jne failure
	; Output at 0x6000 is as follows:
	; 0  UINT32 - Type
	; 8  EFI_PHYSICAL_ADDRESS - PhysicalStart
	; 16 EFI_VIRTUAL_ADDRESS - VirtualStart
	; 24 UINT64 - NumberOfPages
	; 32 UINT64 - Attribute
	; 40 UINT64 - Blank

	; Find the interface to GRAPHICS_OUTPUT_PROTOCOL via its GUID
	mov rcx, EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID		; *Protocol
	mov rdx, 0						; *Registration OPTIONAL
	mov r8, VIDEO						; **Interface
	mov rax, [BS]
	mov rax, [rax + EFI_BOOT_SERVICES_LOCATEPROTOCOL]
	call rax
	cmp rax, EFI_SUCCESS
	jne failure

	; Parse the graphics information
	;
	; Mode Structure
	; 0  UINT32 - MaxMode
	; 4  UINT32 - Mode
	; 8  EFI_GRAPHICS_OUTPUT_MODE_INFORMATION - *Info;
	; 16 UINTN - SizeOfInfo
	; 24 EFI_PHYSICAL_ADDRESS - FrameBufferBase
	; 32 UINTN - FrameBufferSize
	;
	; EFI_GRAPHICS_OUTPUT_MODE_INFORMATION Structure
	; 0  UINT32 - Version
	; 4  UINT32 - HorizontalResolution
	; 8  UINT32 - VerticalResolution
	; 12 EFI_GRAPHICS_PIXEL_FORMAT - PixelFormat (UINT32)
	; 16 EFI_PIXEL_BITMASK - PixelInformation (4 UINT32 - RedMask, GreenMask, BlueMask, ReservedMask)
	; 32 UINT32 - PixelsPerScanLine (Should be the same as HorizontalResolution)
	mov rbx, [VIDEO]
	add rbx, EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE
	mov rbx, [rbx]			; RAX holds the address of the Mode structure
	mov rax, [rbx+24]		; RAX holds the FB base
	mov [FB], rax			; Save the FB base
	mov rax, [rbx+32]		; RAX holds the FB size
	mov [FBS], rax			; Save the FB size
	mov rbx, [rbx+8]		; RBX holds the address of the EFI_GRAPHICS_OUTPUT_MODE_INFORMATION Structure
	mov eax, [rbx+4]		; RAX holds the Horizontal Resolution
	mov [HR], rax			; Save the Horizontal Resolution
	mov eax, [rbx+8]		; RAX holds the Vertical Resolution
	mov [VR], rax			; Save the Vertical Resolution
	; TODO - Check EFI_GRAPHICS_PIXEL_FORMAT (RBX+12) to make sure bit 0 is set (32-bit colour mode), otherwise parse EFI_PIXEL_BITMASK  

	; Clear the screen via the frame buffer
;	mov rdi, [FB]
;	mov eax, 0x00404040
;	mov rcx, [FBS]
;	shr rcx, 2			; Quick divide by 4 (32-bit colour)
;	rep stosd

	; Disable watchdog timer
	xor ecx, ecx			; Timeout
	xor edx, edx			; WatchdogCode
	xor r8, r8			; DataSize
	xor r9, r9			; *WatchdogData OPTIONAL
	mov rax, [BS]
	call [rax + EFI_BOOT_SERVICES_SETWATCHDOGTIMER]
	cmp rax, EFI_SUCCESS
	jne failure

	; Copy Pure64 to the correct memory address
	cli				; Stop interrupts
	mov rsi, END
	mov rdi, 0x8000
	mov rcx, 16384			; Copy 16KB
	rep movsb
	mov ax, [0x8006]
	cmp ax, 0x3436			; Match against the Pure64 binary
	jne sig_fail

	; Exit Boot services
	mov rcx, [EFI_IMAGE_HANDLE]
	mov rdx, [memmapkey]
	mov rbx, [BS]
	call [rbx + EFI_BOOT_SERVICES_EXITBOOTSERVICES]
	cmp rax, EFI_SUCCESS
	jne failure

	; Switch to 32-bit mode

	; Call Pure64
	mov rdi, [FB]
	mov eax, 0x0000FF00		; Green
	mov rcx, [FBS]
	shr rcx, 2			; Quick divide by 4 (32-bit colour)
	rep stosd
	jmp $


failure:
	mov rdi, [FB]
	mov eax, 0x00FF0000		; Red
	mov rcx, [FBS]
	shr rcx, 2			; Quick divide by 4 (32-bit colour)
	rep stosd
	lea rdx, [msg_failure]
	mov rcx, [OUTPUT]
	call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING]
	jmp halt
sig_fail:
	lea rdx, [msg_SigFail]
	mov rcx, [OUTPUT]
	call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING]
halt:
	hlt
	jmp halt

; -----------------------------------------------------------------------------
; debug_dump_(rax|eax|ax|al) -- Dump content of RAX, EAX, AX, or AL
;  IN:	RAX = content to dump
; OUT:	Nothing, all registers preserved
debug_dump_rax:
	rol rax, 8
	call debug_dump_al
	rol rax, 8
	call debug_dump_al
	rol rax, 8
	call debug_dump_al
	rol rax, 8
	call debug_dump_al
	rol rax, 32
debug_dump_eax:
	rol eax, 8
	call debug_dump_al
	rol eax, 8
	call debug_dump_al
	rol eax, 16
debug_dump_ax:
	rol ax, 8
	call debug_dump_al
	rol ax, 8
debug_dump_al:
	push rbx
	push rax
	mov rbx, hextable
	push rax			; Save RAX since we work in 2 parts
	shr al, 4			; Shift high 4 bits into low 4 bits
	xlatb
	mov [tchar+0], al
	pop rax
	and al, 0x0f			; Clear the high 4 bits
	xlatb
	mov [tchar+2], al
	push rdx
	push rcx
	lea rdx, [tchar]
	mov rcx, [OUTPUT]
	call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING]

	pop rcx
	pop rdx
	pop rax
	pop rbx
	ret
; -----------------------------------------------------------------------------


align 1024

CODE_END:

; Data begins here
DATA:
EFI_IMAGE_HANDLE:	dq 0	; EFI gives this in RCX
EFI_SYSTEM_TABLE:	dq 0	; And this in RDX
EFI_RETURN:		dq 0	; And this in RSP
BS:			dq 0	; Boot services
RTS:			dq 0	; Runtime services
OUTPUT:			dq 0	; Output services
VIDEO:			dq 0	; Video services
FB:			dq 0	; Frame buffer base address
FBS:			dq 0	; Frame buffer size
HR:			dq 0	; Horizontal Resolution
VR:			dq 0	; Vertical Resolution
memmapsize:		dq 0
memmapkey:		dq 0
memmapdescsize:		dq 0
memmapdescver:		dq 0
Columns:		dq 0
Rows:			dq 0

EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_GUID:
dd 0x387477c2
dw 0x69c7,0x11d2
db 0x8e,0x39,0x00,0xa0,0xc9,0x69,0x72,0x3b

EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID:
dd 0x9042a9de
dw 0x23dc, 0x4a38
db 0x96,0xfb,0x7a,0xde,0xd0,0x80,0x51,0x6a

hextable: 		db '0123456789ABCDEF'
msg_start:		db __utf16__ 'UEFI ', 0x00, 0x00
msg_failure:		db __utf16__ 'System failure - ', 0x00, 0x00
msg_SigFail:		db __utf16__ '- Bad Sig!', 0x00, 0x00
msg_space:		db 0x20, 0x00, 0x00, 0x00
msg_newline:		db 0x0D, 0x00, 0x0A, 0x00, 0x00, 0x00
tchar:			db 0, 0, 0, 0, 0, 0, 0, 0

align 4096
DATA_END:
END:

; Define the needed EFI constants and offsets here.
EFI_SUCCESS						equ 0
EFI_LOAD_ERROR						equ 1
EFI_INVALID_PARAMETER					equ 2
EFI_UNSUPPORTED						equ 3
EFI_BAD_BUFFER_SIZE					equ 4
EFI_BUFFER_TOO_SMALL					equ 5
EFI_NOT_READY						equ 6
EFI_DEVICE_ERROR					equ 7
EFI_WRITE_PROTECTED					equ 8
EFI_OUT_OF_RESOURCES					equ 9
EFI_VOLUME_CORRUPTED					equ 10
EFI_VOLUME_FULL						equ 11
EFI_NO_MEDIA						equ 12
EFI_MEDIA_CHANGED					equ 13
EFI_NOT_FOUND						equ 14

EFI_SYSTEM_TABLE_RUNTIMESERVICES			equ 88
EFI_SYSTEM_TABLE_BOOTSERVICES				equ 96

EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_RESET			equ 0
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING		equ 8
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_TEST_STRING		equ 16
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_QUERY_MODE		equ 24
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_SET_MODE		equ 32
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_SET_ATTRIBUTE		equ 40
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_CLEAR_SCREEN		equ 48
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_SET_CURSOR_POSITION	equ 56
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_ENABLE_CURSOR		equ 64
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_MODE			equ 70

EFI_BOOT_SERVICES_GETMEMORYMAP				equ 56
EFI_BOOT_SERVICES_LOCATEHANDLE				equ 176
EFI_BOOT_SERVICES_LOADIMAGE				equ 200
EFI_BOOT_SERVICES_EXIT					equ 216
EFI_BOOT_SERVICES_EXITBOOTSERVICES			equ 232
EFI_BOOT_SERVICES_STALL					equ 248
EFI_BOOT_SERVICES_SETWATCHDOGTIMER			equ 256
EFI_BOOT_SERVICES_LOCATEPROTOCOL			equ 320

EFI_GRAPHICS_OUTPUT_PROTOCOL_QUERY_MODE			equ 0
EFI_GRAPHICS_OUTPUT_PROTOCOL_SET_MODE			equ 8
EFI_GRAPHICS_OUTPUT_PROTOCOL_BLT			equ 16
EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE			equ 24

EFI_RUNTIME_SERVICES_RESETSYSTEM			equ 104

; EOF
