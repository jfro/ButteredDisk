//
//  BDDiskArbitrationSession.m
//  ButteredDisk
//
//  Created by Jeremy Knope on 10/17/09.
//  Copyright 2009 Buttered Cat Software. All rights reserved.
//

#import "BDDiskArbitrationSession.h"
#import "BDDisk.h"

@implementation BDDiskArbitrationSession {
	DASessionRef _session;
    CFRunLoopRef _sessionRunLoop;
    __weak BDDiskArbitrationSession *_weakSelf; // used for the callbacks
}

void bcDiskAppeared(DADiskRef disk, void *context)
{
    BDDiskArbitrationSession *self = *(BDDiskArbitrationSession * __weak *)context;
    [self diskDidAppear:disk];
}

void bcDiskDisappeared(DADiskRef disk, void *context)
{
    BDDiskArbitrationSession *self = *(BDDiskArbitrationSession * __weak *)context;
	[self diskDidDisappear:disk];
}

- (id)initWithDelegate:(NSObject <BDDiskArbitrationSessionDelegate> *)newDelegate
{
	if((self = [super init]))
	{
		_delegate = newDelegate;
		_session = DASessionCreate(kCFAllocatorDefault);
        _sessionRunLoop = (CFRunLoopRef)CFRetain(CFRunLoopGetCurrent());
		DASessionScheduleWithRunLoop(_session, _sessionRunLoop, kCFRunLoopCommonModes);
        _weakSelf = self;
		[self watchDisks];
	}
	return self;
}

- (void)dealloc
{
	[self unwatchDisks];
	DASessionUnscheduleFromRunLoop(_session, _sessionRunLoop, kCFRunLoopCommonModes);
	CFRelease(_session);
    CFRelease(_sessionRunLoop);
}

- (void)watchDisks
{
	DARegisterDiskAppearedCallback(_session, NULL, bcDiskAppeared, (void *)(&_weakSelf));
	DARegisterDiskDisappearedCallback(_session, NULL, bcDiskDisappeared, (void *)(&_weakSelf));
    
	// TODO: add support for mount/unmount notifications (do we have to rely on NSWorkspace?)
//    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver:self selector:@selector(diskDidMount:) name:NSWorkspaceDidMountNotification object:nil];
    // currently don't care for unmounts
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(diskDidUnmount:) name:NSWorkspaceDidUnmountNotification object:nil];
}

- (void)unwatchDisks
{
	DAUnregisterCallback(_session, bcDiskAppeared, (void *)(&_weakSelf));
	DAUnregisterCallback(_session, bcDiskDisappeared, (void *)(&_weakSelf));
    
    [[[NSWorkspace sharedWorkspace] notificationCenter] removeObserver:self];
}

- (void)diskDidAppear:(DADiskRef)aDisk
{
    BDDisk *disk = [BDDisk diskWithRef:aDisk];
    id<BDDiskArbitrationSessionDelegate> delegate = self.delegate;
    if([delegate respondsToSelector:@selector(diskDidAppear:)]) {
        [delegate diskDidAppear:disk];
    }
}

- (void)diskDidDisappear:(DADiskRef)aDisk
{
    BDDisk *disk = [BDDisk diskWithRef:aDisk];
    id<BDDiskArbitrationSessionDelegate> delegate = self.delegate;
    if([delegate respondsToSelector:@selector(diskDidDisappear:)]) {
        [delegate diskDidDisappear:disk];
    }
}

//- (void)diskDidMount:(NSNotification *)note
//{
//    id<BDDiskArbitrationSessionDelegate> delegate = self.delegate;
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
        DADiskRef diskRef = DADiskCreateFromVolumePath(kCFAllocatorDefault, _session, (__bridge CFURLRef)url);
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
	DADiskRef diskRef = DADiskCreateFromBSDName(kCFAllocatorDefault, _session, [bsdName UTF8String]);
	if(diskRef) {
        BDDisk *disk = [BDDisk diskWithRef:diskRef];
        CFRelease(diskRef);
		return disk;
    }
		
	return nil;
}

@end
