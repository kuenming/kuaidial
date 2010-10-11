/**
 * Name: KDHash
 * Author: linspike
 */

#include <string.h>
#include <stdlib.h>

#define HASH_MAX 5000

struct KDHashNode {
	char *key;
	char *data;
	struct KDHashNode *next;
};

static inline int utf8len(char c){
	if((c & 0x80) == 0){ //0xxxxxxx
		return 1;
	}else if((c & 0x40) == 0){ //10xxxxxx
		return 1;
	}else if((c & 0x20) == 0){ //110xxxxx
		return 2;
	}else if((c & 0x10) == 0){ //1110xxxx
		return 3;
	}else if((c & 0x08) == 0){ //11110xxx
		return 4;
	}else if((c & 0x04) == 0){ //111110xx
		return 5;
	}else if((c & 0x02) == 0){ //1111110x
		return 6;
	}else if((c & 0x01) == 0){ //11111110
		return 7;
	}
	return 1;
};

static inline int utf8strlen(char *c){
	int len = 0;
	for(; *c; len++)
	    c += utf8len(*c);
	return len;
};

static inline char *copyMem(char *buf, int buf_len){
	char *new_buf = (char*) malloc (buf_len+1);
	if(!new_buf)
		return NULL;
	memcpy(new_buf, buf, buf_len);
	new_buf[buf_len] = '\0';
	return new_buf;
};

static inline int KDHash_key(char *key, int key_len){
	register int hash = 5381;
	//for (; key_len >= 8; key_len -= 8) {
	//    hash = ((hash << 5) + hash) + *key++;
	//    hash = ((hash << 5) + hash) + *key++;
	//    hash = ((hash << 5) + hash) + *key++;
	//    hash = ((hash << 5) + hash) + *key++;
	//    hash = ((hash << 5) + hash) + *key++;
	//    hash = ((hash << 5) + hash) + *key++;
	//    hash = ((hash << 5) + hash) + *key++;
	//    hash = ((hash << 5) + hash) + *key++;
	//}
	switch (key_len) {
		case 8: hash = ((hash << 5) + hash) + *key++;
		case 7: hash = ((hash << 5) + hash) + *key++;
		case 6: hash = ((hash << 5) + hash) + *key++;
		case 5: hash = ((hash << 5) + hash) + *key++;
		case 4: hash = ((hash << 5) + hash) + *key++;
		case 3: hash = ((hash << 5) + hash) + *key++;
		case 2: hash = ((hash << 5) + hash) + *key++;
		case 1: hash = ((hash << 5) + hash) + *key;
	}
	return hash;
};

static inline void *KDHash_make(){
	return (void *) calloc(sizeof(struct KDHashNode *), HASH_MAX);
};

static inline void KDHash_free(void *hash_table){
	for(int i = 0; i < HASH_MAX; i++){
		struct KDHashNode **first_node = (struct KDHashNode **) hash_table + i;
		struct KDHashNode *cur_node = *first_node;
		while(cur_node){
			struct KDHashNode *next_node = cur_node -> next;
			free(cur_node -> key);
			free(cur_node -> data);
			free(cur_node);
			cur_node = next_node;
		}
	}
	free(hash_table);
};

static inline void KDHash_add(void *hash_table, char *key, int key_len, char *data, int data_len){

	struct KDHashNode *new_node = (struct KDHashNode *) malloc (sizeof(struct KDHashNode));
	if(!new_node)
		return;

	struct KDHashNode **first_node = (struct KDHashNode **)hash_table + (KDHash_key(key, key_len) % (HASH_MAX-1));

	new_node -> next = NULL;
	new_node -> key = copyMem(key, key_len);
	new_node -> data = copyMem(data, data_len);

	if(*first_node){
		if((*first_node) -> next)
			new_node -> next = (*first_node) -> next;
		(*first_node) -> next = new_node;
	}else
		*first_node = new_node;
};

static inline void KDHash_set(void *hash_table, char *key, int key_len, char *data, int data_len){

	struct KDHashNode **first_node = (struct KDHashNode **) hash_table + (KDHash_key(key, key_len) % (HASH_MAX-1));
	struct KDHashNode *cur_node = *first_node;

	while(cur_node){
		if(memcmp(cur_node -> key, key, key_len) == 0){
			free(cur_node -> data);
			cur_node -> data = copyMem(data, data_len);
			return;
		}
		cur_node = cur_node -> next;
	}

	struct KDHashNode *new_node = (struct KDHashNode *) malloc (sizeof(struct KDHashNode));
	if(!new_node)
		return;

	new_node -> next = NULL;
	new_node -> key = copyMem(key, key_len);
	new_node -> data = copyMem(data, data_len);

	if(*first_node){
		if((*first_node) -> next)
			new_node -> next = (*first_node) -> next;
		(*first_node) -> next = new_node;
	}else
		*first_node = new_node;
};

static inline char *KDHash_get(void *hash_table, char *key, int key_len){

	struct KDHashNode **first_node = (struct KDHashNode **) hash_table + (KDHash_key(key, key_len) % (HASH_MAX-1));
	struct KDHashNode *cur_node = *first_node;

	while(cur_node){
		if(memcmp(cur_node -> key, key, key_len) == 0)
			return cur_node -> data;
		cur_node = cur_node -> next;
	}

	return NULL;
};

