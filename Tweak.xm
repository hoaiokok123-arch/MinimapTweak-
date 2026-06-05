#import <UIKit/UIKit.h>
#import "MinimapView.h"

static MinimapView *g_minimap = nil;

// Hàm tạo minimap
static void CreateMinimap() {
    if (g_minimap) return;
    
    UIWindow *window = nil;
    // Lấy window cho iOS 13+
    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            window = scene.windows.firstObject;
            break;
        }
    }
    if (!window) {
        window = [UIApplication sharedApplication].windows.firstObject;
    }
    
    if (window) {
        CGRect frame = CGRectMake(window.bounds.size.width - 130, 60, 120, 120);
        g_minimap = [[MinimapView alloc] initWithFrame:frame];
        g_minimap.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [window addSubview:g_minimap];
        NSLog(@"[Minimap] Created!");
    }
}

// Hook vào Update của UIViewController
%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CreateMinimap();
    });
}

%end

// Hook vào UIView để cập nhật minimap
%hook UIView

- (void)didMoveToWindow {
    %orig;
    if (self.window && !g_minimap) {
        CreateMinimap();
    }
}

%end

// Constructor
%ctor {
    NSLog(@"[Minimap] Tweak loaded!");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CreateMinimap();
    });
}
