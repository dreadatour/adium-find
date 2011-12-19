//
//  adium_findAppDelegate.m
//  adium-find
//
//  Created by Vladimir R on 10.12.11.
//  Copyright 2011 dreadatour@gmail.com. All rights reserved.
//

#import "adium_findAppDelegate.h"

@implementation adium_findAppDelegate

@synthesize window;
@synthesize windowPos;
@synthesize windowHeight;
@synthesize adiumContacts;
@synthesize searchResult;

- (void)dealloc {
    [adiumContacts release];
    [super dealloc];
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;    
}

- (NSTimeInterval)animationResizeTime:(NSRect)newFrame
{
    return 0.5;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    searchResult = [[adiumContact alloc] init];
    AdiumApplication *adiumApp = [SBApplication applicationWithBundleIdentifier:@"com.adiumX.adiumX"];
    if ([adiumApp isRunning]) {
        if ([[[adiumApp version] substringToIndex:3] floatValue] < 1.5) {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert addButtonWithTitle:@"OK"];
            [alert setMessageText:@"Warning"];
            [alert setInformativeText:[NSString stringWithFormat: @"Adium 1.5 or higher version needed.\nYou running Adium %@.", [adiumApp version]]];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert beginSheetModalForWindow:window
                              modalDelegate:self
                             didEndSelector:nil
                                contextInfo:nil];
            isOldVersion = true;
        } else {
            isOldVersion = false;
        }
        windowPos = [[NSNumber alloc] initWithFloat:[window frame].origin.y];
        windowHeight = [[NSNumber alloc] initWithFloat:[window frame].size.height];

        adiumContacts = [[NSMutableArray alloc] init];
        int adiumContactsCnt = 0;

        SBElementArray *accounts = [adiumApp accounts];
        if ([accounts count] > 0) {
            for (AdiumAccount *account in accounts) {
                if ([account enabled]) {
                    SBElementArray *contacts = [account contacts];
                    for (AdiumContact *contact in contacts) {
                        adiumContact *aContact = [[adiumContact alloc] init];
                        aContact.primaryKey = adiumContactsCnt++;
                        aContact.name = [[NSString alloc] initWithString:[contact name]];
                        aContact.displayName = [[NSString alloc] initWithString:[contact displayName]];
                        aContact.account = [[NSString alloc] initWithString:[account name]];
                        [adiumContacts addObject:aContact];
                    }
                }
            }
            [searchResults setStringValue:[NSString stringWithFormat:@"Contacts total: %d", [adiumContacts count]]];
        }
    } else {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Exit"];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:@"Adium is not running."];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:window
                          modalDelegate:self
                         didEndSelector:@selector(alertDidEnd:returnCode:contextInfo:)
                            contextInfo:nil];
    }
    [NSApp activateIgnoringOtherApps:YES];
}

- (void)alertDidEnd:(NSAlert *)alert returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo;
{
    [NSApp terminate: nil];
}

- (void)controlTextDidChange: (NSNotification *)aNotification
{
    NSString *searchString = [searchField stringValue];
    NSString *resultString = [[NSString alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(displayName CONTAINS[cd] %@) OR (name CONTAINS[cd] %@)", searchString, searchString];
    NSRect windowFrame = [window frame];

    searchResult = nil;
    if ([searchString length] > 0) {
        NSInteger found = 0;
        for (adiumContact *contact in [adiumContacts filteredArrayUsingPredicate:predicate]) {
            if (found == 0) {
                searchResult = contact;
            }
            if (found < 10) {
                resultString = [resultString stringByAppendingString:[NSString stringWithFormat:@"%@ <%@>\n", contact.displayName, contact.name]];
            }
            found++;
        }
        if (found == 0) {
            resultString = [NSString stringWithFormat:@"Nothing was found"];
            windowFrame.size.height = [windowHeight floatValue];
            windowFrame.origin.y = [windowPos floatValue];
        } else if (found <= 10) {
            windowFrame.size.height = [windowHeight floatValue] + 17 * (found - 1);
            windowFrame.origin.y = [windowPos floatValue] - 17 * (found - 1);
        } else if (found > 10) {
            resultString = [resultString stringByAppendingString:[NSString stringWithFormat:@"Contacts found: %d", found]];
            windowFrame.size.height = [windowHeight floatValue] + 170;
            windowFrame.origin.y = [windowPos floatValue] - 170;
        }
        [searchResults setStringValue:resultString];
        [window setFrame:windowFrame display:TRUE animate:TRUE];
    } else {
        [searchResults setStringValue:[NSString stringWithFormat:@"Contacts total: %d", [adiumContacts count]]];
        windowFrame.size.height = [windowHeight floatValue];
        windowFrame.origin.y = [windowPos floatValue];
        [window setFrame:windowFrame display:TRUE animate:TRUE];
    }
}

- (void)controlTextDidEndEditing:(NSNotification *)aNotification
{
    if (isOldVersion) {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"OK"];
        [alert setMessageText:@"Warning"];
        [alert setInformativeText:[NSString stringWithFormat: @"Sorry, your Adium not supports create new conversation."]];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:window
                          modalDelegate:self
                         didEndSelector:nil
                            contextInfo:nil];
    } else {
        if (searchResult.name != nil) {
            NSAppleScript *todo = [[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@""
            @"\ntell application \"Adium\""
            @"\n  set user to contact \"%@\" of account \"%@\""
            @"\n  if not (exists (chats whose contacts contains user)) then"
            @"\n    if not (exists (first chat window)) then"
            @"\n      tell account of user to (make new chat with contacts {user} with new chat window)"
            @"\n    else"
            @"\n      set existing_window to first chat window"
            @"\n      set existing_chat to last chat of existing_window"
            @"\n      tell account of user to (make new chat with contacts {user} at after existing_chat)"
            @"\n      tell last chat of existing_window to become active"
            @"\n    end if"
            @"\n  else"
            @"\n    tell chats whose contacts contains user to become active"
            @"\n  end if"
            @"\n  activate"
            @"\nend tell", searchResult.name, searchResult.account]];
            [todo executeAndReturnError:nil];
            [NSApp terminate: nil];
        }
    }
}

@end
