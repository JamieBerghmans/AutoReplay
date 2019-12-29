typedef struct { 
	long long value;
	int timescale;
	unsigned int flags;
	long long epoch;
	} TIME;

@interface PUBrowsingVideoPlayer
-(void)videoSessionDidPlayToEnd:(id)arg1; //IOS12
-(void)avPlayer:(id)arg1 itemDidPlayToEnd:(id)arg2; //IOS13
-(void)seekToTime:(TIME)arg1 toleranceBefore:(TIME)arg2 toleranceAfter:(TIME)arg3 completionHandler:(id)arg4;
-(void)seekToTime:(TIME)arg1 completionHandler:(id)arg2;
-(TIME)currentTime;
-(void)_updateVideoSessionDesiredPlayState;
-(void)rewindExistingPlayer;
@property(nonatomic) long long desiredPlayState;
@end





%group IOS12
%hook PUBrowsingVideoPlayer

- (void)avPlayer:(id)arg1 itemDidPlayToEnd:(id)arg2 {
	// %orig (arg1, arg2);
	NSLog(@"AutoReplay - Ended 12");

	TIME t = [self currentTime];
	t.value = (long long) 0;
	t.timescale = 100;
	t.flags = (unsigned int) 1;

	[self seekToTime:t toleranceBefore:t toleranceAfter:t completionHandler:NULL];
}

%end
%end //end group IOS12





%group IOS13
%hook PUBrowsingVideoPlayer

static bool isFirstTryAfterEnding = false;

- (void)videoSessionDidPlayToEnd:(id)arg1 {
	isFirstTryAfterEnding = true;
	[self rewindExistingPlayer];
}

- (void)_updateVideoSessionDesiredPlayState {
	if (self.desiredPlayState == 0 && isFirstTryAfterEnding) {
		isFirstTryAfterEnding = false;
		MSHookIvar<long long>(self, "_desiredPlayState") = 1;
	}

	%orig;
}
%end
%end //end group IOS13





%ctor {
	float version = [[[UIDevice currentDevice] systemVersion] floatValue];
	NSLog(@"AUTOREPLAY - Version: %f", version);
	if (version < 13) {
		%init(IOS12);
	} else {
		%init(IOS13);
	}
}