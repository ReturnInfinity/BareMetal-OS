// =====================================================================================
// BareMetal Image Maker -- The tool for creating an image from the BareMetal artifacts.
// Copyright (C) 2008-2017 Return Infinity -- see LICENSE
//
// Version 1.0
// =====================================================================================

#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

static int cat(FILE *dst, const char *filename)
{
	FILE *src = fopen(filename, "rb");
	if (src == NULL) {
		fprintf(stderr, "Failed to open '%s': %s\n", filename, strerror(errno));
		return EXIT_FAILURE;
	}

	unsigned char *buf = malloc(4096);
	if (buf == NULL)
	{
		fprintf(stderr, "Failed to allocate write buffer: %s\n", strerror(errno));
		fclose(src);
		return EXIT_FAILURE;
	}

	while (!feof(src)) {
		size_t read_count = fread(buf, 1, 4096, src);
		size_t total_write_count = 0;
		while (total_write_count < read_count) {
			size_t write_count = fwrite(&buf[total_write_count], 1, read_count - total_write_count, dst);
			total_write_count += write_count;
		}
	}

	fclose(src);

	return EXIT_SUCCESS;
}

struct image_plan
{
	const char *bootsector;
	const char *pure64;
	const char *kernel;
	const char *alloy;
	const char *image;
};

void image_plan_init(struct image_plan *plan)
{
	plan->bootsector = "bmfs_mbr.sys";
	plan->pure64 = "pure64.sys";
	plan->kernel = "kernel.sys";
	plan->alloy = "alloy.bin";
	plan->image = "bmfs.image";
}

int image_plan_execute(const struct image_plan *plan)
{
	FILE *image = fopen(plan->image, "rb+");
	if (image == NULL) {
		fprintf(stderr, "Failed to open '%s': %s\n", plan->image, strerror(errno));
		return EXIT_FAILURE;
	}

	int err = cat(image, plan->bootsector);
	if (err != EXIT_SUCCESS) {
		fclose(image);
		return err;
	}

	err = fseek(image, 0x2000, SEEK_SET);
	if (err != 0) {
		fprintf(stderr, "Failed to seek to 0x2000: %s\n", strerror(errno));
		fclose(image);
		return EXIT_FAILURE;
	}

	err = cat(image, plan->pure64);
	if (err != EXIT_SUCCESS) {
		fclose(image);
		return err;
	}

	err = cat(image, plan->kernel);
	if (err != EXIT_SUCCESS) {
		fclose(image);
		return err;
	}

	err = cat(image, plan->alloy);
	if (err != EXIT_SUCCESS) {
		fclose(image);
		return err;
	}

	fclose(image);

	return EXIT_SUCCESS;
}

int main(int argc, const char **argv)
{
	struct image_plan plan;

	image_plan_init(&plan);

	return image_plan_execute(&plan);
}

