//
//  BDDisk.h
//  ButteredDisk
//
//  Created by Jeremy Knope on 10/17/09.
//  Copyright 2009 Buttered Cat Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <DiskArbitration/DiskArbitration.h>

typedef void(^BCDiskDidMountBlock)(NSURL *mountURL, NSError *error);
typedef void(^BCDiskDidUnmountBlock)(NSError *error);

@interface BDDisk : NSObject
{
	NSDictionary *info;
	DADiskRef diskRef;
	NSImage *icon;
}

@property (weak, readonly) NSImage *icon;
@property (readonly) BOOL isCurrentSystem;
@property (readonly) BOOL isRemovable;
@property (readonly) BOOL isDiskImage;
@property (readonly) NSString *mediaName;
@property (readonly) NSString *realDevicePath;
@property (readonly) BOOL isWholeDisk;
@property (readonly) BOOL isMountable;
@property (readonly) BOOL isMounted;
@property (readonly) BOOL isNetwork;

@property (readonly) NSDictionary *diskDescription;
@property (readonly) NSString *BSDName;
@property (readonly) NSString *devicePath;
@property (readonly) NSString *volumeName;
@property (readonly) NSURL *volumeURL;
@property (readonly) NSString *volumePath;
@property (readonly) NSString *filesystem;
@property (readonly) NSString *volumeUUIDString;
@property (readonly) NSInteger mediaSize;

+ (BDDisk *)diskWithRef:(DADiskRef)disk;
- (id)initWithDiskRef:(DADiskRef)disk;

/*
 * Mounts the volume, or all volumes if it's a whole disk
 */
- (void)mountWithCompletionHandler:(BCDiskDidMountBlock)handler;
- (void)unmountWithCompletionHandler:(BCDiskDidUnmountBlock)handler;

@end