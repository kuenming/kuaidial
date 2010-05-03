#import <UIKit/UIKit.h>
#import "KDPrefs.h"
#import "KDPrefsApp.h"
#import "KDPrefsViewController.h"
#import "KDPrefsViewControllerNext.h"

@implementation KDPrefsViewControllerNext

-(id)initWithVc:(KDPrefsViewController *)Vc{

	vc=Vc;

    self=[super initWithStyle:1];
    if(self){
        [self setTitle:NSLocalizedString(@"Name Order",nil)];
    }

    return self;
}

-(int)numberOfSectionsInTableView:(UITableView *)tableView{
	return 1;
}

-(int)tableView:(UITableView *)tableView numberOfRowsInSection:(int)section{
	return 2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *reuseIdSimple=@"SimpleCell";

    UITableViewCell *cell=nil;

	cell = [tableView dequeueReusableCellWithIdentifier:reuseIdSimple];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectMake(0,0,0,0) reuseIdentifier:reuseIdSimple] autorelease];
		[cell setSelectionStyle:1];
	}

    if (indexPath.section==0){
        if(indexPath.row==0){
			if(!vc.prefs.NameOrder){
				[cell setAccessoryType:3];
			}
			[cell setText:NSLocalizedString(@"Last, First",nil)];
		}else{
			if(vc.prefs.NameOrder){
				[cell setAccessoryType:3];
			}
			[cell setText:NSLocalizedString(@"First, Last",nil)];
		}
	}

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    if (indexPath.section==0){
        if(indexPath.row==0){
			vc.prefs.NameOrder=NO;
			[vc.labelNext setText:NSLocalizedString(@"Last, First",nil)];

		}else{
			vc.prefs.NameOrder=YES;
			[vc.labelNext setText:NSLocalizedString(@"First, Last",nil)];
		}
    }

	[vc.prefs savePrefs];

	[[self navigationController] popViewControllerAnimated:YES];
}

-(void)dealloc{
	[super dealloc];
}

@end
