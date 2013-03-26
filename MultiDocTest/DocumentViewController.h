//
//  DocumentViewController.h
//  MultiDocTest
//
//  Created by Cartwright Samuel on 3/14/13.
//  Copyright (c) 2013 Samuel Cartwright. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DocumentViewController : NSViewController {
@private
    NSDocument* _documnet;
}

@property (retain) NSDocument* document;

@end
