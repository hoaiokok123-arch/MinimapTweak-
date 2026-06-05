#import <UIKit/UIKit.h>

// ============================================
// MINIMAP VIEW CLASS (gộp luôn vào đây)
// ============================================
@interface MinimapView : UIView
@property (nonatomic, assign) CGPoint playerPosition;
@property (nonatomic, strong) NSArray<NSValue *> *monsterPositions;
- (void)updatePlayerPosition:(CGPoint)position direction:(CGFloat)direction;
- (void)updateMonsters:(NSArray<NSValue *> *)monsters;
@end

@implementation MinimapView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.layer.cornerRadius = 10;
        self.layer.borderWidth = 1;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.userInteractionEnabled = NO;
        self.playerPosition = CGPointMake(50, 50);
        self.monsterPositions = @[];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;
    
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    
    // Vẽ player (xanh)
    CGContextSetFillColorWithColor(context, [UIColor blueColor].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(w/2 - 5, h/2 - 5, 10, 10));
    
    // Vẽ monster (đỏ)
    for (NSValue *val in self.monsterPositions) {
        CGPoint pos = [val CGPointValue];
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        CGContextFillEllipseInRect(context, CGRectMake(pos.x, pos.y, 6, 6));
    }
    
    // Label
    NSDictionary *attrs = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:8], NSForegroundColorAttributeName: [UIColor whiteColor]};
    [@"MINIMAP" drawInRect:CGRectMake(4, 4, 50, 10) withAttributes:attrs];
}

- (void)updatePlayerPosition:(CGPoint)position direction:(CGFloat)direction {
    self.playerPosition = position;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)updateMonsters:(NSArray<NSValue *> *)monsters {
    self.monsterPositions = monsters;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

@end

// ============================================
// TWEAK MAIN
// ============================================
static MinimapView *g_minimap = nil;

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
        CGRect frame = CGRectMake(window.bounds.size.width - 130, 60, 120, 120);
        g_minimap = [[MinimapView alloc] initWithFrame:frame];
        g_minimap.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        [window addSubview:g_minimap];
        NSLog(@"[Minimap] Created!");
    }
}

%hook UIViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CreateMinimap();
    });
}

%end

%ctor {
    NSLog(@"[Minimap] Tweak loaded!");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        CreateMinimap();
    });
}
