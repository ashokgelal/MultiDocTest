//
//  MultiDocAppDelegate.m
//  MultiDocTest
//
//  Created by Cartwright Samuel on 3/14/13.
//  Copyright (c) 2013 Samuel Cartwright. All rights reserved.
//

#import "MultiDocAppDelegate.h"
#import "Document.h"
#import "MultiDocWindowController.h"
#import "MultiDocDocumentController.h"

@interface MultiDocAppDelegate()

@property (strong, nonatomic) NSViewController* currentContentViewController;
@property (strong, nonatomic) NSWindowController* mainWindowController;

@end


@implementation MultiDocAppDelegate

@synthesize currentContentViewController = _currentContentViewController;

-(void)applicationWillFinishLaunching:(NSNotification *)notification
{    
    NSNotificationCenter* nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(handleDocumentNeedWindowNotification:) name:DocumentNeedWindowNotification object:nil];
    
}

-(void)handleDocumentNeedWindowNotification:(NSNotification *)notification
{
    Document* doc = notification.object;
    [(MultiDocWindowController*)self.mainWindowController addDocument:doc];
    [self.mainWindowController.window makeKeyAndOrderFront:doc];
}

-(NSWindowController *)mainWindowController
{
    if (!_mainWindowController) {
//        _mainWindowController = [MultiDocWindowController new];
        _mainWindowController = [[MultiDocWindowController alloc] initWithWindowNibName:@"Window"];
    }
    return _mainWindowController;
}

@end
