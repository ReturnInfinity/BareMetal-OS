; Adapted from https://stackoverflow.com/questions/72947069/how-to-write-hello-world-efi-application-in-nasm
; PE https://wiki.osdev.org/PE
; GOP https://wiki.osdev.org/GOP
; Automatic boot: Assemble and save as /EFI/BOOT/BOOTX64.EFI

bits 64
DEFAULT REL

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
NUMBER_OF_SECTIONS:		dw 3				; Number of sections. Indicates size of section table that immediately follows the headers
CREATED_DATE_TIME:		dd 1670698099			; Number of seconds since 1970 since when the file was created
SYMBOL_TABLE_POINTER:		dd 0x00
NUMBER_OF_SYMBOLS:		dd 0x00
OHEADER_SIZE:			dw O_HEADER_END - O_HEADER	; Size of the optional header
CHARACTERISTICS:		dw 0x222E			; These are the attributes of the file

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
MAJOR_OS_VERSION:		dw 0x00
MINOR_OS_VERSION:		dw 0x00
MAJOR_IMAGE_VERSION:		dw 0x00
MINOR_IMAGE_VERSION:		dw 0x00
MAJOR_SUBSYS_VERSION:		dw 0x00
MINOR_SUBSYS_VERSION:		dw 0x00
WIN32_VERSION_VALUE:		dd 0x00				; Reserved, must be 0
IMAGE_SIZE:			dd END - START			; The size in bytes of the image when loaded in memory including all headers
HEADERS_SIZE:			dd HEADER_END - HEADER		; Size of all the headers
CHECKSUM:			dd 0x00
SUBSYSTEM:			dw 10				; The subsystem. In this case we're making a UEFI application.
DLL_CHARACTERISTICS:		dw 0b000011110010000
STACK_RESERVE_SIZE:		dq 0x200000			; Reserve 2MB for the stack
STACK_COMMIT_SIZE:		dq 0x1000			; Commit 4kb of the stack
HEAP_RESERVE_SIZE:		dq 0x200000			; Reserve 2MB for the heap
HEAP_COMMIT_SIZE:		dq 0x1000			; Commit 4kb of heap
LOADER_FLAGS:			dd 0x00				; Reserved, must be zero
NUMBER_OF_RVA_AND_SIZES:	dd 0x10				; Number of entries in the data directory

DATA_DIRECTORIES:
EDATA:
	.address	dd 0		; Address of export table
	.size		dd 0		; Size of export table
IDATA:
	.address	dd 0		; Address of import table
	.size		dd 0		; Size of import table
RSRC:
	.address	dd 0		; Address of resource table
	.size		dd 0		; Size of resource table
PDATA:
	.address	dd 0		; Address of exception table
	.size		dd 0		; Size of exception table
CERT:
	.address	dd 0		; Address of certificate table
	.size		dd 0		; Size of certificate table
RELOC:
	.address	dd END - START	; Address of relocation table
	.size		dd 0		; Size of relocation table
DEBUG:
	.address	dd 0		; Address of debug table
	.size		dd 0		; Size of debug table
ARCHITECTURE:
	.address	dd 0		; Reserved. Must be 0
	.size		dd 0		; Reserved. Must be 0
GLOBALPTR:
	.address	dd 0		; RVA to be stored in global pointer register
	.size		dd 0		; Must be 0
TLS:
	.address	dd 0		; Address of TLS table
	.size		dd 0		; Size of TLS table
LOADCONFIG:
	.address	dd 0		; Address of Load Config table
	.size		dd 0		; Size of Load Config table
BOUNDIMPORT:
	.address	dd 0		; Address of bound import table
	.size		dd 0		; Size of bound import table
IAT:
	.address	dd 0		; Address of IAT
	.size		dd 0		; Size of IAT
DELAYIMPORTDESCRIPTOR:
	.address	dd 0		; Address of delay import descriptor
	.size		dd 0		; Size of delay import descriptor
CLRRUNTIMEHEADER:
	.address	dd 0		; Address of CLR runtime header
	.size		dd 0		; Size of CLR runtime header
RESERVED:
	.address	dd 0		; Reserved, must be 0
	.size		dd 0		; Reserved, must be 0

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

	SECTION_RELOC:
		.name				db ".reloc", 0x00, 0x00
		.virtual_size			dd 0
		.virtual_address		dd END - START
		.size_of_raw_data		dd 0
		.pointer_to_raw_data		dd END - START
		.pointer_to_relocations		dd 0
		.pointer_to_line_numbers	dd 0
		.number_of_relocations		dw 0
		.number_of_line_numbers		dw 0
		.characteristics		dd 0xC2000040

times 4096-($-PE) db 0
HEADER_END:

CODE:	; The code begins here with the entry point
EntryPoint:
; Save the values passed by UEFI
mov [IMAGE_HANDLE], rcx
mov [SYSTEM_TABLE], rdx

;mov rax, [SYSTEM_TABLE]
;mov rax, [rax + EFI_SYSTEM_TABLE_BOOTSERVICES]
;mov [BS], rax

;mov rax, [SYSTEM_TABLE]
;mov rax, [rax + EFI_SYSTEM_TABLE_RUNTIMESERVICES]
;mov [RTS], rax

; Clear screen
mov rcx, [SYSTEM_TABLE]
mov rcx, [rcx + EFI_SYSTEM_TABLE_OUTPUT_PROTOCOL]
call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_CLEAR_SCREEN]

; Display starting message
lea rdx, [msg_start]
mov rcx, [SYSTEM_TABLE]
mov rcx, [rcx + EFI_SYSTEM_TABLE_OUTPUT_PROTOCOL]
call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING]

; Get Memory Map


; Set Video Mode
; Find the interface to GRAPHICS_OUTPUT_PROTOCOL
;mov rbx, [SYSTEM_TABLE]
;mov rbx, [rbx + EFI_SYSTEM_TABLE_BOOTSERVICES]
;mov rcx, EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID
;mov rdx, EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID+8
;lea r8, [Interface]
;call [rbx + EFI_BOOT_SERVICES_LOCATEPROTOCOL]
;cmp rax, EFI_SUCCESS
;jne failure
;mov rcx, [Interface]
;mov rcx, [rcx + 0x18 ] ;EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE
;mov rbx, [rcx + 0x18 ] ;EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE_FRAMEBUFFERBASE
;mov [FB], rbx
;mov rdi, rbx
;mov rcx, [rcx + 0x20 ] ;EFI_GRAPHICS_OUTPUT_PROTOCOL_MODE_FRAMEBUFFERSIZE
;mov [FBS], rcx
;mov eax, 0xffffffff
;mov rcx, 1000000
;rep stosd

; Exit Boot services
;mov rcx, [IMAGE_HANDLE]
; RDX memmapkey
;mov rbx, [SYSTEM_TABLE]
;mov rbx, [rbx + EFI_SYSTEM_TABLE_BOOTSERVICES]
;call [rbx + EFI_BOOT_SERVICES_EXITBOOTSERVICES]
;cmp rax, EFI_SUCCESS
;jne failure

; If this was a UEFI app we could "return" to it by uncommenting the lines below
;mov rax, EFI_SUCCESS					; Return value for UEFI
;ret
jmp $


failure:
lea rdx, [msg_failure]
mov rcx, [SYSTEM_TABLE]
mov rcx, [rcx + EFI_SYSTEM_TABLE_OUTPUT_PROTOCOL]
call [rcx + EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING]
jmp $

align 4096

CODE_END:

; Data begins here
DATA:
msg_start:		db __utf16__ `Starting...\n\0`
msg_failure:		db __utf16__ `System failure\n\0`
IMAGE_HANDLE:	dq 0	; EFI gives this in RCX
SYSTEM_TABLE:	dq 0	; And this in RDX
Interface:	dq 0
BS:		dq 0	; Boot services
RTS:		dq 0	; Runtime services
STK:		dq 0
FB:		dq 0	; Frame buffer base address
FBS:		dq 0	; Frame buffer size
HR:		dq 0
VR:		dq 0
PPS:		dq 0
memmapsize:	dq 4096
memmapkey:	dq 0
memmapdescsize:	dq 48
memmapdescver:	dq 0

EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_GUID:
dd 0x387477c2
dw 0x69c7,0x11d2
db 0x8e,0x39,0x00,0xa0,0xc9,0x69,0x72,0x3b

EFI_GRAPHICS_OUTPUT_PROTOCOL_GUID:
dd 0x9042a9de
dw 0x23dc, 0x4a38
db 0x96,0xfb,0x7a,0xde,0xd0,0x80,0x51,0x6a

align 4096
DATA_END:
END:

; Define the needed EFI constants and offsets here.
EFI_SUCCESS					equ 0
EFI_SYSTEM_TABLE_SIGNATURE			equ 0x5453595320494249

EFI_SYSTEM_TABLE_OUTPUT_PROTOCOL		equ 64
EFI_SYSTEM_TABLE_RUNTIMESERVICES		equ 88
EFI_SYSTEM_TABLE_BOOTSERVICES			equ 96

EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_RESET		equ 0
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_OUTPUTSTRING	equ 8
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_TEST_STRING	equ 16
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_QUERY_MODE	equ 24
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_SET_MODE	equ 32
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_SET_ATTRIBUTE	equ 40
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_CLEAR_SCREEN	equ 48
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_SET_CURSOR_POSITION	equ 56
EFI_SIMPLE_TEXT_OUTPUT_PROTOCOL_ENABLE_CURSOR	equ 64

EFI_BOOT_SERVICES_GETMEMORYMAP			equ 56
EFI_BOOT_SERVICES_LOCATEHANDLE			equ 176
EFI_BOOT_SERVICES_LOADIMAGE			equ 200
EFI_BOOT_SERVICES_EXIT				equ 216
EFI_BOOT_SERVICES_EXITBOOTSERVICES		equ 232
EFI_BOOT_SERVICES_LOCATEPROTOCOL		equ 320

EFI_RUNTIME_SERVICES_RESETSYSTEM		equ 104



; EOF