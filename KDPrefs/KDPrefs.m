#import "KDPrefs.h"

@implementation KDPrefs

@synthesize plistFile,PrefixNumber,Enable,AutoActivate,MenuDial,Highlight,ShowCount,ShowAvatar,NameOrder,TxtTable,JianPin,PinYin,English,PhoneNumber;

-(id)initVar{

	plistFile=[[NSMutableString alloc] initWithString:@"/var/mobile/Library/Preferences/kuaidial.plist"];
	PrefixNumber=[[NSMutableString alloc] initWithString:@""];

	[self loadPrefs];

	return self;	
}

-(void)loadPrefs{

	NSDictionary *prefs;

	if(![[NSFileManager defaultManager] fileExistsAtPath:plistFile]){

		prefs=[NSMutableDictionary dictionary];

		[prefs setObject:[NSNumber numberWithBool:YES] forKey:@"Enable"];
		[prefs setObject:[NSNumber numberWithBool:YES] forKey:@"AutoActivate"];
		[prefs setObject:[NSNumber numberWithBool:YES] forKey:@"MenuDial"];
		[prefs setObject:[NSNumber numberWithBool:NO] forKey:@"Highlight"];
		[prefs setObject:[NSNumber numberWithBool:NO] forKey:@"ShowCount"];
		[prefs setObject:[NSNumber numberWithBool:NO] forKey:@"ShowAvatar"];
		[prefs setObject:[NSNumber numberWithBool:NO] forKey:@"NameOrder"];
		[prefs setObject:[NSNumber numberWithBool:NO] forKey:@"TxtTable"];

		[prefs setObject:[NSNumber numberWithBool:YES] forKey:@"JianPin"];
		[prefs setObject:[NSNumber numberWithBool:YES] forKey:@"PinYin"];
		[prefs setObject:[NSNumber numberWithBool:YES] forKey:@"English"];
		[prefs setObject:[NSNumber numberWithBool:YES] forKey:@"PhoneNumber"];

		[prefs setObject:@"17951" forKey:@"PrefixNumber"];

		[prefs writeToFile:plistFile atomically:YES];
	}else{
		prefs=[NSDictionary dictionaryWithContentsOfFile:plistFile];
	}

	Enable=[[prefs objectForKey:@"Enable"] boolValue];
	AutoActivate=[[prefs objectForKey:@"AutoActivate"] boolValue];
	MenuDial=[[prefs objectForKey:@"MenuDial"] boolValue];
	Highlight=[[prefs objectForKey:@"Highlight"] boolValue];
	ShowCount=[[prefs objectForKey:@"ShowCount"] boolValue];
	ShowAvatar=[[prefs objectForKey:@"ShowAvatar"] boolValue];
	NameOrder=[[prefs objectForKey:@"NameOrder"] boolValue];
	TxtTable=[[prefs objectForKey:@"TxtTable"] boolValue];

	JianPin=[[prefs objectForKey:@"JianPin"] boolValue];
	PinYin=[[prefs objectForKey:@"PinYin"] boolValue];
	English=[[prefs objectForKey:@"English"] boolValue];
	PhoneNumber=[[prefs objectForKey:@"PhoneNumber"] boolValue];

	[PrefixNumber setString:[prefs objectForKey:@"PrefixNumber"]];
}

-(void)savePrefs{

	NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:plistFile];

	[prefs setObject:[NSNumber numberWithBool:Enable] forKey:@"Enable"];
	[prefs setObject:[NSNumber numberWithBool:AutoActivate] forKey:@"AutoActivate"];
	[prefs setObject:[NSNumber numberWithBool:MenuDial] forKey:@"MenuDial"];
	[prefs setObject:[NSNumber numberWithBool:Highlight] forKey:@"Highlight"];
	[prefs setObject:[NSNumber numberWithBool:ShowCount] forKey:@"ShowCount"];
	[prefs setObject:[NSNumber numberWithBool:ShowAvatar] forKey:@"ShowAvatar"];
	[prefs setObject:[NSNumber numberWithBool:NameOrder] forKey:@"NameOrder"];
	[prefs setObject:[NSNumber numberWithBool:TxtTable] forKey:@"TxtTable"];

	[prefs setObject:[NSNumber numberWithBool:JianPin] forKey:@"JianPin"];
	[prefs setObject:[NSNumber numberWithBool:PinYin] forKey:@"PinYin"];
	[prefs setObject:[NSNumber numberWithBool:English] forKey:@"English"];
	[prefs setObject:[NSNumber numberWithBool:PhoneNumber] forKey:@"PhoneNumber"];

	[prefs setObject:PrefixNumber forKey:@"PrefixNumber"];

	[prefs writeToFile:plistFile atomically:YES];
	[prefs release];
}

-(void)dealloc{
	[plistFile release];
	[PrefixNumber release];
	[super dealloc];
}

@end
