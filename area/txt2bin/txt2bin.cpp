// txt2bin.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include <string>
#include <iostream>
#include <map>
#include <vector>
#include <algorithm>

#include "../area.h"

using namespace std;

static unsigned int counting = 0;

typedef struct AreaLine {
	AreaNumber number;
	AreaNode node;
	size_t start;
} AreaLine;
   
typedef struct AreaNodeSave {
	vector<AreaPrefixIndex> prefix_vector;
	vector<AreaSuffixIndex> suffix_vector;
	vector<AreaNode> node_vector;
	map<unsigned int, unsigned int> index_map;
} AreaNodeSave;

typedef struct AreaNameSave {
	vector<string> name_vector;
	map<string, unsigned int> name_map;
	unsigned int name_size;
} AreaNameSave;

bool nodeCmp(AreaLine left, AreaLine right){
	if(counting++ % 10000000 == 0)
		cout << '.';
	return (left.number.prefix == right.number.prefix) ? (left.number.suffix < right.number.suffix) : (left.number.prefix < right.number.prefix);
}

unsigned int getNameindex(AreaNameSave *name_save, char *name){
	if(!name)
		return 0;
	string name_key = name;
	map<string, unsigned int>::iterator name_it = name_save->name_map.find(name_key);
	if(name_it != name_save->name_map.end())
		return name_it->second;
	else{
		unsigned int pre_offset = name_save->name_size;
		name_save->name_map[name_key] = pre_offset;
		name_save->name_vector.push_back(name_key);
		name_save->name_size += name_key.size() + 1;
		return pre_offset > 0xffff ? 0 : pre_offset;
	}
}

const char *getConf(map<string, string>*conf_map, const char *name){
	map<string, string>::iterator conf_it = conf_map->find(name);
	return conf_it != conf_map->end() ? conf_it->second.c_str() : NULL;
}

void txt2bin(const char *textfile, const char *binfile){

	cout << "Loading...";
	FILE *fp = fopen(textfile,"r");
	if(!fp){
		cout << "error" << endl;
		return;
	}

	AreaInfo fileinfo;
	memset(&fileinfo, NULL, sizeof(AreaInfo));

	fileinfo.id = AREA_ID;
	fileinfo.version = AREA_VERSION;
	fileinfo.min_lenght = 9;
	fileinfo.max_lenght = 0;
	fileinfo.fill_total = 0;

	map<string, string> conf_map;
	AreaNameSave name_save;
	AreaNodeSave node_save;
	vector<AreaLine> file_vector;

	name_save.name_size = 0;
	getNameindex(&name_save,  "");

	unsigned int errorcount = 0;
	char buf[1025];
	while(fgets(buf, 1024, fp)){
		char *name = strchr(buf, '=');
		if(!name)
			continue;
		*name++ = '\0';

		size_t name_len = strlen(name);
		if(name_len-- && name[name_len] == '\n')
			name[name_len] = '\0';

		if(*buf == '#'){
			conf_map[buf + 1] = name;
			continue;
		}

		AreaLine line;
		char *number = buf;
		if(*number == '%')
			number += line.start = 1;
		else
			line.start = 0;
		size_t number_len = name - number - 1;
		if(number_len < AREA_MIN_NUMBER_LENGHT || number_len > AREA_MAX_NUMBER_LENGHT){
			if(errorcount++ % 1000 == 0)
				cout << '*';
			continue;
		}

		char *type = strchr(name, '|');
		if(type)
			*type++ = '\0';

		if(fileinfo.min_lenght > number_len)
			fileinfo.min_lenght = number_len;
		if(fileinfo.max_lenght < number_len)
			fileinfo.max_lenght = number_len;

		line.number = Area_atoi(number, number_len);
		line.node.name_offset = getNameindex(&name_save, name);
		line.node.type_offset = getNameindex(&name_save, type);
		file_vector.push_back(line);

		if(counting++ % 10000 == 0)
			cout << '.';
	}
	fclose(fp);
	cout << ".done" << endl;

	counting = 0;
	cout << "Sorting...";
	sort(file_vector.begin(), file_vector.end(), nodeCmp);
	cout << ".done" << endl;

	counting = 0;
	cout << "Building...";
	unsigned int last_number = 0;
	AreaNode nullnode = {0, 0};
	for(vector<AreaLine>::iterator it = file_vector.begin(); it != file_vector.end(); ++it){
		map<unsigned int, unsigned int>::iterator number_it = node_save.index_map.find(it->number.prefix);
		if(number_it != node_save.index_map.end()){
			if(last_number >= it->number.suffix){
				if(errorcount++ % 1000 == 0)
					cout << '-';
				continue;
			}

			unsigned int number_index = number_it->second;
			AreaSuffixIndex suffix_index = node_save.suffix_vector[number_index];
			if(suffix_index.suffix_end < it->number.suffix)
				suffix_index.suffix_end = it->number.suffix;
			node_save.suffix_vector[number_index] = suffix_index;
			while(++last_number < it->number.suffix){
				node_save.node_vector.push_back(nullnode);
				fileinfo.fill_total++;
				if(fileinfo.fill_total % 10000 == 0)
					cout << '+';
			}
		}else{
			AreaPrefixIndex prefix_index;
			AreaSuffixIndex suffix_index;
			prefix_index.prefix = it->number.prefix;
			suffix_index.suffix_start = it->number.suffix;
			suffix_index.suffix_end = it->number.suffix;
			suffix_index.node_index = it->start ? 0x00000001 : 0;
			suffix_index.node_index |= node_save.node_vector.size() << 1;
			node_save.prefix_vector.push_back(prefix_index);
			node_save.suffix_vector.push_back(suffix_index);
			node_save.index_map[it->number.prefix] = node_save.prefix_vector.size() - 1;
			last_number = it->number.suffix;
		}
		node_save.node_vector.push_back(it->node);

		if(counting++ % 10000 == 0)
			cout << '.';
	}

	fp = fopen(binfile,"wb");
	if(!fp){
		cout << "error" << endl;
		return;
	}

	const char *val;
	if(val = getConf(&conf_map, "NAME"))
		strncpy(fileinfo.name, val, AREA_MAX_INFO_LENGHT);
	if(val = getConf(&conf_map, "DATE"))
		strncpy(fileinfo.date, val, AREA_MAX_INFO_LENGHT);
	if(val = getConf(&conf_map, "COUNTRY_CODE"))
		strncpy(fileinfo.country_code, val, AREA_MAX_CODE_LENGHT);
	if(val = getConf(&conf_map, "LONG_DISTANCE_CODE"))
		strncpy(fileinfo.long_distance_code, val, AREA_MAX_CODE_LENGHT);
	if(val = getConf(&conf_map, "INTERNATIONAL_ACCESS_CODE"))
		strncpy(fileinfo.international_access_code, val, AREA_MAX_CODE_LENGHT);
	if(val = getConf(&conf_map, "INTERNATIONAL_CODE"))
		strncpy(fileinfo.international_code, val, AREA_MAX_CODE_LENGHT);
	if(val = getConf(&conf_map, "SEPARATE"))
		strncpy(fileinfo.separate, val, AREA_MAX_SEPARATE_LENGHT);
	else
		*fileinfo.separate = ' ';

	fileinfo.prefix_index.offset = sizeof(AreaInfo);
	fileinfo.prefix_index.size = node_save.prefix_vector.size() * sizeof(AreaPrefixIndex);
	fileinfo.suffix_index.offset = fileinfo.prefix_index.offset + fileinfo.prefix_index.size;
	fileinfo.suffix_index.size = node_save.suffix_vector.size() * sizeof(AreaSuffixIndex);
	fileinfo.node_data.offset = fileinfo.suffix_index.offset + fileinfo.suffix_index.size;
	fileinfo.node_data.size = node_save.node_vector.size() * sizeof(AreaNode);
	fileinfo.name_data.offset = fileinfo.node_data.offset + fileinfo.node_data.size;
	fileinfo.name_data.size = name_save.name_size;

	fwrite(&fileinfo, sizeof(AreaInfo), 1, fp);

	for(vector<AreaPrefixIndex>::iterator pnumber_it = node_save.prefix_vector.begin(); pnumber_it != node_save.prefix_vector.end(); ++pnumber_it)
		fwrite(pnumber_it, sizeof(AreaPrefixIndex), 1, fp);
	for(vector<AreaSuffixIndex>::iterator snumber_it = node_save.suffix_vector.begin(); snumber_it != node_save.suffix_vector.end(); ++snumber_it)
		fwrite(snumber_it, sizeof(AreaSuffixIndex), 1, fp);
	for(vector<AreaNode>::iterator node_it = node_save.node_vector.begin(); node_it != node_save.node_vector.end(); ++node_it)
		fwrite(node_it, sizeof(AreaNode), 1, fp);
	for(vector<string>::iterator name_it = name_save.name_vector.begin(); name_it != name_save.name_vector.end(); ++name_it)
		fwrite(name_it->c_str(), name_it->size()+1, 1, fp);

    size_t filesize = ftell(fp);
	fclose(fp);
	cout << ".done" << endl;

	cout << "\nFile Info: " << binfile <<
	"\n Build date: " << fileinfo.date <<
	"\n Country name: " << fileinfo.name <<
	"\n Country code: " << fileinfo.country_code <<
	"\n International access code: " << fileinfo.international_access_code <<
	"\n International code: " << fileinfo.international_code <<
	"\n Long distance code: " << fileinfo.long_distance_code <<
	"\n Min lenght: " << fileinfo.min_lenght <<
	"\n Max lenght: " << fileinfo.max_lenght <<
	"\n Index offset: " << fileinfo.prefix_index.offset <<
	"\n Index size: " << fileinfo.prefix_index.size + fileinfo.suffix_index.size <<
	"\n Index total: " << fileinfo.prefix_index.size / sizeof(AreaPrefixIndex) <<
	"\n Node offset: " << fileinfo.node_data.offset <<
	"\n Node size: " << fileinfo.node_data.size <<
	"\n Node total: " << fileinfo.node_data.size / sizeof(AreaNode) - fileinfo.fill_total <<
	"\n Name offset: " << fileinfo.name_data.offset <<
	"\n Name size: " << fileinfo.name_data.size <<
	"\n Name total: " << name_save.name_vector.size() <<
	"\n File size: " << filesize * 100 / 1024 / 100.0 << " KB" <<
	"\n Cache size: " << fileinfo.prefix_index.size * 100 / 1024 / 100.0 << " KB" <<
	"\n [+] Fill nodes: " << fileinfo.fill_total <<
	"\n [-] Error nodes: " << errorcount << endl;
}

int main(int argc, char* argv[]){

    if(argc == 3)
		txt2bin(argv[1], argv[2]);
	else
		cout << "usage: txt2bin <infile> <outfile>" << endl;

	return 0;
}
