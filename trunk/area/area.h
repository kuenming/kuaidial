
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

#ifndef AREA_H
#define AREA_H

#ifdef __cplusplus
extern "C" {
#endif

#define AREA_VERSION 0x0001
#define AREA_ID 0x444b
#define AREA_INDEX_LENGHT 4
#define AREA_MAX_SEPARATE_LENGHT 4
#define AREA_MAX_NUMBER_LENGHT 8
#define AREA_MIN_NUMBER_LENGHT 2
#define AREA_MAX_INFO_LENGHT 16
#define AREA_MAX_CODE_LENGHT 5
#define AREA_MAX_NAME_LENGHT 50
#define AREA_WITH_NAME 1
#define AREA_WITH_TYPE 2

typedef struct AreaNumber {
	unsigned short int prefix;
	unsigned short int suffix;
} AreaNumber;

typedef struct AreaOffset {
	unsigned int offset;
	unsigned int size;
} AreaOffset;

typedef struct AreaNode {
	unsigned short int name_offset;
	unsigned short int type_offset;
} AreaNode;

typedef struct AreaPrefixIndex {
	unsigned short int prefix;
} AreaPrefixIndex;

typedef struct AreaSuffixIndex {
	unsigned short int suffix_start;
	unsigned short int suffix_end;
	unsigned int node_index;
} AreaSuffixIndex;

typedef struct AreaInfo {
	unsigned short int id;
	unsigned short int version;
	char separate[AREA_MAX_SEPARATE_LENGHT];
	char name[AREA_MAX_INFO_LENGHT];
	char date[AREA_MAX_INFO_LENGHT];
	char international_access_code[AREA_MAX_CODE_LENGHT];
	char international_code[AREA_MAX_CODE_LENGHT];
	char country_code[AREA_MAX_CODE_LENGHT];
	char long_distance_code[AREA_MAX_CODE_LENGHT];
	unsigned short int min_lenght;
	unsigned short int max_lenght;
	unsigned int fill_total;
	AreaOffset prefix_index;
	AreaOffset suffix_index;
	AreaOffset name_data;
	AreaOffset node_data;
} AreaInfo;

typedef struct Area {
	FILE *file;
	AreaInfo *info;
	AreaPrefixIndex *index;
	AreaOffset *name;
	char *cache;
	char *buffer;
	unsigned int buf_len;
	unsigned short int sep_len;
	unsigned short int iac_len;
	unsigned short int ic_len;
	unsigned short int cc_len;
	unsigned short int ldc_len;
} Area;

Area *Area_load(const char *filename, unsigned int cache_size);
void Area_unload(Area *area);
int Area_cmp(const void *left, const void *right);
AreaNumber Area_atoi(const char *number_string, size_t number_len);
char *Area_get(Area *area, const char *number_string, int withs);

#ifdef __cplusplus
}
#endif

#endif
