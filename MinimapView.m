#import "MinimapView.h"

@implementation MinimapView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.5;
        self.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.6].CGColor;
        self.userInteractionEnabled = NO;
        self.monsterPositions = @[];
        self.dungeonRects = @[];
    }
    return self;
}

- (void)updateWithPlayerX:(CGFloat)x 
                         y:(CGFloat)y 
                 direction:(CGFloat)direction
                  monsters:(NSArray<NSValue *> *)monsters
                   dungeons:(NSArray<NSValue *> *)dungeons {
    self.playerPosition = CGPointMake(x, y);
    self.playerDirection = direction;
    self.monsterPositions = monsters ?: @[];
    self.dungeonRects = dungeons ?: @[];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)updatePlayerPosition:(CGPoint)position direction:(CGFloat)direction {
    self.playerPosition = position;
    self.playerDirection = direction;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)updateMonsters:(NSArray<NSValue *> *)monsters {
    self.monsterPositions = monsters ?: @[];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)refresh {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setNeedsDisplay];
    });
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;
    
    CGFloat centerX = rect.size.width / 2;
    CGFloat centerY = rect.size.height / 2;
    CGFloat scale = rect.size.width / 1000.0;
    
    // 1. Vẽ Dungeon (nâu)
    for (NSValue *dungeonValue in self.dungeonRects) {
        CGRect dungeonRect = [dungeonValue CGRectValue];
        CGRect scaledRect = CGRectMake(dungeonRect.origin.x * scale,
                                        dungeonRect.origin.y * scale,
                                        dungeonRect.size.width * scale,
                                        dungeonRect.size.height * scale);
        CGContextSetFillColorWithColor(context, [UIColor brownColor].CGColor);
        CGContextSetAlpha(context, 0.4);
        CGContextFillEllipseInRect(context, scaledRect);
        CGContextSetAlpha(context, 1.0);
    }
    
    // 2. Vẽ Monster (đỏ)
    for (NSValue *monsterValue in self.monsterPositions) {
        CGPoint monsterPos = [monsterValue CGPointValue];
        CGPoint scaledPos = CGPointMake(monsterPos.x * scale, monsterPos.y * scale);
        CGRect monsterRect = CGRectMake(scaledPos.x - 4, scaledPos.y - 4, 8, 8);
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        CGContextFillEllipseInRect(context, monsterRect);
    }
    
    // 3. Vẽ Player (xanh)
    CGPoint scaledPlayerPos = CGPointMake(self.playerPosition.x * scale, self.playerPosition.y * scale);
    CGRect playerRect = CGRectMake(scaledPlayerPos.x - 6, scaledPlayerPos.y - 6, 12, 12);
    
    CGContextSetShadow(context, CGSizeMake(1, 1), 2);
    CGContextSetFillColorWithColor(context, [UIColor systemBlueColor].CGColor);
    CGContextFillEllipseInRect(context, playerRect);
    CGContextSetShadow(context, CGSizeZero, 0);
    
    // 4. Vẽ hướng nhìn
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2);
    CGContextMoveToPoint(context, scaledPlayerPos.x, scaledPlayerPos.y);
    CGFloat endX = scaledPlayerPos.x + cos(self.playerDirection) * 12;
    CGFloat endY = scaledPlayerPos.y + sin(self.playerDirection) * 12;
    CGContextAddLineToPoint(context, endX, endY);
    CGContextStrokePath(context);
}

@end
