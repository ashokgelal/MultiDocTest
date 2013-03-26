//
//  MultiDocWindowController.m
//  MultiDocTest
//
//  Created by Cartwright Samuel on 3/14/13.
//  Copyright (c) 2013 Samuel Cartwright. All rights reserved.
//

#import "MultiDocWindowController.h"
#import "Document.h"

@interface MultiDocWindowController () 

@property (nonatomic,strong,readonly) NSMutableSet* documents;
@property (nonatomic,strong,readonly) NSMutableSet* contentViewControllers;

@end

@implementation MultiDocWindowController

@synthesize documents = _documents;
@synthesize contentViewControllers = _contentViewControllers;

-(NSMutableSet *)documents {
    if (!_documents) {
        _documents = [[NSMutableSet alloc] initWithCapacity:3];
    }
    return _documents;
}

-(NSMutableSet *)contentViewControllers {
    if (!_contentViewControllers) {
        _contentViewControllers = [[NSMutableSet alloc] initWithCapacity:3];
    }
    return _contentViewControllers;    
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    [tabBar setHideForSingleTab:NO];
    [tabBar setSizeCellsToFit:YES];
    [tabBar setAllowsResizing:YES];
    [tabBar setAlwaysShowActiveTab:YES];
        
    // add views for any documents that were added before the window was created
    for(NSDocument* document in self.documents) {
        [self addViewWithDocument:document];
    }
}

-(void)addViewWithDocument:(NSDocument*) document {
    
    if ([document respondsToSelector:@selector(newPrimaryViewController)]) {
        NSViewController* addedCtrl = [(id)document newPrimaryViewController];
        [self.contentViewControllers addObject: addedCtrl];
        
        NSTabViewItem* tabViewItem = [[[NSTabViewItem alloc]initWithIdentifier: addedCtrl] autorelease];
        [tabViewItem setView: addedCtrl.view];
        [tabViewItem setLabel: [document displayName]];
        
        NSUInteger tabIndex = [tabView numberOfTabViewItems];
        [tabView insertTabViewItem:tabViewItem atIndex:tabIndex];
        [tabView selectTabViewItem: tabViewItem];
        
        [document setWindow: self.window];
    }
    
    [document addWindowController:self];
}

-(void)addDocument:(NSDocument *)docToAdd
{
    NSMutableSet* documents = self.documents;
    if ([documents containsObject:docToAdd]) {
        return;
    }
    
    [documents addObject:docToAdd];

    // check if the window has been created. We can not insert new tab
    // items until the nib has been loaded. So if the window isnt created
    // yet, do nothing and instead add the view controls during the
    // windowDidLoad function
    
    if(self.isWindowLoaded) {
        [self addViewWithDocument:docToAdd];
    }
}

-(void)removeDocument:(NSDocument *)docToRemove attachedToViewController:(NSViewController*)ctrl
{
    NSMutableSet* documents = self.documents;
    if (![documents containsObject:docToRemove]) {
        return;
    }
    
    // remove the document's view controller and view
    [ctrl.view removeFromSuperview];
    if ([ctrl respondsToSelector:@selector(setDocument:)]) {
        [(id)ctrl setDocument: nil];
    }
    [ctrl release];
    
        // remove the view from the tab item
        // dont remove the tab view item from the tab view, as this is handled by the framework (when
        // we click on the close button on the tab) - of course it wouldnt be if you closed the document
        // using the menu (TODO)
    NSTabViewItem* tabViewItem = [tabView tabViewItemAtIndex: [tabView indexOfTabViewItemWithIdentifier: ctrl]];
    [tabViewItem setView: nil];
    
        // remove the control from the view controllers set
    [self.contentViewControllers removeObject: ctrl];
    
    // finally detach the document from the window controller
    [docToRemove removeWindowController:self];
    [documents removeObject:docToRemove];
}

-(void)setDocument:(NSDocument *)document
{
    // NSLog(@"Will not set document to: %@",document);
}

- (BOOL)tabView:(NSTabView *)aTabView shouldCloseTabViewItem:(NSTabViewItem *)tabViewItem {
    return TRUE;
}

- (void)tabView:(NSTabView *)aTabView willCloseTabViewItem:(NSTabViewItem *)tabViewItem {
    NSLog(@"Will Close Tab View Item");
    
    // identifier is wrong now
    NSViewController* ctrl = (NSViewController*)[[tabView selectedTabViewItem] identifier];
    
    if ([ctrl respondsToSelector:@selector(document)]) {
        NSDocument* doc = [(id) ctrl document];
        [self removeDocument:doc attachedToViewController:ctrl];
    }
}

- (void)tabView:(NSTabView *)aTabView didCloseTabViewItem:(NSTabViewItem *)tabViewItem {
    NSLog(@"Did Close Tab View Item");    
}

- (void)tabView:(NSTabView *)aTabView didDetachTabViewItem:(NSTabViewItem *)tabViewItem {
    NSLog(@"Did Detach Tab View Item");    
}

-(NSDocument*)document
{
    NSTabViewItem *tabViewItem = [tabView selectedTabViewItem];
    NSViewController* ctrl = (NSViewController*)tabViewItem.identifier;
    
    if ([ctrl respondsToSelector:@selector(document)]) {
        return [(id) ctrl document];
    }
    return nil;
}

// Each document needs to be detached from the window controller before the window closes.
// In addition, any references to those documents from any child view controllers will also
// need to be cleared in order to ensure a proper cleanup.
// The windowWillClose: method does just that. One caveat found during debugging was that the
// window controller’s self pointer may become invalidated at any time within the method as
// soon as nothing else refers to it (using ARC). Since we’re disconnecting references to
// documents, there have been cases where the window controller got deallocated mid-way of
// cleanup. To prevent that, I’ve added a strong pointer to self and use that pointer exclusively
// in the windowWillClose: method.
-(void) windowWillClose:(NSNotification *)notification
{
    NSWindow * window = self.window;
    if (notification.object != window) {
        return;
    }
    
    // let's keep a reference to ourself and not have us thrown away while we clear out references.
    MultiDocWindowController* me = self;

    // detach the view controllers from the document first
    for (NSViewController* ctrl in me.contentViewControllers) {
        [ctrl.view removeFromSuperview];
        if ([ctrl respondsToSelector:@selector(setDocument:)]) {
            [(id) ctrl setDocument:nil];
            [ctrl release];
        }
    }
    
    // then any content view
    [window setContentView:nil];
    [me.contentViewControllers removeAllObjects];
       
    // disassociate this window controller from the document
    for (NSDocument* doc in me.documents) {
        [doc removeWindowController:me];
    }
    [me.documents removeAllObjects];
}

@end
