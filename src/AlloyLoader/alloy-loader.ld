ENTRY(_start)
SECTIONS
{
	. = 0x1E0000;
	.text : {
		*(.text)
		. = ALIGN(8);
	}
	.data : {
		*(.data)
		*(.rodata)
		. = ALIGN(8);
	}
	__bss_start = .;
	.bss : {
		bss = .; _bss = .; __bss = .;
		*(.bss);
	}
	end = .; _end = .; __end = .;
}
