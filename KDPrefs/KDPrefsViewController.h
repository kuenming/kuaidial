#import <UIKit/UIKit.h>
#import <UIKit/UIPushButton.h>
#import "KDPrefs.h"

@interface KDPrefsViewController:UITableViewController<UITextFieldDelegate> {

	KDPrefs *prefs;

    UIWindow *windowCloseKeyboard;
    UIView *viewCloseKeyboard;
    UIPushButton *buttonCloseKeyboard;
    UITextField *textPrefix;
	UILabel *labelNext;
}

@property (nonatomic,retain) KDPrefs *prefs;
@property (nonatomic,retain) UILabel *labelNext;

@end
