/**
 * Name: KDHash
 * Author: linspike
 */

#include "KDHash.h"

void *hashTableFromFile(char *filename){

	void *hash_table = KDHash_make();
	if(!hash_table)
		return NULL;

	FILE *fp = fopen(filename, "r");
	if(!fp)
		return hash_table;

	char buf[2049];
	while(fgets(buf, 2048, fp)){
		for(char *key = buf; *key; key++){
			if(*key == '='){
				int buf_len = key - buf;
				*key++ = '\0';
				int key_len = strlen(key);
				if(key_len--)
					key[key_len] = '\0';
				while(*key){
					key_len = utf8len(*key);
					KDHash_add(hash_table, key, key_len, buf, buf_len);
					key += key_len;
				}
				break;
			}
		}
	}

	fclose(fp);

	return hash_table;
}

