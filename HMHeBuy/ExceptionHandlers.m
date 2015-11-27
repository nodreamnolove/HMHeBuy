//
//  UncaughtExceptionHandler.m
//  UncaughtExceptions
//
//  异常捕捉函数
//

#import "ExceptionHandlers.h"
#import <libkern/OSAtomic.h>
#import <execinfo.h>

#import "SBJson.h"

NSString * const UncaughtExceptionHandlerSignalExceptionNames = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKeys = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKeys = @"UncaughtExceptionHandlerAddressesKey";

volatile int32_t UncaughtExceptionCounts = 0;
const int32_t UncaughtExceptionMaximums = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCounts = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCounts = 5;

NSMutableDictionary *dic;
@interface ExceptionHandlers()<UIAlertViewDelegate>

@end

@implementation ExceptionHandlers

+ (NSArray *)backtrace
{
	 void* callstack[128];
	 int frames = backtrace(callstack, 128);
	 char **strs = backtrace_symbols(callstack, frames);
	 
	 int i;
	 NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
	 for (
	 	i = UncaughtExceptionHandlerSkipAddressCounts;
	 	i < UncaughtExceptionHandlerSkipAddressCounts +
			UncaughtExceptionHandlerReportAddressCounts;
		i++)
	 {
	 	[backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
	 }
	 free(strs);
	 
	 return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
	if (anIndex == 0)
	{
		dismissed = YES;
        NSLog(@"click cancel");
	}
    else
        NSLog(@"click 确认");       
}

- (void)validateAndSaveCriticalApplicationData
{

        

  
}

- (void)handleException:(NSException *)exception
{
    
    dic=[NSMutableDictionary dictionary];
    dic[@"addDate"]=[NSDate date];
    dic[@"reason"]=[exception reason];
    dic[@"userInfo"]=[[exception userInfo] objectForKey:UncaughtExceptionHandlerAddressesKeys];
	[self validateAndSaveCriticalApplicationData];
   
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"duang..." message:@"小易遇到异常需要崩溃一下" delegate:self cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
    
    
 
    
	CFRunLoopRef runLoop = CFRunLoopGetCurrent();
	CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
	
	while (!dismissed)
	{
		for (NSString *mode in (__bridge NSArray*)allModes)
		{
			CFRunLoopRunInMode((CFStringRef)mode, 0.001, false);
		}
	}
	
	CFRelease(allModes);

	NSSetUncaughtExceptionHandler(NULL);
	signal(SIGABRT, SIG_DFL);
	signal(SIGILL, SIG_DFL);
	signal(SIGSEGV, SIG_DFL);
	signal(SIGFPE, SIG_DFL);
	signal(SIGBUS, SIG_DFL);
	signal(SIGPIPE, SIG_DFL);
	
	if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionNames])
	{
		kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKeys] intValue]);
	}
	else
	{
		[exception raise];
	}
}



@end

void HandleException(NSException *exception)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCounts);
	if (exceptionCount > UncaughtExceptionMaximums)
	{
		return;
	}
	
	NSArray *callStack = [ExceptionHandlers backtrace];
	NSMutableDictionary *userInfo =
		[NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
	[userInfo
		setObject:callStack
		forKey:UncaughtExceptionHandlerAddressesKeys];
	
	[[[ExceptionHandlers alloc] init]
		performSelectorOnMainThread:@selector(handleException:)
		withObject:
			[NSException
				exceptionWithName:[exception name]
				reason:[exception reason]
				userInfo:userInfo]
		waitUntilDone:YES];
}

void SignalHandler(int signal)
{
	int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCounts);
	if (exceptionCount > UncaughtExceptionMaximums)
	{
		return;
	}
	
	NSMutableDictionary *userInfo =
		[NSMutableDictionary
			dictionaryWithObject:[NSNumber numberWithInt:signal]
			forKey:UncaughtExceptionHandlerSignalKeys];

	NSArray *callStack = [ExceptionHandlers backtrace];
	[userInfo
		setObject:callStack
		forKey:UncaughtExceptionHandlerAddressesKeys];
	
	[[[ExceptionHandlers alloc] init]
		performSelectorOnMainThread:@selector(handleException:)
		withObject:
			[NSException
				exceptionWithName:UncaughtExceptionHandlerSignalExceptionNames
				reason:
					[NSString stringWithFormat:
						NSLocalizedString(@"Signal %d was raised.", nil),
						signal]
				userInfo:
					[NSDictionary
						dictionaryWithObject:[NSNumber numberWithInt:signal]
						forKey:UncaughtExceptionHandlerSignalKeys]]
		waitUntilDone:YES];
}







void InstallUncaughtExceptionHandler(void)
{
	NSSetUncaughtExceptionHandler(&HandleException);
	signal(SIGABRT, SignalHandler);//abort
	signal(SIGILL, SignalHandler);
	signal(SIGSEGV, SignalHandler);
	signal(SIGFPE, SignalHandler);
	signal(SIGBUS, SignalHandler);
	signal(SIGPIPE, SignalHandler);
}

