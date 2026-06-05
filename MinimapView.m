#import "MinimapView.h"

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
    self.playerDirection = direction;
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

- (void)updateWithPlayerX:(CGFloat)x y:(CGFloat)y direction:(CGFloat)direction monsters:(NSArray<NSValue *> *)monsters dungeons:(NSArray<NSValue *> *)dungeons {
    self.playerPosition = CGPointMake(x, y);
    self.playerDirection = direction;
    self.monsterPositions = monsters;
    self.dungeonRects = dungeons;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)refresh {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

@end
