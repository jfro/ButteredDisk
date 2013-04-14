//
//  BDDiskArbitrationSession.h
//  ButteredDisk
//
//  Created by Jeremy Knope on 10/17/09.
//  Copyright 2009 Buttered Cat Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DiskArbitration/DiskArbitration.h>
#import "BDDisk.h"

@protocol BDDiskArbitrationSessionDelegate

@optional
- (void)diskDidAppear:(BDDisk *)disk;
- (void)diskDidDisappear:(BDDisk *)disk;

@end


@interface BDDiskArbitrationSession : NSObject
{
	DASessionRef session;
	NSObject<BDDiskArbitrationSessionDelegate> *__unsafe_unretained delegate;
}

@property (unsafe_unretained) NSObject <BDDiskArbitrationSessionDelegate> *delegate;

- (id)initWithDelegate:(NSObject <BDDiskArbitrationSessionDelegate> *)newDelegate;

/**
 * Returns a disk object for a given device path
 */
- (BDDisk *)diskForBSDName:(NSString *)bsdName;

@end
