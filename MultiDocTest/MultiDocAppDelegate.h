//
//  MultiDocAppDelegate.h
//  MultiDocTest
//
//  Created by Cartwright Samuel on 3/14/13.
//  Copyright (c) 2013 Samuel Cartwright. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DocumentNeedWindowNotification @"TSDocumentNeedWindowNotification"

@interface MultiDocAppDelegate : NSObject <NSApplicationDelegate, NSOutlineViewDelegate, NSOutlineViewDataSource, NSMenuDelegate>

@end
