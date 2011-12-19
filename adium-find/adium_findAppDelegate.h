//
//  adium_findAppDelegate.h
//  adium-find
//
//  Created by Vladimir R on 10.12.11.
//  Copyright 2011 dreadatour@gmail.com. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ScriptingBridge/SBApplication.h>
#import "adium_contact.h"
#import "Adium.h"

@interface adium_findAppDelegate: NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSNumber *windowPos;
    NSNumber *windowHeight;
    boolean_t isOldVersion;
    NSMutableArray *adiumContacts;
    adiumContact *searchResult;
    IBOutlet NSSearchField *searchField;
    IBOutlet NSTextField *searchResults;
}

@property (assign) IBOutlet NSWindow *window;
@property (retain) NSNumber *windowPos;
@property (retain) NSNumber *windowHeight;
@property (retain) NSMutableArray *adiumContacts;
@property (retain) adiumContact *searchResult;

@end
