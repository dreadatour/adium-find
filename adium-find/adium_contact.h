//
//  adium_contact.h
//  adium-find
//
//  Created by Vladimir Rudnyh on 12/13/11.
//  Copyright (c) 2011 dreadatour@gmail.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface adiumContact: NSObject {
    int primaryKey;
    NSString *name;
    NSString *displayName;
    NSString *account;
}

@property(nonatomic, assign) int primaryKey;
@property(nonatomic, retain) NSString *name;
@property(nonatomic, retain) NSString *displayName;
@property(nonatomic, retain) NSString *account;

@end
