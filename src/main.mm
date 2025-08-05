#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>
#include "GeminiAPI.h"
#include "Dotenv.h"
#include <vector>
#include <iostream>

@interface OverlayWindow : NSWindow
@end

@implementation OverlayWindow
- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSWindowStyleMask)style backing:(NSBackingStoreType)backingStoreType defer:(BOOL)flag {
    self = [super initWithContentRect:contentRect styleMask:NSWindowStyleMaskBorderless backing:backingStoreType defer:flag];
    if (self) {
        [self setOpaque:NO];
        [self setBackgroundColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];
        [self setLevel:NSFloatingWindowLevel];
        [self setIgnoresMouseEvents:YES];
        [self setAlphaValue:0.5];
        [self setCollectionBehavior:NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorStationary | NSWindowCollectionBehaviorIgnoresCycle];
        
        // This is the important part for avoiding screen capture
        [self setSharingType:NSWindowSharingNone];
    }
    return self;
}
@end

@interface AppDelegate : NSObject <NSApplicationDelegate>
@property (nonatomic, strong) NSWindow *window;
@property (nonatomic, strong) NSTextView *textView;
@property (nonatomic, assign) GeminiAPI *geminiAPI;
@end

@implementation AppDelegate
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    auto env = Dotenv::load(".env");
    std::string apiKey;
    if (env.count("GEMINI_API_KEY")) {
        apiKey = env["GEMINI_API_KEY"];
    } else {
        std::cerr << "GEMINI_API_KEY not found in .env file" << std::endl;
        // Handle error appropriately, maybe exit or show an alert
    }

    self.geminiAPI = new GeminiAPI(apiKey);

    NSLog(@"Application finished launching. Creating window.");
    NSRect screenRect = [[NSScreen mainScreen] frame];
    self.window = [[OverlayWindow alloc] initWithContentRect:screenRect styleMask:NSWindowStyleMaskBorderless backing:NSBackingStoreBuffered defer:NO];
    
    self.textView = [[NSTextView alloc] initWithFrame:self.window.contentView.bounds];
    [self.textView setString:@"Hello from Prometheus!"];
    [self.textView setEditable:NO];
    [self.textView setDrawsBackground:NO];
    [self.textView setTextColor:[NSColor yellowColor]];
    [self.textView setFont:[NSFont systemFontOfSize:24.0]];
    [self.textView setAlignment:NSTextAlignmentCenter];
    [self.textView.textContainer setLineFragmentPadding:0];
    [self.textView setTextContainerInset:NSMakeSize(0, (screenRect.size.height - 24.0) / 2.0)];
    
    [self.window.contentView addSubview:self.textView];
    [self.window makeKeyAndOrderFront:nil];

    [NSTimer scheduledTimerWithTimeInterval:5.0
                                     target:self
                                   selector:@selector(captureAndProcessScreen)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)captureAndProcessScreen {
    NSLog(@"Capturing screen...");
    CGImageRef screenShot = CGDisplayCreateImage(kCGDirectMainDisplay);
    if (!screenShot) {
        NSLog(@"Failed to capture screen.");
        return;
    }

    NSBitmapImageRep *bitmapRep = [[NSBitmapImageRep alloc] initWithCGImage:screenShot];
    NSData *imageData = [bitmapRep representationUsingType:NSJPEGFileType properties:@{}];
    CGImageRelease(screenShot);

    if (!imageData) {
        NSLog(@"Failed to convert image to data.");
        return;
    }

    std::vector<char> imageVec(
        (const char*)[imageData bytes],
        (const char*)[imageData bytes] + [imageData length]
    );

    std::string response = self.geminiAPI->processImage(imageVec);
    NSString* nsResponse = [NSString stringWithUTF8String:response.c_str()];

    dispatch_async(dispatch_get_main_queue(), ^{
        [self.textView setString:nsResponse];
    });
}

- (void)dealloc {
    delete self.geminiAPI;
    [super dealloc];
}
@end

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSApplication *application = [NSApplication sharedApplication];
        AppDelegate *appDelegate = [[AppDelegate alloc] init];
        [application setDelegate:appDelegate];
        [application run];
    }
    return 0;
}
