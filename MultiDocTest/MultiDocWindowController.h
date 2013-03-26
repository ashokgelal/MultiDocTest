//
//  MultiDocWindowController.h
//  MultiDocTest
//
//  Created by Cartwright Samuel on 3/14/13.
//  Copyright (c) 2013 Samuel Cartwright. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <PSMTabBarControl/PSMTabBarControl.h>

@interface MultiDocWindowController : NSWindowController <NSWindowDelegate, PSMTabBarControlDelegate> {
    IBOutlet NSTabView				*tabView;
	IBOutlet PSMTabBarControl		*tabBar;    
}

- (PSMTabBarControl *)tabBar;

-(void)addDocument:(NSDocument *)docToAdd;
-(void)removeDocument:(NSDocument *)docToRemove;

@end
