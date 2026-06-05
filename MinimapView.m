#import "MinimapView.h"

@implementation MinimapView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        self.layer.cornerRadius = 10;
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor whiteColor].CGColor;
        self.userInteractionEnabled = NO;
        self.playerPosition = CGPointMake(frame.size.width / 2, frame.size.height / 2);
        self.monsterPositions = @[];
        self.dungeonRects = @[];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;
    
    CGFloat w = rect.size.width;
    CGFloat h = rect.size.height;
    
    // 1. Vẽ Quái vật (Màu Đỏ)
    for (NSValue *val in self.monsterPositions) {
        CGPoint pos = [val CGPointValue];
        // Chỉ vẽ nếu tọa độ nằm trong khung hiển thị của Minimap
        if (pos.x >= 0 && pos.x <= w && pos.y >= 0 && pos.y <= h) {
            CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
            CGContextFillEllipseInRect(context, CGRectMake(pos.x - 3, pos.y - 3, 6, 6));
        }
    }
    
    // 2. Vẽ Người chơi (Xanh Dương) ở chính giữa tâm Minimap
    CGContextSetFillColorWithColor(context, [UIColor systemBlueColor].CGColor);
    CGContextFillEllipseInRect(context, CGRectMake(w/2 - 5, h/2 - 5, 10, 10));
    
    // Vẽ hướng nhìn của người chơi dựa trên biến playerDirection
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    CGContextMoveToPoint(context, w/2, h/2);
    CGFloat targetX = w/2 + 15 * cos(self.playerDirection);
    CGFloat targetY = h/2 + 15 * sin(self.playerDirection);
    CGContextAddLineToPoint(context, targetX, targetY);
    CGContextStrokePath(context);
    
    // 3. Chữ hiển thị
    NSDictionary *attrs = @{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:9],
        NSForegroundColorAttributeName: [UIColor greenColor]
    };
    [@"MINIMAP RUNNING" drawInRect:CGRectMake(6, 4, 100, 12) withAttributes:attrs];
}

- (void)updateWithPlayerX:(CGFloat)x y:(CGFloat)y direction:(CGFloat)direction monsters:(NSArray *)monsters dungeons:(NSArray *)dungeons {
    self.playerDirection = direction;
    self.monsterPositions = monsters;
    self.dungeonRects = dungeons;
    [self refresh];
}

- (void)refresh {
    if ([NSThread isMainThread]) {
        [self setNeedsDisplay];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsDisplay];
        });
    }
}
@end
