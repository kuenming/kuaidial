#import <UIKit/UIKit.h>
#import "KDPrefsApp.h"
#import "KDPrefsViewController.h"

@implementation KDPrefsApp

-(void)applicationDidFinishLaunching:(UIApplication *)application {

	navController = [[UINavigationController alloc] initWithRootViewController:[[[KDPrefsViewController alloc] initWithStyle:1] autorelease]];
	[[navController navigationBar] setBarStyle:1];

	window=[[UIWindow alloc] initWithContentRect:[[UIScreen mainScreen] bounds]];
	[window addSubview:[navController view]];
	[window makeKeyAndVisible];
}

-(void)dealloc{
	[navController release];
	[window release];
	[super dealloc];
}

@end

