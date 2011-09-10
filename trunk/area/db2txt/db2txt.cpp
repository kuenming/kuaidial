// db2txt.cpp : Defines the entry point for the console application.
//

#include "stdafx.h"

#include <string.h>
#include <stdlib.h>

#include "sqlite3.h"

void db2txt(const char *dbfile, const char *textfile){

	unsigned int counting = 0;
	FILE *fp = fopen(textfile,"w");

	printf("Writing...");
	if(!fp){
		printf("error\n");
		return;
	}

	sqlite3 *db;
	if(sqlite3_open(dbfile, &db)==SQLITE_OK) {
		sqlite3_stmt *stmt;
		if(sqlite3_prepare_v2(db,"SELECT DISTINCT npa.npa, npa.location, npa.country FROM npa ORDER BY npa.npa",-1,&stmt,NULL)==SQLITE_OK) {
			while(sqlite3_step(stmt)==SQLITE_ROW) {
				char *number = (char *)sqlite3_column_text(stmt,0);
				char *city1 = (char *)sqlite3_column_text(stmt,1);
				if(city1){
					char *city2 = (char *)sqlite3_column_text(stmt,2);
					if(city2)
						fprintf(fp, "%s=%s|%s\n", number, city1, city2);
					else
						fprintf(fp, "%s=%s\n", number, city1);
					if(counting++ % 1000 == 0)
						printf(".");
				}
			}
		}
		sqlite3_finalize(stmt);
		if(sqlite3_prepare_v2(db,"SELECT npanxx.npa||npanxx.nxx, citycode.city, npa.location FROM npanxx, citycode, npa WHERE npanxx.npa = npa.npa AND npanxx.rate_center = citycode.code ORDER BY npanxx.npa, npanxx.nxx ASC",-1,&stmt,NULL)==SQLITE_OK) {
			while(sqlite3_step(stmt)==SQLITE_ROW) {
				char *number = (char *)sqlite3_column_text(stmt,0);
				char *city1 = (char *)sqlite3_column_text(stmt,1);
				if(number && city1){
					char *city2 = (char *)sqlite3_column_text(stmt,2);
					char *c = city1;
					while(*c){
						if(*c++ == ' '){
							if(*c >= 'a' && *c <= 'z')
								*c += 'A' - 'a';
						}else if(*c >= 'A' && *c <= 'Z')
							*c -= 'A' - 'a';
					}
					if(city2)
						fprintf(fp, "%s=%s|%s\n", number, city1, city2);
					else
						fprintf(fp, "%s=%s\n", number, city1);
					if(counting++ % 5000 == 0)
						printf(".");
				}
			}
		}
		sqlite3_finalize(stmt);
		sqlite3_close(db);
	}

	fclose(fp);
	printf(".done\n\nFile Info: %s\n Total: %d\n", textfile, counting);
}

int main(int argc, char* argv[]){

    if(argc == 3)
		db2txt(argv[1], argv[2]);
	else
		printf("usage: db2txt <infile> <outfile>\n");

	return 0;
}
