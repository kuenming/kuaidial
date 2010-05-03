/**
 * Name: KuaiDial Settings
 * Author: linspike
 * Last-modified: 2009-12-06
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <Preferences/PSTableCell.h>
#import <Preferences/PSTextEditingPane.h>

static NSMutableDictionary *_settings;
static NSString *_plist;

@interface KuaiDialSettingsController: PSListController {
}

- (id) initForContentSize:(CGSize)size;
- (void) dealloc;
- (void) suspend;
- (id) specifiers;
- (void) setPreferenceValue:(id)value specifier:(PSSpecifier *)spec;
- (id) readPreferenceValue:(PSSpecifier *)spec;
- (NSArray *)localizedSpecifiersForSpecifiers:(NSArray *)s;
- (void)emailApp:(NSString *)str;

@end

@implementation KuaiDialSettingsController

- (id) initForContentSize:(CGSize)size {
    if ((self = [super initForContentSize:size]) != nil) {
        _plist = [[NSString stringWithFormat:@"%@/Library/Preferences/kuaidial.plist", NSHomeDirectory()] retain];
        _settings = [([NSMutableDictionary dictionaryWithContentsOfFile:_plist] ?: [NSMutableDictionary dictionary]) retain];
    }
	return self;
}

- (void) dealloc {
    [_settings release];
    [_plist release];
    [super dealloc];
}

- (void) suspend {
    NSData *data = [NSPropertyListSerialization dataFromPropertyList:_settings format:NSPropertyListBinaryFormat_v1_0 errorDescription:NULL];
    if (!data)
        return;
    if (![data writeToFile:_plist options:NSAtomicWrite error:NULL])
        return;
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

- (void)emailApp:(NSString *)str{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:linspike@gmail.com?subject=KuaiDial"]];
}

@end

