
#include "area.h"

#ifdef __cplusplus
extern "C" {
#endif

int Area_cmp(const void *left, const void *right){
	return ((AreaPrefixIndex *)left)->prefix - ((AreaPrefixIndex *)right)->prefix;
}

Area *Area_load(const char *filename, unsigned int cache_size){

	Area *area;

	FILE *fp = fopen(filename, "rb");
	if(!fp)
		return NULL;

	area = (Area *)calloc(sizeof(Area), 1);
	if(!area){
		fclose(fp);
		return NULL;
	}
	area->file = fp;

	area->info = (AreaInfo *)calloc(sizeof(AreaInfo), 1);
	if(!area->info){
		Area_unload(area);
		return NULL;
	}
	fread(area->info, sizeof(AreaInfo), 1, area->file);
	if(area->info->version != AREA_VERSION
		|| area->info->id != AREA_ID
		|| !area->info->prefix_index.offset
		|| !area->info->prefix_index.size
		|| !area->info->suffix_index.offset
		|| !area->info->suffix_index.size
		|| !area->info->node_data.offset
		|| !area->info->node_data.size
		|| !area->info->name_data.offset
		|| !area->info->name_data.size
		|| area->info->max_lenght <= 0
		|| area->info->min_lenght <= 0){
		Area_unload(area);
		return NULL;
	}

	area->index = (AreaPrefixIndex *)malloc(area->info->prefix_index.size);
	if(!area->index){
		Area_unload(area);
		return NULL;
	}
	fseek(area->file, area->info->prefix_index.offset, SEEK_SET);
	fread(area->index, area->info->prefix_index.size, 1, area->file);

	if(cache_size >= area->info->name_data.size){
		area->cache = (char *)malloc(area->info->name_data.size);
		if(!area->cache){
			Area_unload(area);
			return NULL;
		}
		fseek(area->file, area->info->name_data.offset, SEEK_SET);
		fread(area->cache, area->info->name_data.size, 1, area->file);
	}

	area->buffer = (char *)malloc(AREA_MAX_NAME_LENGHT * 2);
	if(!area->buffer){
		Area_unload(area);
		return NULL;
	}

	area->sep_len = strlen(area->info->separate);
	area->iac_len = strlen(area->info->international_access_code);
	area->ic_len = strlen(area->info->international_code);
	area->cc_len = strlen(area->info->country_code);
	area->ldc_len = strlen(area->info->long_distance_code);

	return area;
}

void Area_unload(Area *area){
	if(!area)
		return;
	if(area->file)
		fclose(area->file);
	free(area->info);
	free(area->index);
	free(area->name);
	free(area->cache);
	free(area->buffer);
	free(area);
}

AreaNumber Area_atoi(const char *number_string, size_t number_len){

	AreaNumber number;
	char prefix_string[AREA_INDEX_LENGHT+2];
	char suffix_string[AREA_MAX_NUMBER_LENGHT+2];

	if(number_len > AREA_MAX_NUMBER_LENGHT)
		number_len = AREA_MAX_NUMBER_LENGHT;

	strncpy(prefix_string+1, number_string, AREA_INDEX_LENGHT);
	prefix_string[AREA_INDEX_LENGHT+1] = '\0';
	*prefix_string = '1';
	if(number_len > AREA_INDEX_LENGHT){
		*suffix_string = '1';
		strncpy(suffix_string+1, number_string+AREA_INDEX_LENGHT, number_len-AREA_INDEX_LENGHT);
		suffix_string[number_len-AREA_INDEX_LENGHT+1] = '\0';
		number.suffix = atoi(suffix_string);
	}else
		number.suffix = 0;
	number.prefix = atoi(prefix_string);

	return number;
}

char *Area_get(Area *area, const char *number_string, int withs){

	unsigned int has_ldc;
	size_t number_len;
	unsigned int find_prefix;
	unsigned int find_suffix;
	int prefix_len;
	int suffix_len;
	AreaNumber number;

	if(!area || !number_string || !(*number_string))
		return NULL;

	has_ldc = 0;
	if(*number_string == '+')
		number_string++;
	else if(strncmp(number_string, area->info->international_access_code, area->iac_len) == 0)
		number_string += area->iac_len;
	else if(strncmp(number_string, area->info->international_code, area->ic_len) == 0)
		number_string += area->ic_len;
	if(strncmp(number_string, area->info->country_code, area->cc_len) == 0){
		number_string += area->cc_len;
		has_ldc = 1;
	}
	if(strncmp(number_string, area->info->long_distance_code, area->ldc_len) == 0){
		number_string += area->ldc_len;
		has_ldc = 1;
	}

	number_len = strlen(number_string);
	if(number_len < area->info->min_lenght)
		return NULL;
	if(number_len > area->info->max_lenght){
		number_len = area->info->max_lenght;
	}
	if(number_len >= AREA_INDEX_LENGHT){
		prefix_len = AREA_INDEX_LENGHT;
		suffix_len = number_len - AREA_INDEX_LENGHT;
	}else{
		prefix_len = number_len = AREA_INDEX_LENGHT;
		suffix_len = 0;
	}

	number = Area_atoi(number_string, number_len);

	find_prefix = number.prefix;
	for(;;){

		AreaPrefixIndex *p = (AreaPrefixIndex *)bsearch(&find_prefix,
			area->index, area->info->prefix_index.size / sizeof(AreaPrefixIndex),
			sizeof(AreaPrefixIndex), Area_cmp);

		if(p){

			AreaSuffixIndex find = {0, 0, 0};
			fseek(area->file, area->info->suffix_index.offset + (p - area->index) * sizeof(AreaSuffixIndex), SEEK_SET);
			fread(&find, sizeof(AreaSuffixIndex), 1, area->file);
			find_suffix = (prefix_len < AREA_INDEX_LENGHT) ? 0 : number.suffix;

			for(;;){

				if(find_suffix >= find.suffix_start && find_suffix <= find.suffix_end &&
					(!(find.node_index << sizeof(find.node_index) * 8 - 1) || (find.node_index & has_ldc))){

					unsigned int c, name_lenght = 0;
					AreaNode node = {0, 0};

					fseek(area->file, area->info->node_data.offset +
						((find.node_index >> 1) + find_suffix - find.suffix_start) * sizeof(AreaNode), SEEK_SET);
					fread(&node, sizeof(AreaNode), 1, area->file);

					if(node.name_offset && (withs & AREA_WITH_NAME)){
						if(area->cache){
							name_lenght = strlen(area->cache + node.name_offset);
							memcpy(area->buffer, area->cache + node.name_offset, name_lenght);
						}else{
							fseek(area->file, area->info->name_data.offset + node.name_offset, SEEK_SET);
							while((c = fgetc(area->file)) && c != EOF && name_lenght < AREA_MAX_NAME_LENGHT * 2)
								area->buffer[name_lenght++] = c;
						}
					}

					if(node.type_offset && (withs & AREA_WITH_TYPE)){
						if(name_lenght){
							memcpy(area->buffer + name_lenght, area->info->separate, area->sep_len);
							name_lenght += area->sep_len;
						}
						if(area->cache){
							unsigned int len = strlen(area->cache + node.type_offset);
							memcpy(area->buffer + name_lenght, area->cache + node.type_offset, len);
							name_lenght += len;
						}else{
							fseek(area->file, area->info->name_data.offset + node.type_offset, SEEK_SET);
							while((c = fgetc(area->file)) && c != EOF && name_lenght < AREA_MAX_NAME_LENGHT * 2)
								area->buffer[name_lenght++] = c;
						}
					}

					if(name_lenght){
						area->buffer[name_lenght] = '\0';
						return area->buffer;
					}
				}

				if(--suffix_len < 0)
					break;

				if((find_suffix /= 10) == 1)
					find_suffix = 0;
			}
		}

		if(--prefix_len < area->info->min_lenght)
			break;

		find_prefix /= 10;
	}

	return NULL;
}

#ifdef __cplusplus
}
#endif
