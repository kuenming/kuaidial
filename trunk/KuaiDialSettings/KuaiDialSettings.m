/**
 * Name: KuaiDial Settings
 * Author: linspike
 * Last-modified: 2010-08-16
 */

#import <sqlite3.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIKeyboard.h>
#import <UIKit/UITableViewController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSViewController.h>
#import <AddressBook/AddressBook.h>

#import "KDCommon.h"

static id _SettingsController;
static id _ListController;
static NSMutableDictionary *_settings;
static NSMutableString *_plistfile;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// KuaiDialSettingsController
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface KuaiDialSettingsController: PSListController {}
- (id) initForContentSize:(CGSize)size;
- (void) dealloc;
- (id) specifiers;
- (void) setPreferenceValue:(id)value specifier:(PSSpecifier *)spec;
- (id) readPreferenceValue:(PSSpecifier *)spec;
- (NSArray *) localizedSpecifiersForSpecifiers:(NSArray *)s;
@end

@implementation KuaiDialSettingsController

- (id) initForContentSize:(CGSize)size {
    if ((self = [super initForContentSize:size]) != nil) {
        _plistfile = [[NSString alloc] initWithString:@"/private/var/mobile/Library/Preferences/kuaidial.plist"];
        _settings = [([NSMutableDictionary dictionaryWithContentsOfFile:_plistfile] ?: [NSMutableDictionary dictionary]) retain];
    }
	_SettingsController = self;

	return self;
}

- (void) dealloc {
	[_plistfile release];
    [_settings release];
    [super dealloc];
}

- (id) specifiers {
    if (!_specifiers)
		_specifiers = [[self loadSpecifiersFromPlistName:@"KuaiDial" target:self] retain];
		_specifiers = [self localizedSpecifiersForSpecifiers:_specifiers];
    return _specifiers;
}

- (void) setPreferenceValue:(id)value specifier:(PSSpecifier *)spec {
   if ([[spec propertyForKey:@"negate"] boolValue])
        value = [NSNumber numberWithBool:(![value boolValue])];
    [_settings setValue:value forKey:[spec propertyForKey:@"key"]];

	[super setPreferenceValue:value specifier:spec];
}

- (id) readPreferenceValue:(PSSpecifier *)spec {
    NSString *key = [spec propertyForKey:@"key"];
    id defaultValue = [spec propertyForKey:@"default"];
    id plistValue = [_settings objectForKey:key];
    if (!plistValue)
        return defaultValue;
    if ([[spec propertyForKey:@"negate"] boolValue])
        plistValue = [NSNumber numberWithBool:(![plistValue boolValue])];

    return plistValue;
}

- (NSArray *)localizedSpecifiersForSpecifiers:(NSArray *)s
{
   for(PSSpecifier *specifier in s)
   {
      if([specifier name])
         [specifier setName:[[self bundle] localizedStringForKey:[specifier name] value:[specifier name] table:nil]];

      if([specifier titleDictionary])
      {
         NSMutableDictionary *newTitles = [[NSMutableDictionary alloc] init];
         for(NSString *key in [specifier titleDictionary])
            [newTitles setObject: [[self bundle] localizedStringForKey:[[specifier titleDictionary] objectForKey:key] value:[[specifier titleDictionary] objectForKey:key] table:nil] forKey: key];

         [specifier setTitleDictionary: [newTitles autorelease]];
      }
   }

   return s;
}

- (void)emailApp:(id)ps{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:linspike@gmail.com?subject=KuaiDial"]];
}

- (NSArray *)areaTitleApp:(id)ps{
	NSMutableArray *areas = [NSMutableArray arrayWithObject:[[self bundle] localizedStringForKey:@"None" value:@"None" table:nil]];
	[areas addObjectsFromArray:[[NSFileManager defaultManager] directoryContentsAtPath:@"/Library/KuaiDial/Area"]];
	return areas;
}

- (NSArray *)areaDataApp:(id)ps{
	NSMutableArray *areas = [NSMutableArray arrayWithObject:@""];
	[areas addObjectsFromArray:[[NSFileManager defaultManager] directoryContentsAtPath:@"/Library/KuaiDial/Area"]];
	return areas;
}

- (NSArray *)t9TitleApp:(id)ps{
	NSMutableArray *list = [NSMutableArray arrayWithObject:[[self bundle] localizedStringForKey:@"None" value:@"None" table:nil]];
	[list addObjectsFromArray:[[NSFileManager defaultManager] directoryContentsAtPath:@"/Library/KuaiDial/Table"]];
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:@"/Library/KuaiDial/T9"];
	NSString *file;
	while (file = [dirEnum nextObject]){
		if ([[file pathExtension] isEqualToString:@"plist"])
			[list addObject:[file substringToIndex:[file length]-6]];
	}
	return list;
}

- (NSArray *)t9DataApp:(id)ps{
	NSMutableArray *list = [NSMutableArray arrayWithObject:@""];
	[list addObjectsFromArray:[[NSFileManager defaultManager] directoryContentsAtPath:@"/Library/KuaiDial/Table"]];
	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:@"/Library/KuaiDial/T9"];
	NSString *file;
	while (file = [dirEnum nextObject]){
		if ([[file pathExtension] isEqualToString:@"plist"])
			[list addObject:file];
	}
	return list;
}

-(void)savePref:(NSObject *)sth forKey:(NSString *)key{
	NSMutableDictionary *settings = [NSMutableDictionary dictionaryWithContentsOfFile:_plistfile];
	if(settings){
	    [settings setValue:sth forKey:key];
		NSData *data = [NSPropertyListSerialization dataFromPropertyList:settings format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
		if(data)
			[data writeToFile:_plistfile options:NSAtomicWrite error:NULL];
	}
}

-(NSObject *)zeroValue:(PSSpecifier*)spec{
	return @"0";
}

-(NSObject *)resetSettsings:(PSSpecifier*)spec{
	system("rm -f /private/var/mobile/Library/Preferences/kuaidial.plist");
	[self setLimit:@"100" forSpecifier:spec];
	[_settings release];
	_settings = [[NSMutableDictionary dictionary] retain];
}

-(NSObject *)resetData:(PSSpecifier*)spec{
	system("rm -f /private/var/mobile/Library/Preferences/kuaidial.*.plist");
}

-(NSObject *)blackListCount:(PSSpecifier*)spec{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Preferences/kuaidial.black.plist"];
	return [NSString stringWithFormat:@"%d", dict ? [dict count] : 0];
}

-(NSObject *)whiteListCount:(PSSpecifier*)spec{
	NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Preferences/kuaidial.white.plist"];
	return [NSString stringWithFormat:@"%d", dict ? [dict count] : 0];
}

-(NSObject *)getLimit:(PSSpecifier*)spec{
	int limit = 100;
	sqlite3 *db;
	if(sqlite3_open([KDCommon callHistoryFile],&db)==SQLITE_OK) {
	   char *buf;
	   sqlite3_stmt *stmt;
	   if(sqlite3_prepare_v2(db,"SELECT value FROM _SqliteDatabaseProperties WHERE key='call_history_limit'",-1,&stmt,NULL)==SQLITE_OK) {
		   if(sqlite3_step(stmt)==SQLITE_ROW) {
			   buf=(char *)sqlite3_column_text(stmt,0);
			   if(buf)
					limit = [[NSString stringWithUTF8String:buf] intValue];
		   }
	   }
	   sqlite3_finalize(stmt);
	   sqlite3_close(db);
	}

	NSNumber *sth = [NSNumber numberWithInt:limit];

	[self savePref:sth forKey:@"CallHistoryLimit"];

	return sth;
}

-(void)setLimit:(NSObject*)sth forSpecifier:(PSSpecifier*)spec{
	if([KDCommon OSVersion] >= 40){
		if([sth intValue] == 100){
			system("/Library/KuaiDial/recent -u");
		}else{
			system([[NSString stringWithFormat:@"/Library/KuaiDial/recent -i %@", sth] UTF8String]);
		}
	}else{
		sqlite3 *db;
		if(sqlite3_open([KDCommon callHistoryFile],&db)==SQLITE_OK) {
			sqlite3_stmt *stmt;
			if(sqlite3_prepare_v2(db,[[NSString stringWithFormat:@"UPDATE _SqliteDatabaseProperties SET value=%@ WHERE key='call_history_limit'", sth] UTF8String],-1,&stmt,NULL)==SQLITE_OK) {
				if(sqlite3_step(stmt)==SQLITE_ROW) {
				}
			}
			sqlite3_finalize(stmt);
			if([sth intValue] == 100){
				if(sqlite3_prepare_v2(db,"DROP TABLE deleted",-1,&stmt,NULL)==SQLITE_OK) {
					if(sqlite3_step(stmt)==SQLITE_ROW) {
					}
				}
				sqlite3_finalize(stmt);
				if(sqlite3_prepare_v2(db,"DROP TRIGGER save_deleted",-1,&stmt,NULL)==SQLITE_OK) {
					if(sqlite3_step(stmt)==SQLITE_ROW) {
					}
				}
				sqlite3_finalize(stmt);

			}else{
				if(sqlite3_prepare_v2(db,"CREATE TABLE deleted (ROWID INTEGER PRIMARY KEY AUTOINCREMENT, address TEXT, date INTEGER, duration INTEGER, flags INTEGER, id INTEGER)",-1,&stmt,NULL)==SQLITE_OK) {
					if(sqlite3_step(stmt)==SQLITE_ROW) {
					}
				}
				sqlite3_finalize(stmt);
				if(sqlite3_prepare_v2(db,"CREATE TRIGGER save_deleted BEFORE DELETE ON call FOR EACH ROW BEGIN INSERT INTO deleted SELECT * FROM call WHERE call.ROWID=OLD.ROWID; END",-1,&stmt,NULL)==SQLITE_OK) {
					if(sqlite3_step(stmt)==SQLITE_ROW) {
					}
				}
				sqlite3_finalize(stmt);

			}
			sqlite3_close(db);
		}
	}

	[self savePref:sth forKey:@"CallHistoryLimit"];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// KDSettingsController
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface KDSettingsController:PSListController {}
- (id) specifiers;
- (NSArray *) localizedSpecifiersForSpecifiers:(NSArray *)s;
- (id) navigationTitle;
@end

@implementation KDSettingsController

-(void)setSpecifier:(PSSpecifier *)spec{
	if ([self respondsToSelector:@selector(navigationItem)])
		[[self navigationItem] setTitle:[[self bundle] localizedStringForKey:[spec name] value:[spec name] table:nil]];

	[super setSpecifier:spec];
}

- (void) setPreferenceValue:(id)value specifier:(PSSpecifier *)spec {
   if ([[spec propertyForKey:@"negate"] boolValue])
        value = [NSNumber numberWithBool:(![value boolValue])];
    [_settings setValue:value forKey:[spec propertyForKey:@"key"]];

	[super setPreferenceValue:value specifier:spec];
}

- (id) readPreferenceValue:(PSSpecifier *)spec {
    NSString *key = [spec propertyForKey:@"key"];

    id defaultValue = [spec propertyForKey:@"default"];
    id plistValue = [_settings objectForKey:key];
    if (!plistValue)
        return defaultValue;
    if ([[spec propertyForKey:@"negate"] boolValue])
        plistValue = [NSNumber numberWithBool:(![plistValue boolValue])];

    return plistValue;
}

- (id) specifiers {
    return [self localizedSpecifiersForSpecifiers:[super specifiers]];
}

- (NSArray *)localizedSpecifiersForSpecifiers:(NSArray *)s
{
   for(PSSpecifier *specifier in s)
   {
      if([specifier name])
         [specifier setName:[[self bundle] localizedStringForKey:[specifier name] value:[specifier name] table:nil]];

	  if([specifier propertyForKey:@"valueLocalized"])
	      continue;

      if([specifier titleDictionary])
      {
         NSMutableDictionary *newTitles = [[NSMutableDictionary alloc] init];
         for(NSString *key in [specifier titleDictionary])
            [newTitles setObject: [[self bundle] localizedStringForKey:[[specifier titleDictionary] objectForKey:key] value:[[specifier titleDictionary] objectForKey:key] table:nil] forKey: key];

         [specifier setTitleDictionary: [newTitles autorelease]];
      }
   }

   return s;
}

- (id) navigationTitle {
	return [[self bundle] localizedStringForKey:[super navigationTitle] value:[super navigationTitle] table:nil];
}

@end



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// KDHelpSettingsController
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface KDHelpSettingsController:PSListController {}
- (id) specifiers;
- (NSArray *) localizedSpecifiersForSpecifiers:(NSArray *)s;
- (id) navigationTitle;
@end

@implementation KDHelpSettingsController

-(void)setSpecifier:(PSSpecifier *)spec{
	if ([self respondsToSelector:@selector(navigationItem)])
		[[self navigationItem] setTitle:[[self bundle] localizedStringForKey:[spec name] value:[spec name] table:nil]];

	[super setSpecifier:spec];
}

- (id) specifiers {
    return [self localizedSpecifiersForSpecifiers:[super specifiers]];
}

- (NSArray *)localizedSpecifiersForSpecifiers:(NSArray *)s
{
   for(PSSpecifier *specifier in s)
   {
      if([specifier name])
         [specifier setName:[[self bundle] localizedStringForKey:[specifier name] value:[specifier name] table:nil]];

      if([specifier titleDictionary])
      {
         NSMutableDictionary *newTitles = [[NSMutableDictionary alloc] init];
         for(NSString *key in [specifier titleDictionary])
            [newTitles setObject: [[self bundle] localizedStringForKey:[[specifier titleDictionary] objectForKey:key] value:[[specifier titleDictionary] objectForKey:key] table:nil] forKey: key];

         [specifier setTitleDictionary: [newTitles autorelease]];
      }
   }

   return s;
}

- (id) navigationTitle {
	return [[self bundle] localizedStringForKey:[super navigationTitle] value:[super navigationTitle] table:nil];
}

@end



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// KDHelpViewController
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface KDHelpViewController: PSViewController {
    UITextView *_textView;
	NSMutableString *_title;
}

- (id) view;
- (id) navigationTitle;
- (void) dealloc;

@end

@implementation KDHelpViewController

- (void)viewWillBecomeVisible:(void *)spec{
	if(spec)
		[self loadFromSpecifier:spec];
	[super viewWillBecomeVisible:spec];
}

- (void)setSpecifier:(PSSpecifier *)spec{
	[self loadFromSpecifier:spec];
	[super setSpecifier:spec];
}

- (void)loadFromSpecifier:(PSSpecifier *)spec{
	if(!_title)
		_title = [[NSMutableString alloc] init];
	[_title setString:[spec name]];

	_textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64)];
	[_textView setEditable:NO];
	[_textView setFont:[UIFont systemFontOfSize:14.0]];
	[_textView setContentToHTMLString:[[_SettingsController bundle] localizedStringForKey:[NSString stringWithFormat:@"Help-%@",[spec identifier]] value:@"Not Found" table:nil]];

	if ([self respondsToSelector:@selector(navigationItem)])
		[[self navigationItem] setTitle:[[_SettingsController bundle] localizedStringForKey:_title value:_title table:nil]];
}

- (id) view {
	return _textView;
}

- (id) navigationTitle {
	if(_title)
		return [[_SettingsController bundle] localizedStringForKey:_title value:_title table:nil];

	return [super navigationTitle];
}

- (void) dealloc {
    [_textView release];
	[_title release];
    [super dealloc];
}

@end



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// KDContactViewController
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface KDContactViewController: PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
	NSMutableString *_title;
	NSMutableArray *_list;
	NSString *_saveplist;
	int showType;
}

- (id) view;
- (id) navigationTitle;
- (void) dealloc;

@end

@implementation KDContactViewController

- (id) initWithTitle:(NSString *)title type:(int)type plist:(NSString *)plist{
	self =  [super init];

	if(!_title)
		_title = [[NSMutableString alloc] init];
	[_title setString:title];

	showType = type;
	_saveplist = plist;

	[self loadFromSpecifier:nil];

	return self;
}

- (void)viewDidBecomeVisible {
	@try {
		[self showLeftButton:nil withStyle:0 rightButton:nil withStyle:0];
	}
	@catch (id ue) {}

   [super viewDidBecomeVisible];
}

- (void)loadFromSpecifier:(PSSpecifier *)spec{

	NSMutableDictionary *blocklist = nil;
	if([[NSFileManager defaultManager] fileExistsAtPath:_saveplist])
		blocklist=[NSMutableDictionary dictionaryWithContentsOfFile:_saveplist];

	NSMutableDictionary *contactlist = nil;
	if(!showType)
		contactlist=[NSMutableDictionary dictionary];

	if(!_list)
		_list=[[NSMutableArray alloc] init];

	sqlite3 *db;
	if(sqlite3_open("/private/var/mobile/Library/AddressBook/AddressBook.sqlitedb",&db)==SQLITE_OK) {
		char *buf;
		sqlite3_stmt *stmt;

		bool prefsNameOrder = NO;
		NSString *contactpfile = @"/private/var/mobile/Library/Preferences/com.apple.PeoplePicker.plist";
		if([[NSFileManager defaultManager] fileExistsAtPath:contactpfile]){
			NSDictionary *settings = [NSDictionary dictionaryWithContentsOfFile:contactpfile];
			if(settings){
				id obj = [settings objectForKey:@"personNameOrdering"];
				if(obj)
					prefsNameOrder = ![obj boolValue];
			}
		}

		NSString *sql = [NSString stringWithFormat:
			@"SELECT ABMultiValue.Value,%@,ABMultiValueLabel.value FROM ABPerson,ABMultiValue,ABMultiValueLabel WHERE ABPerson.ROWID=ABMultiValue.record_id AND ABMultiValue.label=ABMultiValueLabel.ROWID AND property=3 ORDER BY ABMultiValue.record_id,ABMultiValue.label DESC", 
			prefsNameOrder?@"COALESCE(ABPerson.[First]||' '||ABPerson.[Last],ABPerson.[First],ABPerson.[Last],' ')":@"COALESCE(ABPerson.[Last]||' '||ABPerson.[First],ABPerson.[Last],ABPerson.[First],' ')"];

		if(sqlite3_prepare_v2(db,[sql UTF8String],-1,&stmt,NULL)==SQLITE_OK) {
			while(sqlite3_step(stmt)==SQLITE_ROW) {
				NSMutableString *phoneNumber = nil;
				buf=(char *)sqlite3_column_text(stmt,0);
				if(buf)
					phoneNumber = [NSString stringWithUTF8String:buf];
				if(phoneNumber == nil)
					continue;
				phoneNumber = [[NSMutableString alloc] initWithString:phoneNumber];
				[KDCommon filterNumber:phoneNumber];

				NSString *nameFull;
				buf=(char *)sqlite3_column_text(stmt,1);
				if(buf)
					nameFull = [NSString stringWithUTF8String:buf];
				else
					nameFull = @"";

				if(!showType){
					if(nameFull)
						[contactlist setObject:nameFull forKey:phoneNumber];
				}else{
					NSString *phoneType = nil;
					buf=(char *)sqlite3_column_text(stmt,2);
					if(buf)
						phoneType = [NSString stringWithUTF8String:buf];

					NSMutableDictionary *propertys = [[NSMutableDictionary alloc] init];
					[propertys setObject:nameFull forKey:@"name"];

					NSMutableString *type = [[NSMutableString alloc] init];
					if(phoneType)
						[type setString:ABAddressBookCopyLocalizedLabel(phoneType)];
					[propertys setObject:type forKey:@"type"];
					[type release];

					bool checked = NO;

					[propertys setObject:phoneNumber forKey:@"number"];
					if(blocklist && [blocklist objectForKey:phoneNumber]){
						checked = YES;
						[blocklist removeObjectForKey:phoneNumber];
					}

					[propertys setObject:[NSNumber numberWithBool:checked] forKey:@"checked"];
					if(checked){
						[_list insertObject:propertys atIndex:0];
					}else{
						[_list addObject:propertys];
					}
					[propertys release];
				}
				[phoneNumber release];
			}
		}
		sqlite3_finalize(stmt);
		sqlite3_close(db);
	}

	if(!showType){
		sqlite3 *db;
		if(sqlite3_open([KDCommon callHistoryFile],&db)==SQLITE_OK) {
			char *buf;
			sqlite3_stmt *stmt;
			if(sqlite3_prepare_v2(db,"SELECT address,date FROM call WHERE address!='' ORDER BY ROWID DESC",-1,&stmt,NULL)==SQLITE_OK) {

				NSMutableDictionary *distinct=[NSMutableDictionary dictionary];
				NSTimeInterval curtimeinterval = [NSDate timeIntervalSinceReferenceDate]+978307200;
				NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
				[dateFormatter setLocale:[NSLocale systemLocale]];
				[dateFormatter setTimeStyle:NSDateFormatterNoStyle];
				[dateFormatter setDateStyle:@"yyyy-MM-dd"];

				NSDateFormatter *timeFormatter = [[[NSDateFormatter alloc] init] autorelease];
				[timeFormatter setLocale:[NSLocale systemLocale]];
				[timeFormatter setDateStyle:NSDateFormatterNoStyle];
				[timeFormatter setTimeStyle:@"hh:mm:ss"];

				NSString *today = [dateFormatter stringFromDate:[NSDate date]]; 

				while(sqlite3_step(stmt)==SQLITE_ROW) {

					NSMutableString *address = [[NSMutableString alloc] init];
					buf=(char *)sqlite3_column_text(stmt,0);
					if(buf){
						[address setString:[NSString stringWithUTF8String:buf]];
						[KDCommon filterNumber:address];
					}

					id obj = [distinct objectForKey:address];
					if(obj){
						[address release];
						continue;
					}else{
						[distinct setObject:[NSNumber numberWithBool:YES] forKey:address];
					}

					NSMutableString *label = [[NSMutableString alloc] init];
					NSMutableDictionary *propertys = [[NSMutableDictionary alloc] init];
					[propertys setObject:address forKey:@"number"];

					obj = [contactlist objectForKey:address];
					if(obj){
						[propertys setObject:obj forKey:@"name"];
					}

					buf=(char *)sqlite3_column_text(stmt,1);
					if(buf){
						@try {
							NSTimeInterval timeinterval = [[NSString stringWithUTF8String:buf] doubleValue];
							NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeinterval];
							NSString *datestring = [dateFormatter stringFromDate:date]; 

							if(curtimeinterval - timeinterval < 86400){
								if([today isEqualToString:datestring])
									datestring = [timeFormatter stringFromDate:date]; 
							}

							if(datestring){
								[label setString:[datestring stringByReplacingOccurrencesOfString:@" " withString:@"-"]];
							}
						} @catch (id ue) {}
					}
					[propertys setObject:label forKey:@"type"];

					if(blocklist && [blocklist objectForKey:address]){
						[propertys setObject:[NSNumber numberWithBool:YES] forKey:@"checked"];
					}else{
						[propertys setObject:[NSNumber numberWithBool:NO] forKey:@"checked"];
					}

					[_list addObject:propertys];
					[propertys release];
					[label release];
					[address release];
				}
			}
			sqlite3_finalize(stmt);
		}
		sqlite3_close(db);

	}else{

		if(blocklist){
		   NSString *key;
		   NSEnumerator *ie = [blocklist keyEnumerator];
		   while(key=[ie nextObject]){
				NSMutableDictionary *propertys = [[NSMutableDictionary alloc] init];
				[propertys setObject:key forKey:@"number"];
				[propertys setObject:[NSString stringWithFormat:@"%@", [[_SettingsController bundle] localizedStringForKey:@"unkown" value:@"unkown" table:nil]] forKey:@"type"];
				[propertys setObject:[NSNumber numberWithBool:YES] forKey:@"checked"];
				[_list insertObject:propertys atIndex:0];
				[propertys release];
		   }
		}
	}

	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStylePlain];
	[_tableView setDataSource:self];
	[_tableView setDelegate:self];

	if ([self respondsToSelector:@selector(navigationItem)])
		[[self navigationItem] setTitle:_title];
}

- (id) view {
	return _tableView;
}

- (id) navigationTitle {
	return _title;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    return nil;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
	if(!_list)
		return 0;

    return [_list count];
}

- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NumberCell"];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100) reuseIdentifier:@"NumberCell"] autorelease];

		UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 3, 190, 22)];
		nameLabel.textAlignment=UITextAlignmentLeft;
		nameLabel.font = [UIFont boldSystemFontOfSize:18];
		nameLabel.textColor = [UIColor blackColor];
		nameLabel.backgroundColor = [UIColor clearColor];
		nameLabel.highlightedTextColor = [UIColor whiteColor];
		nameLabel.adjustsFontSizeToFitWidth=YES;
		nameLabel.minimumFontSize=12;
		nameLabel.tag = 1;
		[cell.contentView addSubview:nameLabel];
		[nameLabel release];
 
		UILabel *numberLabel=[[UILabel alloc] initWithFrame:CGRectMake(10,25,190,15)];
		numberLabel.textAlignment=UITextAlignmentLeft;
		numberLabel.font = [UIFont systemFontOfSize:14];
		numberLabel.textColor = [UIColor grayColor];
		numberLabel.backgroundColor = [UIColor clearColor];
		numberLabel.highlightedTextColor = [UIColor whiteColor];
		numberLabel.adjustsFontSizeToFitWidth=YES;
		numberLabel.minimumFontSize=12;
		numberLabel.tag = 2;
		[cell.contentView addSubview:numberLabel];
		[numberLabel release];
 
		//UILabel *typeLabel=[[UILabel alloc] initWithFrame:CGRectMake(100,0,210,43)];
		UILabel *typeLabel=[[UILabel alloc] initWithFrame:CGRectMake(100,0,185,43)];
		typeLabel.textAlignment=UITextAlignmentRight;
		typeLabel.font = [UIFont boldSystemFontOfSize:16];
		typeLabel.textColor = [UIColor colorWithRed:107/255.0 green:127/255.0 blue:155/255.0 alpha:1];
		typeLabel.backgroundColor = [UIColor clearColor];
		typeLabel.highlightedTextColor = [UIColor whiteColor];
		typeLabel.adjustsFontSizeToFitWidth=YES;
		typeLabel.minimumFontSize=12;
		typeLabel.numberOfLines=2;
		typeLabel.tag = 3;
		[cell.contentView addSubview:typeLabel];
		[typeLabel release];
    }

	UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
	UILabel *numberLabel = (UILabel *)[cell.contentView viewWithTag:2];
	UILabel *typeLabel = (UILabel *)[cell.contentView viewWithTag:3];

	NSMutableDictionary *propertys = [_list objectAtIndex:indexPath.row];
	if(propertys){
		NSString *num = [propertys objectForKey:@"number"];
		NSString *name = [propertys objectForKey:@"name"];
		if(name && [name length] && ![name isEqualToString:@" "]){
			[nameLabel setFrame:CGRectMake(10, 3, 190, 22)];		
			nameLabel.text = name;
			numberLabel.text = num;
		}else{
			[nameLabel setFrame:CGRectMake(10, 3, 190, 40)];			
			nameLabel.text = num;
			numberLabel.text = @"";
		}
		typeLabel.text = [propertys objectForKey:@"type"];

		id obj = [propertys objectForKey:@"checked"];
		if(obj){
			cell.accessoryType = [obj boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
		}
	}

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	NSMutableDictionary *propertys = [_list objectAtIndex:indexPath.row];

	id obj = [propertys objectForKey:@"checked"];
	bool checked = NO;
	if(obj)
		checked = ![obj boolValue];
	if(checked){
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
	}else{
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	[propertys setObject:[NSNumber numberWithBool:checked] forKey:@"checked"];

	[tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:NO];

	NSMutableDictionary *data;
	if([[NSFileManager defaultManager] fileExistsAtPath:_saveplist]){
	   data=[NSMutableDictionary dictionaryWithContentsOfFile:_saveplist];
	}else{
	   data=[NSMutableDictionary dictionary];
	}

	obj = [propertys objectForKey:@"number"];
	if(checked){
		id name = [propertys objectForKey:@"name"];
		if(name && ![name isEqualToString:@" "]){
			[data setValue:name forKey:obj];
		}else{
			[data setValue:@"" forKey:obj];
		}
	}else {
		[data removeObjectForKey:obj];
	}

	[data writeToFile:_saveplist atomically:YES];

	[_ListController reLoad];
}

- (void) dealloc {
    [_tableView release];
	[_list release];
	[_saveplist release];
	[_title release];
    [super dealloc];
}

@end



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// KDListViewController
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface KDListViewController: PSViewController <UITableViewDelegate, UITableViewDataSource> {
    UITableView *_tableView;
	NSMutableString *_title;
	NSMutableArray *_list;
	NSMutableDictionary *_dict;
	int _lastrow;
}

- (id) view;
- (id) navigationTitle;
- (void) dealloc;

@end

@implementation KDListViewController

- (id) initWithTitle:(NSString *)title{
	self =  [super init];

	if(!_title)
		_title = [[NSMutableString alloc] init];
	[_title setString:title];

	[self loadFromSpecifier:nil];

	return self;
}

- (void)viewDidBecomeVisible {
	@try {
		[self showLeftButton:nil withStyle:0 rightButton:nil withStyle:0];
	}
	@catch (id ue) {}

   [super viewDidBecomeVisible];
}

- (void)loadFromSpecifier:(PSSpecifier *)spec{

	if(!_list)
		_list=[[NSMutableArray alloc] init];

	[_list addObject:[[_SettingsController bundle] localizedStringForKey:@"Please select one" value:@"Please select one" table:nil]];

	NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:@"/Library/KuaiDial/T9"];
	NSString *file;
	while (file = [dirEnum nextObject]){
		if ([[file pathExtension] isEqualToString: @"plist"]){
			[_list addObject:[file substringToIndex:[file length]-6]];
		}
	}
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStyleGrouped];
	[_tableView setDataSource:self];
	[_tableView setDelegate:self];

	if ([self respondsToSelector:@selector(navigationItem)])
		[[self navigationItem] setTitle:_title];
}

- (id) view {
	return _tableView;
}

- (id) navigationTitle {
	return _title;
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    return nil;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
	if(!_list)
		return 0;

    return [_list count];
}

- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"T9Cell"];
    if (!cell) 
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100) reuseIdentifier:@"T9Cell"] autorelease];

	cell.text = [_list objectAtIndex:indexPath.row];

	if(_lastrow == indexPath.row){
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.textColor = [UIColor colorWithRed:81/255.0 green:102/255.0 blue:145/255.0 alpha:1];
	}else{
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.textColor = [UIColor blackColor];
	}

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:YES];

	if(_lastrow == indexPath.row)
		return;

	UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:_lastrow inSection:0]];
	cell.accessoryType = UITableViewCellAccessoryNone;
	cell.textColor = [UIColor blackColor];

	_lastrow = indexPath.row;

	cell = [tableView cellForRowAtIndexPath:indexPath];
	cell.accessoryType = UITableViewCellAccessoryCheckmark;
	cell.textColor = [UIColor colorWithRed:81/255.0 green:102/255.0 blue:145/255.0 alpha:1];

	NSString *saveplist = @"/private/var/mobile/Library/Preferences/kuaidial.t9.plist";
	if(!_dict){
		if([[NSFileManager defaultManager] fileExistsAtPath:saveplist])
			_dict = [NSMutableDictionary dictionaryWithContentsOfFile:saveplist];
		if(!_dict)
			_dict = [[NSMutableDictionary alloc] init];
		else
			[_dict retain];
	}

	if(_lastrow == 0){
		[_dict writeToFile:saveplist atomically:YES];		
	}else{
		NSString *plist = [NSString stringWithFormat:@"/Library/KuaiDial/T9/%@.plist", [_list objectAtIndex:indexPath.row]];
		if([[NSFileManager defaultManager] fileExistsAtPath:plist]){
			NSMutableDictionary *loaddata = [NSMutableDictionary dictionaryWithContentsOfFile:plist];
			if(!loaddata)
				return;

			NSMutableDictionary *data = nil;
			if([[NSFileManager defaultManager] fileExistsAtPath:saveplist])
				data = [NSMutableDictionary dictionaryWithContentsOfFile:saveplist];
			if(!data)
				data = [NSMutableDictionary dictionary];

			NSString *key;
			NSEnumerator *ie = [loaddata keyEnumerator];
			while(key=[ie nextObject]){
				NSString *str = [loaddata objectForKey:key];
				if([str length]){
					[data setObject:str forKey:key];
				}else{
					[data removeObjectForKey:key];
				}
			}
			[data writeToFile:saveplist atomically:YES];
		}
	}

	[_ListController reLoad];
}

- (void) dealloc {
    [_tableView release];
    [_dict release];
	[_list release];
	[_title release];
    [super dealloc];
}

@end



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// KDEditViewController
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@interface KDEditViewController: UITableViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource> {
	UITextField *_nameField;
	UITextField *_numberField;
	NSMutableDictionary *_dict;
}

- (void) dealloc;

@end

@implementation KDEditViewController

- (id) initWithDict:(NSMutableDictionary *)dict{
	self =  [super initWithStyle:1];
	_dict = [dict retain];
	return self;
}

- (NSString *)getName {
	return _nameField ? _nameField.text : nil;
}

- (NSString *)getNumber {
	return _numberField ? _numberField.text : nil;
}

- (NSString *)getKey {
	return [_dict objectForKey:@"number"];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
	return 2;
}

- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;

	if(indexPath.row == 0){
		cell = [tableView dequeueReusableCellWithIdentifier:@"nameCell"];
		if (!cell) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100) reuseIdentifier:@"nameCell"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;

			if(!_nameField){
				_nameField = [[UITextField alloc] initWithFrame:CGRectMake(10,12,285,20)];
				[_nameField setDelegate:self];
				_nameField.textAlignment=UITextAlignmentLeft;
				_nameField.font = [UIFont systemFontOfSize:17];
				_nameField.textColor = [UIColor colorWithRed:81/255.0 green:102/255.0 blue:145/255.0 alpha:1];
				_nameField.backgroundColor = [UIColor clearColor];
				_nameField.adjustsFontSizeToFitWidth=YES;
				_nameField.clearButtonMode = UITextFieldViewModeWhileEditing;
				_nameField.tag = 1;
				_nameField.placeholder = [_dict objectForKey:@"nameTip"];
				_nameField.text = [_dict objectForKey:@"name"];
				[_nameField becomeFirstResponder];
			}

			[cell.contentView addSubview:_nameField];
		}

	}else{
		cell = [tableView dequeueReusableCellWithIdentifier:@"numberCell"];
		if (!cell) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100) reuseIdentifier:@"numberCell"] autorelease];
			cell.selectionStyle = UITableViewCellSelectionStyleNone;

			if(!_numberField){
				_numberField = [[UITextField alloc] initWithFrame:CGRectMake(10,12,285,20)];
				[_numberField setDelegate:self];
				_numberField.keyboardType=UIKeyboardTypePhonePad;
				_numberField.textAlignment=UITextAlignmentLeft;
				_numberField.font = [UIFont systemFontOfSize:17];
				_numberField.textColor = [UIColor colorWithRed:81/255.0 green:102/255.0 blue:145/255.0 alpha:1];
				_numberField.backgroundColor = [UIColor clearColor];
				_numberField.adjustsFontSizeToFitWidth=YES;
				_numberField.clearButtonMode = UITextFieldViewModeWhileEditing;
				_numberField.tag = 2;
				_numberField.placeholder = [_dict objectForKey:@"numberTip"];
				_numberField.text = [_dict objectForKey:@"number"];
			}

			[cell.contentView addSubview:_numberField];
		}
	}

    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.row == 0)
		[_nameField becomeFirstResponder];
	else
		[_numberField becomeFirstResponder];
}

- (void) dealloc {
    [_dict release];
	[_nameField release];
	[_numberField release];
    [super dealloc];
}

@end


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// KDListSettingsController
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#define uAREA		1
#define uT9			2
#define uPRIORITY	3
#define uBLACK		4
#define uWHITE		5

@interface KDListSettingsController: PSViewController <UITableViewDelegate, UITableViewDataSource> {
	UIWindow *_editwindow;
	UIView *_editview;
	UINavigationController *_navcontroller;
	KDEditViewController *_editcontroller;
    UITableView *_tableView;
	NSMutableString *_saveplist;
	NSMutableString *_title;
	NSMutableArray *_list;
	int _selectrow;
	int _use;
}

- (id) view;
- (id) navigationTitle;
- (void) dealloc;

@end

@implementation KDListSettingsController

- (void)viewWillBecomeVisible:(void *)spec{
	if(spec)
		[self loadFromSpecifier:spec];
	[super viewWillBecomeVisible:spec];
}

- (void)setSpecifier:(PSSpecifier *)spec{
	[self loadFromSpecifier:spec];
	[super setSpecifier:spec];
}

- (void)loadFromSpecifier:(PSSpecifier *)spec{
	_ListController = self;

	if(!_title)
		_title = [[NSMutableString alloc] init];
	[_title setString:[spec name]];

	_use = [[spec propertyForKey:@"use"] intValue];
	NSString *useid = nil;
	switch(_use){
		case uAREA:
			useid = @"area";
			break;
		case uT9:
			useid = @"t9";
			break;
		case uPRIORITY:
			useid = @"priority";
			break;
		case uBLACK:
			useid = @"black";
			break;
		case uWHITE:
			useid = @"white";
			break;
		default:
			return;
	}

	if(!_saveplist)
	   _saveplist = [[NSMutableString alloc] init];

	[_saveplist setString:[NSString stringWithFormat:@"/private/var/mobile/Library/Preferences/kuaidial.%@.plist", [useid lowercaseString]]];

	if(![[NSFileManager defaultManager] fileExistsAtPath:_saveplist]){
		NSString *defaultplist = [NSString stringWithFormat:@"/Library/KuaiDial/Default/kuaidial.%@.plist", [useid lowercaseString]];
		if([[NSFileManager defaultManager] fileExistsAtPath:defaultplist]){
			NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:defaultplist];
			if(dict)
				[dict writeToFile:_saveplist atomically:YES];
		}
	}

	[self loadPlist];

	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480-64) style:UITableViewStyleGrouped];
	[_tableView setDataSource:self];
	[_tableView setDelegate:self];

	if ([self respondsToSelector:@selector(navigationItem)])
		[[self navigationItem] setTitle:[[_SettingsController bundle] localizedStringForKey:_title value:_title table:nil]];
}

-(void)loadPlist {
	if(!_list)
		_list = [[NSMutableArray alloc] init];
	else
		[_list removeAllObjects];

	if([[NSFileManager defaultManager] fileExistsAtPath:_saveplist]){
		NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithContentsOfFile:_saveplist];
		if(dict){
			NSArray *keys = [[dict allKeys] sortedArrayUsingSelector:@selector(compare:)];
			NSString *key;
			NSEnumerator *ie = [keys objectEnumerator];
			while(key=[ie nextObject]){
				NSMutableDictionary *propertys = [[NSMutableDictionary alloc] init];
				[propertys setObject:key forKey:@"number"];
				[propertys setObject:[dict objectForKey:key] forKey:@"name"];
				[_list addObject:propertys];
				[propertys release];
			}
		}
	}
}

- (id) view {
	return _tableView;
}

-(void) reLoad {
	[self loadPlist];
	if(_tableView)
		[_tableView reloadData];
}

- (NSString *) navigationTitle {
	if(_title)
		return [[_SettingsController bundle] localizedStringForKey:_title value:_title table:nil];

	return [super navigationTitle];
}

- (int) numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (id) tableView:(UITableView *)tableView titleForHeaderInSection:(int)section {
    return nil;
}

- (int) tableView:(UITableView *)tableView numberOfRowsInSection:(int)section {
	switch(section){
		case 0:
			switch(_use){
				case uAREA:
				case uPRIORITY:
					return 1;
				case uT9:
					return 2;
				case uBLACK:
				case uWHITE:
					return 3;
			}
			break;
		case 1:
			return [_list count];
	}

	return 0;
}

- (NSString *)LS:(NSString *)str{
	return [[self bundle] localizedStringForKey:str value:str table:nil];
}

- (NSString *)getNavigationTitle:(NSIndexPath*)indexPath{

	switch(_use){
		case uAREA:
		   return indexPath.section ? [self LS:@"Edit Area"] : [self LS:@"Add Area"];

		case uT9:
			if(indexPath.section){
				return [self LS:@"Edit Code Table"];
			}else switch(indexPath.row){
				case 0:
					return [self LS:@"Add Code Table"];
				case 1:
					return [self LS:@"Add built-in code table (0-9)"];
			}
			break;

		case uPRIORITY:
		case uBLACK:
		case uWHITE:
			if(indexPath.section){
				return [self LS:@"Edit Number"];
			}else switch(indexPath.row){
				case 0:
					return [self LS:@"Add Number"];
				case 1:
					return [self LS:@"Select call history"];
				case 2:
					return [self LS:@"Select contact"];
			}
			break;
	}

	return @"";
}

- (id) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;

	switch(indexPath.section){
		case 0:
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"NormalCell"];
				if (!cell){
					cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100) reuseIdentifier:@"NormalCell"] autorelease];
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
				}
				cell.text = [self getNavigationTitle:indexPath];
			}
			break;

		case 1:
			{
				cell = [tableView dequeueReusableCellWithIdentifier:@"NumberCell"];
				if (!cell) {
					cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, 100, 100) reuseIdentifier:@"NumberCell"] autorelease];
					cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

					UILabel *nameLabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 5, 190, 20)];
					nameLabel.textAlignment=UITextAlignmentLeft;
					nameLabel.font = [UIFont boldSystemFontOfSize:16];
					nameLabel.textColor = [UIColor blackColor];
					nameLabel.backgroundColor = [UIColor clearColor];
					nameLabel.highlightedTextColor = [UIColor whiteColor];
					nameLabel.adjustsFontSizeToFitWidth=YES;
					nameLabel.minimumFontSize=12;
					nameLabel.tag = 1;
					[cell.contentView addSubview:nameLabel];
					[nameLabel release];

					UILabel *numberLabel=[[UILabel alloc] initWithFrame:CGRectMake(10,26,190,20)];
					numberLabel.textAlignment=UITextAlignmentLeft;
					numberLabel.font = [UIFont systemFontOfSize:16];
					numberLabel.textColor = [UIColor grayColor];
					numberLabel.backgroundColor = [UIColor clearColor];
					numberLabel.highlightedTextColor = [UIColor whiteColor];
					numberLabel.adjustsFontSizeToFitWidth=YES;
					numberLabel.minimumFontSize=12;
					numberLabel.tag = 2;
					[cell.contentView addSubview:numberLabel];
					[numberLabel release];
				}

				UILabel *nameLabel = (UILabel *)[cell.contentView viewWithTag:1];
				UILabel *numberLabel = (UILabel *)[cell.contentView viewWithTag:2];

				NSMutableDictionary *propertys = [_list objectAtIndex:indexPath.row];
				NSString *number = [propertys objectForKey:@"number"];
				NSString *name = [propertys objectForKey:@"name"];
				if(name && [name length] && ![name isEqualToString:@" "]){
					[nameLabel setFrame:CGRectMake(10, 5, 190, 22)];
					nameLabel.text = name;
					numberLabel.text = number;
				}else{
					[nameLabel setFrame:CGRectMake(10, 5, 190, 40)];
					nameLabel.text = number;
					numberLabel.text = nil;
				}
			}
	}

    return cell;
}

-(void) cancelEditPane{
	[self hideEditPaneFromType:0];
}

-(void) newEditPane{
	[self hideEditPaneFromType:1];
}

-(void) changeEditPane{
	[self hideEditPaneFromType:2];
}

-(void) newData {
	[self updateData:nil];
	[self releaseEditPane];
}

-(void) changeData {
	[self updateData:[_editcontroller getKey]];
	[self releaseEditPane];
}

-(void)updateData:(NSString *)key{
	NSString *number = [_editcontroller getNumber];
	if(!number)
		return;

	NSString *name = [_editcontroller getName];
	if(!name)
		name = @"";

	int maxNumberLength = 15;
	int maxNameLength = 20;

	switch(_use){
		//case uAREA:
			//maxNumberLength = 15;
			//maxNameLength = 20;
			//break;

		case uT9:
			maxNumberLength = 9;
			maxNameLength = 100;
			break;

		//case uPRIORITY:
			//maxNumberLength = 15;
			//maxNameLength = 20;
			//break;

		//case uBLACK:
		//case uWHITE:
			//maxNumberLength = 15;
			//maxNameLength = 20;
			//break;
	}

	if([number length] > maxNumberLength)
		number = [number substringToIndex:maxNumberLength];

	if([name length] > maxNameLength)
		name = [name substringToIndex:maxNameLength];

	NSMutableDictionary *data = nil;
	if([[NSFileManager defaultManager] fileExistsAtPath:_saveplist])
	   data = [NSMutableDictionary dictionaryWithContentsOfFile:_saveplist];
	if(!data)
	   data = [NSMutableDictionary dictionary];

	if(key){
		[data removeObjectForKey:key];
		[data setValue:name forKey:number];
		[data writeToFile:_saveplist atomically:YES];
		[_list replaceObjectAtIndex:_selectrow withObject:[NSDictionary dictionaryWithObjectsAndKeys:number, @"number", name, @"name", nil]];
		[_tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:_selectrow inSection:1]]  withRowAnimation:UITableViewRowAnimationFade];
	}else{
		[data setValue:name forKey:number];
		[data writeToFile:_saveplist atomically:YES];
		[_list insertObject:[NSDictionary dictionaryWithObjectsAndKeys:number, @"number", name, @"name", nil] atIndex:0];
		[_tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:0 inSection:1]] withRowAnimation:UITableViewRowAnimationFade];
	}

	if(_use == uAREA || _use == uBLACK || _use == uWHITE)
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), @"KDPrefsChanged", NULL, NULL, true);
}

-(void) hideEditPaneFromType:(int)type{
	if(type){
		NSString *number = [_editcontroller getNumber];
		if(!number)
			return;

		NSString *name = [_editcontroller getName];
		if(!name)
			name = @"";

		int minNumberLength = 2;
		int minNameLength = 0;

		switch(_use){
			case uAREA:
				minNumberLength = 3;
				minNameLength = 1;
				break;

			case uT9:
				minNumberLength = 1;
				minNameLength = 1;
				break;

			//case uPRIORITY:
				//minNumberLength = 2;
				//minNameLength = 0;
				//break;

			//case uBLACK:
			//case uWHITE:
				//minNumberLength = 2;
				//minNameLength = 0;
				//break;
		}

		if([number length] < minNumberLength || [name length] < minNameLength)
			return;
	}

	[UIView beginAnimations: @"animation" context:_editview];
	[UIView setAnimationDuration:0.3];
	[_editview setFrame:CGRectMake(0, 480, 320, 480)];
	[UIView setAnimationDelegate:self];
	if(type == 1)
		[UIView setAnimationDidStopSelector:@selector(newData)]; 
	else if(type == 2)
		[UIView setAnimationDidStopSelector:@selector(changeData)]; 
	else
		[UIView setAnimationDidStopSelector:@selector(releaseEditPane)]; 
	[UIView commitAnimations];
}

-(void) releaseEditPane {
	if(_navcontroller){
		[[_navcontroller view] removeFromSuperview];
		[_navcontroller release];
		_navcontroller = nil;
	}
	if(_editcontroller){
		[_editcontroller release];
		_editcontroller = nil;
	}
	if(_editview){
		[_editview release];
		_editview = nil;
	}
	if(_editwindow){
		[_editwindow setHidden:YES];
		[_editwindow release];
		_editwindow = nil;
	}
}


- (void)viewDidBecomeVisible {
	@try {
		[self showLeftButton:nil withStyle:0 rightButton:[[self bundle] localizedStringForKey:@"Edit" value:@"Edit" table:nil] withStyle:4];
	}
	@catch (id ue) {}

   [super viewDidBecomeVisible];
}

- (void) navigationBarButtonClicked:(int)buttonIndex {
	if(_tableView){
		if([_tableView isEditing]){
			[_tableView setEditing:NO animated:YES];
			[self showLeftButton:nil withStyle:0 rightButton:[[self bundle] localizedStringForKey:@"Edit" value:@"Edit" table:nil] withStyle:4];
		}else{
			[_tableView setEditing:YES animated:YES];
			[self showLeftButton:nil withStyle:0 rightButton:[[self bundle] localizedStringForKey:@"Done" value:@"Done" table:nil] withStyle:2];
		}
	}

	[super navigationBarButtonClicked:buttonIndex];
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if((_use == uBLACK || _use == uWHITE)&& indexPath.section == 0 && indexPath.row > 0){
		NSString *plist = [[NSString alloc] initWithString:(_use == uWHITE) ?
		   	@"/private/var/mobile/Library/Preferences/kuaidial.white.plist" : @"/private/var/mobile/Library/Preferences/kuaidial.black.plist"];
		KDContactViewController *next = [[KDContactViewController alloc] initWithTitle:[self getNavigationTitle:indexPath] 
																				  type:indexPath.row-1 plist:plist];
		[self pushController:next];
		[next setParentController:self];

	}else if(_use == uT9 && indexPath.section == 0 && indexPath.row == 1){
		KDListViewController *next = [[KDListViewController alloc] initWithTitle:[self getNavigationTitle:indexPath]];
		[self pushController:next];
		[next setParentController:self];

	}else{

		if(!_editwindow)
			_editwindow = [[UIWindow alloc] initWithContentRect:[[UIScreen mainScreen] bounds]];

		if(!_editview)
			_editview = [[UIView alloc] initWithFrame:CGRectMake(0, 480, 320, 480)];

		if(!_editcontroller){

			NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];

			switch(_use){
				case uAREA:
				   [dict setObject:[self LS:@"Area"] forKey:@"nameTip"];
				   [dict setObject:[self LS:@"Prefix"] forKey:@"numberTip"];
				   break;
				case uT9:
				   [dict setObject:[self LS:@"Character"] forKey:@"nameTip"];
				   [dict setObject:[self LS:@"T9 Keyboard"] forKey:@"numberTip"];
				   break;
				case uPRIORITY:
				case uBLACK:
				case uWHITE:
				   [dict setObject:[self LS:@"Name"] forKey:@"nameTip"];
				   [dict setObject:[self LS:@"Phone Number"] forKey:@"numberTip"];
			}

			if(indexPath.section){
				NSMutableDictionary *propertys = [_list objectAtIndex:indexPath.row];
				NSString *number = [propertys objectForKey:@"number"];
				NSString *name = [propertys objectForKey:@"name"];
				if(number)
					[dict setObject:number forKey:@"number"];
				if(name)
					[dict setObject:name forKey:@"name"];
			}

			_editcontroller = [[KDEditViewController alloc] initWithDict:dict];
			[dict release];

			[_editcontroller setTitle:[self getNavigationTitle:indexPath]];
			[[_editcontroller navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditPane)]];
			[[_editcontroller navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:indexPath.section == 0 ? @selector(newEditPane) : @selector(changeEditPane)]];
		}

		if(!_navcontroller){
			_navcontroller = [[UINavigationController alloc] initWithRootViewController:_editcontroller];
			[[_navcontroller navigationBar] setBarStyle:0];
		}

		[_editview addSubview:[_navcontroller view]];

		UIKeyboard *keyboard = [[UIKeyboard alloc] initWithFrame:CGRectMake(0, 480 - [UIKeyboard defaultSize].height, 320, [UIKeyboard defaultSize].height)];
		[_editview addSubview:keyboard];
		[keyboard release];

		_editwindow.contentView = _editview;
		[_editwindow setHidden:NO];

		[UIView beginAnimations: @"animation" context:_editview];
		[UIView setAnimationDuration:0.3];
		[_editview setFrame:CGRectMake(0, 0, 320, 480)];
		[UIView setAnimationDelegate:self];
		[UIView commitAnimations];
	}

	_selectrow = indexPath.row;
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
	if(indexPath.section == 1){
		NSMutableDictionary *propertys = [_list objectAtIndex:indexPath.row];
		NSString *number = [propertys objectForKey:@"number"];
		NSMutableDictionary *data = [NSMutableDictionary dictionaryWithContentsOfFile:_saveplist];
		[data removeObjectForKey:number];
		[data writeToFile:_saveplist atomically:YES];
		[_list removeObjectAtIndex:indexPath.row];
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];

		if(_use == uAREA || _use == uBLACK || _use == uWHITE)
			CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), @"KDPrefsChanged", NULL, NULL, true);
	}
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
	return indexPath.section == 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
	return indexPath.section == 1 ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleNone;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
	return indexPath.section == 1 ? 50 : 43;
}

- (void) dealloc {
	_ListController = nil;
    [_tableView release];
	[_saveplist release];
	[_list release];
	[_title release];
	[self releaseEditPane];
    [super dealloc];
}

@end

