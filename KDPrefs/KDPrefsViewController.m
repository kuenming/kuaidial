#import <UIKit/UIKit.h>
#import <UIKit/UIPushButton.h>
#import "KDPrefs.h"
#import "KDPrefsApp.h"
#import "KDPrefsViewController.h"
#import "KDPrefsViewControllerNext.h"

@implementation KDPrefsViewController

@synthesize prefs,labelNext;

-(id)initWithStyle:(int)style{

    self=[super initWithStyle:style];
    if(self){
        [self setTitle:@"KuaiDial"];
        [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Exit",nil) style:5 target:self action:@selector(exitApp)]];
        [[self navigationItem] setLeftBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Open Phone",nil) style:5 target:self action:@selector(openApp)]];
    }

	prefs=[[KDPrefs alloc] initVar];

    return self;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(int)section{
	switch(section){
		case 0:
			return NSLocalizedString(@"General",nil);
			break;
		case 1:
			return NSLocalizedString(@"Preferences",nil);
			break;
		case 2:
			return NSLocalizedString(@"Search",nil);
			break;
		case 3:
			return NSLocalizedString(@"About",nil);
			break;
		default:
			return @"";
	}
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section{
	switch(section){
		case 0:
			return 2;
			break;
		case 1:
			return 7;
			break;
		case 2:
			return 4;
			break;
		case 3:
			return 1;
			break;
		default:
			return 0;
	}
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *reuseIdToggle=@"ToggleCell";
    static NSString *reuseIdSimple=@"SimpleCell";
    static NSString *reuseIdPrefix=@"PrefixCell";
    static NSString *reuseIdName=@"NameCell";

    UITableViewCell *cell=nil;

	if(indexPath.section==1&&indexPath.row==0){

		UITextField *text;

        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdPrefix];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0,0,0,0) reuseIdentifier:reuseIdPrefix] autorelease];
            [cell setSelectionStyle:0];
            [cell setAccessoryType:0];
			text=[[UITextField alloc] initWithFrame:CGRectMake(0,0,150,20)];
    		text.textAlignment=UITextAlignmentRight;
			text.keyboardType=UIKeyboardTypePhonePad;
			UIColor *color=[[UIColor alloc] initWithRed:.2 green:.3 blue:.5 alpha:1];
			text.textColor=color;
			[color release];
			text.delegate=self;
			[cell setAccessoryView:text];
			[text release];
		}

		text = [cell accessoryView];
		[cell setText:NSLocalizedString(@"Prefix Number",nil)];
		[text setText:prefs.PrefixNumber];
		textPrefix=text;

	}else if(indexPath.section==1&&indexPath.row==1){

        cell = [tableView dequeueReusableCellWithIdentifier:reuseIdName];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0,0,0,0) reuseIdentifier:reuseIdName] autorelease];
            [cell setSelectionStyle:1];
            [cell setAccessoryType:1];
			labelNext=[[UILabel alloc] initWithFrame:CGRectMake(180,12,100,20)];
			labelNext.textAlignment=UITextAlignmentRight;
			UIColor *color=[[UIColor alloc] initWithRed:.2 green:.3 blue:.5 alpha:1];
			labelNext.textColor=color;
			[color release];
			[cell addSubview:labelNext];
        }

        [cell setText:NSLocalizedString(@"Name Order",nil)];
		[labelNext setText:prefs.NameOrder?NSLocalizedString(@"First, Last",nil):NSLocalizedString(@"Last, First",nil)];

	}else if(indexPath.section==3){

		UILabel *ver;

		cell = [tableView dequeueReusableCellWithIdentifier:reuseIdSimple];
		if (cell == nil) {
			cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0,0,0,0) reuseIdentifier:reuseIdSimple] autorelease];
			[cell setSelectionStyle:0];
			[cell setAccessoryType:0];
			ver=[[UILabel alloc] initWithFrame:CGRectMake(0,0,150,20)];
			ver.textAlignment=UITextAlignmentRight;
			UIColor *color=[[UIColor alloc] initWithRed:.2 green:.3 blue:.5 alpha:1];
			ver.textColor=color;
			[color release];
			[cell setAccessoryView:ver];
		}

		ver = [cell accessoryView];
		[cell setText:NSLocalizedString(@"Version",nil)];
		[ver setText:@"0.1.6"];

	}else{

		UISwitch *toggle;

		cell=[tableView dequeueReusableCellWithIdentifier:reuseIdToggle];
		if (cell==nil){
			cell=[[[UITableViewCell alloc] initWithFrame:CGRectMake(0,0,0,0) reuseIdentifier:reuseIdToggle] autorelease];
			[cell setSelectionStyle:0];
			toggle=[[UISwitch alloc] init];
			[toggle addTarget:self action:@selector(switchToggled:) forControlEvents:4096];
			[cell setAccessoryView:toggle];
			[toggle release];
		}

		toggle = [cell accessoryView];

		switch(indexPath.section){

			case 0:
				switch (indexPath.row) {
					case 0:
						[cell setText:NSLocalizedString(@"Enable KuaiDial",nil)];
						[toggle setOn:prefs.Enable];
						break;
					case 1:
						[cell setText:NSLocalizedString(@"Auto Activate",nil)];
						[toggle setOn:prefs.AutoActivate];
						break;
				}
				break;

			case 1:
				switch (indexPath.row) {
					case 2:
						[cell setText:NSLocalizedString(@"Menu Dial",nil)];
						[toggle setOn:prefs.MenuDial];
						break;
					case 3:
						[cell setText:NSLocalizedString(@"Highlight",nil)];
						[toggle setOn:prefs.Highlight];
						break;
					case 4:
						[cell setText:NSLocalizedString(@"Show Count",nil)];
						[toggle setOn:prefs.ShowCount];
						break;
					case 5:
						[cell setText:NSLocalizedString(@"Show Avatar",nil)];
						[toggle setOn:prefs.ShowAvatar];
						break;
					case 6:
						[cell setText:NSLocalizedString(@"Custom Table",nil)];
						[toggle setOn:prefs.TxtTable];
						break;
				}
				break;

			case 2:
				switch (indexPath.row) {
					case 0:
						[cell setText:NSLocalizedString(@"JianPin",nil)];
						[toggle setOn:prefs.JianPin];
						break;
					case 1:
						[cell setText:NSLocalizedString(@"PinYin",nil)];
						[toggle setOn:prefs.PinYin];
						break;
					case 2:
						[cell setText:NSLocalizedString(@"English",nil)];
						[toggle setOn:prefs.English];
						break;
					case 3:
						[cell setText:NSLocalizedString(@"Phone Number",nil)];
						[toggle setOn:prefs.PhoneNumber];
						break;
				}
				break;
		}
	}

    return cell;
}


-(void)switchToggled:(UISwitch *)control{

	NSIndexPath *indexPath = [self.tableView indexPathForCell:[control superview]];

	switch(indexPath.section){
		case 0:
			switch (indexPath.row) {
				case 0:
					prefs.Enable=[control isOn];
					break;
				case 1:
					prefs.AutoActivate=[control isOn];
					break;
			}
			break;
		case 1:
			switch (indexPath.row) {
				case 2:
					prefs.MenuDial=[control isOn];
					break;
				case 3:
					prefs.Highlight=[control isOn];
					break;
				case 4:
					prefs.ShowCount=[control isOn];
					break;
				case 5:
					prefs.ShowAvatar=[control isOn];
					break;
				case 6:
					prefs.TxtTable=[control isOn];
					break;
			}
			break;

		case 2:
			switch (indexPath.row) {
				case 0:
					prefs.JianPin=[control isOn];
					break;
				case 1:
					prefs.PinYin=[control isOn];
					break;
				case 2:
					prefs.English=[control isOn];
					break;
				case 3:
					prefs.PhoneNumber=[control isOn];
					break;
			}
			break;
	}

	[prefs savePrefs];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

	if(indexPath.section==1&&indexPath.row==0){

		[textPrefix becomeFirstResponder];

	}else if(indexPath.section==1&&indexPath.row==1){

	    UIViewController *vc=nil;

    	vc=[[[KDPrefsViewControllerNext alloc] initWithVc:self] autorelease];

		[[self navigationController] pushViewController:vc animated:YES];
	}
}

-(void)exitApp{

	[[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.apple.springboard" suspended:NO];
}

-(void)openApp{

	[[UIApplication sharedApplication] launchApplicationWithIdentifier:@"com.apple.mobilephone" suspended:NO];
}

-(int)numberOfSectionsInTableView:(UITableView *)tableView{
	return 4;
}


-(bool)textFieldShouldBeginEditing:(UITextField *)textField{

	textPrefix=textField;

	buttonCloseKeyboard=[[UIPushButton alloc] initWithTitle:@"" autosizesToFit:NO];
	[buttonCloseKeyboard setFrame:CGRectMake(0,0,320,480)];
	[buttonCloseKeyboard addTarget:self action:@selector(closeKeyboard) forEvents:1];

	viewCloseKeyboard=[[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)];
	[viewCloseKeyboard addSubview:buttonCloseKeyboard];

	windowCloseKeyboard=[[UIWindow alloc] initWithContentRect:CGRectMake(0,0,320,480)];	
	windowCloseKeyboard.contentView=viewCloseKeyboard;
	[windowCloseKeyboard makeKeyAndVisible];

	return YES;
}

-(void)closeKeyboard{

	[prefs.PrefixNumber setString:textPrefix.text];

	[prefs savePrefs];

	[textPrefix resignFirstResponder];

	[buttonCloseKeyboard release];
	[viewCloseKeyboard release];
	[windowCloseKeyboard release];
}

-(void)dealloc{
	[prefs release];
	[labelNext release];
	[super dealloc];
}

@end
