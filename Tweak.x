#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "MinimapView.h"

static MinimapView *g_minimap = nil;
static void *g_localPlayer = nil;

// ============================================
// OFFSETS TỪ DUMP.CS (đã xác định)
// ============================================
// Transform localPlayer offset: 0x20
// WorldStateManager.get_Instance RVA: 0x246309C
// GetPosition RVA: 0x1EB91C4, 0x20F011C
// Update RVA: 0x1D3CF38
// ConfigureAsLocalPlayer RVA: 0x2564608

// ============================================
// HÀM TIỆN ÍCH ĐỌC TỌA ĐỘ
// ============================================
static CGPoint ReadVector3Position(void *vector3Ptr) {
    if (!vector3Ptr) return CGPointZero;
    float x = *(float *)((uintptr_t)vector3Ptr + 0);
    float y = *(float *)((uintptr_t)vector3Ptr + 4);
    float z = *(float *)((uintptr_t)vector3Ptr + 8);
    return CGPointMake(x, z); // Trong game thường x,z là x,y trên map
}

// ============================================
// TÌM LOCAL PLAYER
// ============================================
static void *FindLocalPlayer() {
    // Cách 1: Tìm qua WorldStateManager (RVA: 0x246309C)
    // Địa chỉ này cần được tính toán runtime
    // void *(*getWorldStateManager)() = (void *(*)())0x246309C;
    // void *worldStateManager = getWorldStateManager();
    
    // Cách 2: Tìm qua Transform localPlayer (offset 0x20 từ camera hoặc manager)
    // Tạm thời dùng cách tìm object theo tag
    // TODO: Cần hook vào game để lấy chính xác
    
    return NULL;
}

// ============================================
// HOOK UPDATE - Cập nhật minimap mỗi frame
// ============================================
%hook SomeUpdateClass

- (void)Update {
    %orig;
    
    if (!g_minimap) {
        // Tạo minimap nếu chưa có
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (keyWindow) {
            CGRect frame = CGRectMake(keyWindow.bounds.size.width - 130, 60, 120, 120);
            g_minimap = [[MinimapView alloc] initWithFrame:frame];
            g_minimap.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [keyWindow addSubview:g_minimap];
        }
    }
    
    if (g_minimap && g_localPlayer) {
        // Đọc position từ local player transform
        CGPoint pos = ReadVector3Position(g_localPlayer);
        
        // TODO: Lấy danh sách monster từ game
        // Tạm thời để rỗng
        NSMutableArray *monsters = [NSMutableArray array];
        
        // TODO: Lấy dungeon bounds từ game
        NSMutableArray *dungeons = [NSMutableArray array];
        
        [g_minimap updateWithPlayerX:pos.x y:pos.y direction:0 monsters:monsters dungeons:dungeons];
    }
}

%end

// ============================================
// HOOK VÀO MONSTER VIEW ĐỂ LẤY VỊ TRÍ
// ============================================
%hook MobView

- (void)Update {
    %orig;
    
    if (!g_minimap) return;
    
    // Lấy vị trí của monster này
    // Vector3 pos = [self GetPosition]; // RVA: 0x1EB91C4
    // Thêm vào danh sách monster để vẽ trên minimap
}

%end

// ============================================
// HOOK VÀO LOCAL PLAYER CHARACTER VIEW
// ============================================
%hook LocalPlayerCharacterView

- (void)Awake {
    %orig;
    g_localPlayer = self;
    NSLog(@"[Minimap] LocalPlayer found: %p", g_localPlayer);
}

- (Vector3)GetPosition {
    Vector3 pos = %orig;
    if (g_minimap) {
        CGPoint cgPos = CGPointMake(pos.x, pos.z);
        [g_minimap updatePlayerPosition:cgPos direction:0];
    }
    return pos;
}

%end

// ============================================
// HOOK VAO MINIMAP PREVIEW DE HIEN THI
// ============================================
%hook MiniMapPreview

- (void)Start {
    %orig;
    // Bật minimap nếu game đang tắt
    // self.VisibleOnMinimap = YES; // offset 0x25
    NSLog(@"[Minimap] MiniMapPreview started");
}

%end

// ============================================
// CONSTRUCTOR - KHỞI TẠO TWEAK
// ============================================
%ctor {
    NSLog(@"[Minimap] Tweak loaded - v1.0.0");
    
    // Delay để game load xong
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (keyWindow && !g_minimap) {
            CGRect frame = CGRectMake(keyWindow.bounds.size.width - 130, 60, 120, 120);
            g_minimap = [[MinimapView alloc] initWithFrame:frame];
            g_minimap.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
            [keyWindow addSubview:g_minimap];
            NSLog(@"[Minimap] Minimap view added to window");
        }
    });
}