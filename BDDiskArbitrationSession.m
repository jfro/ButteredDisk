//
//  BDDiskArbitrationSession.m
//  ButteredDisk
//
//  Created by Jeremy Knope on 10/17/09.
//  Copyright 2009 Buttered Cat Software. All rights reserved.
//

#import "BDDiskArbitrationSession.h"

@interface BDDiskArbitrationSession(Private)
- (void)diskDidAppear:(DADiskRef)aDisk;
- (void)diskDidDisappear:(DADiskRef)aDisk;
- (void)diskDidMount:(DADiskRef)aDisk;
- (void)diskDidUnmount:(DADiskRef)aDisk;
- (void)watchDisks;
- (void)unwatchDisks;
@end


void bcDiskAppeared(DADiskRef disk, void *context)
{
	[(__bridge BDDiskArbitrationSession *)context diskDidAppear:disk];
}

void bcDiskDisappeared(DADiskRef disk, void *context)
{
	[(__bridge BDDiskArbitrationSession *)context diskDidDisappear:disk];
}

@implementation BDDiskArbitrationSession

@synthesize delegate;

- (id)initWithDelegate:(NSObject <BDDiskArbitrationSessionDelegate> *)newDelegate
{
	if((self = [super init]))
	{
		self.delegate = newDelegate;
		session = DASessionCreate(kCFAllocatorDefault);
		DASessionScheduleWithRunLoop(session, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
		[self watchDisks];
	}
	return self;
}

- (void)dealloc
{
	[self unwatchDisks];
	
	CFRelease(session);
	session = nil;
}

- (void)watchDisks
{
	DARegisterDiskAppearedCallback(session, NULL, bcDiskAppeared, (__bridge void *)(self));
	DARegisterDiskDisappearedCallback(session, NULL, bcDiskDisappeared, (__bridge void *)(self));
    
	// TODO: add support for mount/unmount notifications (do we have to rely on NSWorkspace?)
//    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(diskDidMount:) name:NSWorkspaceDidMountNotification object:nil];
    // currently don't care for unmounts
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(diskDidUnmount:) name:NSWorkspaceDidUnmountNotification object:nil];
}

- (void)unwatchDisks
{
	DAUnregisterCallback(session, bcDiskAppeared, (__bridge void *)(self));
	DAUnregisterCallback(session, bcDiskDisappeared, (__bridge void *)(self));
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (void)diskDidAppear:(DADiskRef)aDisk
{
    BDDisk *disk = [BDDisk diskWithRef:aDisk];
    if([delegate respondsToSelector:@selector(diskDidAppear:)])
        [delegate diskDidAppear:disk];
}

- (void)diskDidDisappear:(DADiskRef)aDisk
{
    BDDisk *disk = [BDDisk diskWithRef:aDisk];
    if([delegate respondsToSelector:@selector(diskDidDisappear:)])
        [delegate diskDidDisappear:disk];
}

//- (void)diskDidMount:(NSNotification *)note
//{
//    if([delegate respondsToSelector:@selector(diskDidDisappear:)])
//        [delegate diskDidAppear:[self diskForVolumeURL:[[note userInfo] objectForKey:NSWorkspaceVolumeURLKey]]];
//}

// we currently don't care if it unmounts, only if the disk goes away. unmounting a known OS volume, we can still boot via device path
//- (void)diskDidUnmount:(NSNotification *)note
//{
//}

#pragma mark -

- (BDDisk *)diskForVolumeURL:(NSURL *)url
{
    if(url) {
        DADiskRef diskRef = DADiskCreateFromVolumePath(kCFAllocatorDefault, session, (__bridge CFURLRef)url);
        if(diskRef) {
            BDDisk *disk = [BDDisk diskWithRef:diskRef];
            CFRelease(diskRef);
            return disk;
        }
    }
	return nil;
}

- (BDDisk *)diskForBSDName:(NSString *)bsdName
{
	DADiskRef diskRef = DADiskCreateFromBSDName(kCFAllocatorDefault, session, [bsdName UTF8String]);
	if(diskRef) {
        BDDisk *disk = [BDDisk diskWithRef:diskRef];
        CFRelease(diskRef);
		return disk;
    }
		
	return nil;
}

@end
