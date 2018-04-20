#include <bmfs/bmfs.h>

#include "syscalls.h"

extern unsigned char sector[4096];

static bmfs_uint64 round_to_block(bmfs_uint64 size);

void _start(void)
{
	/* This is the sector that the file
	 * system begins at. */
	const bmfs_uint64 fs_offset = 8;

	/* Number of arguments passed to Alloy. */
	int argc = 1;

	/* The arguments passed to Alloy. */
	const char *argv[] = {
		"alloy",
		0
	};

	/* Where Alloy will be loaded. */
	void (*alloy_entry)(int, const char **argv) = (void(*)(int, const char **)) 0x200000;

	/* Read the file system header */
	b_disk_read(sector, fs_offset, 1, 0);
	if ((sector[0] != 'B')
	 || (sector[1] != 'M')
	 || (sector[2] != 'F')
	 || (sector[3] != 'S'))
	{
		b_output("Not a BMFS formatted drive.\n");
		return;
	}

	struct BMFSEntry *root_entry = (struct BMFSEntry *) &sector[512];

	bmfs_uint64 dir_offset = root_entry->Offset;

	unsigned long int read_count = b_disk_read(sector, fs_offset + (dir_offset / 4096), 1, 0);
	if (read_count != 1)
	{
		b_output("Failed to read '/'.\n");
		return;
	}

	/* Look for the '/sbin' directory. */

	struct BMFSEntry *sbin_ent = BMFS_NULL;

	for (bmfs_uint64 i = 0; i < 4096; i += 256)
	{
		struct BMFSEntry *ent = (struct BMFSEntry *) &sector[i];
		if ((ent->Name[0] == 'S')
		 && (ent->Name[1] == 'y')
		 && (ent->Name[2] == 's')
		 && (ent->Name[3] == 't')
		 && (ent->Name[4] == 'e')
		 && (ent->Name[5] == 'm')
		 && (ent->Name[6] == 0))
		{
			b_output("Found '/System'.\n");
			sbin_ent = ent;
			break;
		}
	}

	if (sbin_ent == BMFS_NULL)
	{
		b_output("Failed to find '/System'.\n");
		return;
	}

	bmfs_uint64 sbin_offset = sbin_ent->Offset;

	read_count = b_disk_read(sector, fs_offset + (sbin_offset / 4096), 1, 0);
	if (read_count != 1)
	{
		b_output("Failed to read '/System'.\n");
		return;
	}

	struct BMFSEntry *alloy_ent = BMFS_NULL;

	for (bmfs_uint64 i = 0; i < 4096; i += 256)
	{
		struct BMFSEntry *ent = (struct BMFSEntry *) &sector[i];
		if ((ent->Name[0] == 'a')
		 && (ent->Name[1] == 'l')
		 && (ent->Name[2] == 'l')
		 && (ent->Name[3] == 'o')
		 && (ent->Name[4] == 'y')
		 && (ent->Name[5] == '.')
		 && (ent->Name[6] == 'b')
		 && (ent->Name[7] == 'i')
		 && (ent->Name[8] == 'n')
		 && (ent->Name[9] == 0))
		{
			b_output("Found '/System/alloy.bin'.\n");
			alloy_ent = ent;
			break;
		}
	}

	if (alloy_ent == BMFS_NULL)
	{
		b_output("Failed to find '/System/alloy.bin'.\n");
		return;
	}

	bmfs_uint64 alloy_sector = alloy_ent->Offset;

	bmfs_uint64 alloy_size = alloy_ent->Size;

	read_count = b_disk_read(alloy_entry, fs_offset + (alloy_sector / 4096), round_to_block(alloy_size), 0);
	if (read_count != round_to_block(alloy_size))
	{
		b_output("Failed to read '/System/alloy.bin'.\n");
		return;
	}

	alloy_entry(argc, argv);
}

static bmfs_uint64 round_to_block(bmfs_uint64 size)
{
	return ((size + (4095)) / 4096) * 4096;
}

unsigned char sector[4096];
