#import <UIKit/UIKit.h>
#import "MinimapView.h"

static MinimapView *g_minimap = nil;
static NSTimer *g_minimapTimer = nil;

static void CreateMinimap() {
    if (g_minimap) return;
    
    UIWindow *window = nil;
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
        CGRect frame = CGRectMake(window.bounds.size.width - 140, 50, 120, 120);
        g_minimap = [[MinimapView alloc] initWithFrame:frame];
        g_minimap.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        [window addSubview:g_minimap];
        NSLog(@"[MinimapTweak] Đã tạo khung Minimap!");

        // Khởi tạo Timer để liên tục cập nhật và vẽ lại dữ liệu (Mỗi 0.1 giây)
        g_minimapTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (g_minimap) {
                // CHẠY THỬ NGHIỆM: Giả lập tọa độ di chuyển xoay tròn để xem Minimap hoạt động vẽ
                static CGFloat angle = 0;
                angle += 0.05;
                
                // Giả lập vị trí 2 con quái vật xung quanh người chơi (tọa độ tương đối trong khung 120x120)
                CGPoint monster1 = CGPointMake(60 + 30 * cos(angle), 60 + 30 * sin(angle));
                CGPoint monster2 = CGPointMake(40, 80);
                
                NSArray *monsters = @[
                    [NSValue valueWithCGPoint:monster1],
                    [NSValue valueWithCGPoint:monster2]
                ];
                
                // Truyền dữ liệu sang để MinimapView vẽ lên màn hình
                [g_minimap updateWithPlayerX:60 
                                           y:60 
                                   direction:angle 
                                    monsters:monsters 
                                    dungeons:@[]];
            }
        }];
    }
}

%hook UIViewController
- (void)viewDidAppear:(BOOL)animated {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Chờ 2 giây sau khi view xuất hiện. Đã sửa sang chuẩn int64_t
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CreateMinimap();
        });
    });
}
%end
