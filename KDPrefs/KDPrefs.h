#import <UIKit/UIKit.h>

@interface KDPrefs:NSObject {

	NSMutableString *plistFile;
	NSMutableString *PrefixNumber;

	bool Enable;
	bool AutoActivate;
	bool MenuDial;
	bool Highlight;
	bool ShowCount;
	bool ShowAvatar;
	bool NameOrder;
	bool TxtTable;

	bool JianPin;
	bool PinYin;
	bool English;
	bool PhoneNumber;
}

@property (nonatomic,retain) NSMutableString *plistFile;
@property (nonatomic,retain) NSMutableString *PrefixNumber;

@property (readwrite,assign) bool Enable;
@property (readwrite,assign) bool AutoActivate;
@property (readwrite,assign) bool MenuDial;
@property (readwrite,assign) bool Highlight;
@property (readwrite,assign) bool ShowCount;
@property (readwrite,assign) bool ShowAvatar;
@property (readwrite,assign) bool NameOrder;
@property (readwrite,assign) bool TxtTable;

@property (readwrite,assign) bool JianPin;
@property (readwrite,assign) bool PinYin;
@property (readwrite,assign) bool English;
@property (readwrite,assign) bool PhoneNumber;

-(void)loadPrefs;
-(void)savePrefs;

@end
