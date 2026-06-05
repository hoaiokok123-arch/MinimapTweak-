#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "MinimapView.h"

static MinimapView *g_minimap = nil;

// ============================================
// HÀM TIỆN ÍCH ĐỌC TỌA ĐỘ
// ============================================
static CGPoint ReadPositionFromObject(void *obj) {
    if (!obj) return CGPointZero;
    
    // Thử đọc qua selector getPosition nếu có
    if ([obj respondsToSelector:@selector(position)]) {
        CGPoint pos = [(id)obj position];
        return pos;
    }
    
    // Fallback: đọc từ memory offset (cần reverse để biết offset chính xác)
    // float x = *(float *)((uintptr_t)obj + 0x30);
    // float y = *(float *)((uintptr_t)obj + 0x34);
    
    return CGPointZero;
}

// ============================================
// TẠO MINIMAP
// ============================================
static void CreateMinimap() {
    if (g_minimap) return;
    
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                window = scene.windows.firstObject;
                break;
            }
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
        NSLog(@"[Minimap] ✅ Created minimap");
    }
}

// ============================================
// HOOK UPDATE - Cập nhật minimap mỗi frame
// ============================================
%hook NSObject

// Hook vào update method của game
- (void)Update {
    %orig;
    
    if (!g_minimap) {
        CreateMinimap();
        return;
    }
    
    // Tìm local player bằng cách duyệt các view
    UIWindow *window = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                window = scene.windows.firstObject;
                break;
            }
        }
    }
    if (!window) {
        window = [UIApplication sharedApplication].windows.firstObject;
    }
    
    // Cập nhật minimap với position tạm thời (sẽ thay bằng real position sau khi reverse)
    [g_minimap updatePlayerPosition:CGPointMake(500, 500) direction:0];
}

%end

// ============================================
// HOOK VÀO LOCAL PLAYER (nếu tìm thấy class)
// ============================================
%hook LocalPlayerCharacterView

- (void)Awake {
    %orig;
    NSLog(@"[Minimap] 👤 LocalPlayerCharacterView found: %@", self);
    CreateMinimap();
}

- (CGPoint)position {
    CGPoint pos = %orig;
    if (g_minimap) {
        [g_minimap updatePlayerPosition:pos direction:0];
    }
    return pos;
}

%end

// ============================================
// HOOK VÀO MOB VIEW
// ============================================
%hook MobView

- (void)Awake {
    %orig;
    NSLog(@"[Minimap] 👾 MobView found: %@", self);
}

- (CGPoint)position {
    CGPoint pos = %orig;
    if (g_minimap && pos.x > 0 && pos.y > 0) {
        [g_minimap updateMonsters:@[[NSValue valueWithCGPoint:pos]]];
    }
    return pos;
}

%end

// ============================================
// HOOK VAO MINIMAP PREVIEW
// ============================================
%hook MiniMapPreview

- (void)Start {
    %orig;
    NSLog(@"[Minimap] 🗺️ MiniMapPreview started");
    CreateMinimap();
}

%end

// ============================================
// CONSTRUCTOR
// ============================================
%ctor {
    NSLog(@"[Minimap] 🚀 Minimap Tweak v1.0.0 LOADED");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CreateMinimap();
    });
}
