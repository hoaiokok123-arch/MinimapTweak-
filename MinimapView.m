#import "MinimapView.h"

@interface MinimapView ()
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@end

@implementation MinimapView

#pragma mark - Init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.75];
    self.layer.cornerRadius = 12;
    self.layer.masksToBounds = YES;
    self.clipsToBounds = YES;
    self.userInteractionEnabled = NO;
    
    // Viền trắng
    self.layer.borderWidth = 1.5;
    self.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.6].CGColor;
    
    // Mặc định
    _playerPosition = CGPointZero;
    _monsterPositions = @[];
    _dungeonRects = @[];
}

#pragma mark - Public Methods

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

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (!context) return;
    
    // Làm mờ nền
    CGContextSetFillColorWithColor(context, self.backgroundColor.CGColor);
    CGContextFillRect(context, rect);
    
    CGFloat centerX = rect.size.width / 2;
    CGFloat centerY = rect.size.height / 2;
    CGFloat scale = rect.size.width / 1000.0; // Giả sử world 1000x1000
    
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
    
    // 2. Vẽ Quái vật (đỏ)
    for (NSValue *monsterValue in self.monsterPositions) {
        CGPoint monsterPos = [monsterValue CGPointValue];
        CGPoint scaledPos = CGPointMake(monsterPos.x * scale, monsterPos.y * scale);
        CGRect monsterRect = CGRectMake(scaledPos.x - 4, scaledPos.y - 4, 8, 8);
        
        // Gradient đỏ cho monster
        CGContextSetFillColorWithColor(context, [UIColor redColor].CGColor);
        CGContextFillEllipseInRect(context, monsterRect);
    }
    
    // 3. Vẽ Player (xanh dương)
    CGPoint scaledPlayerPos = CGPointMake(self.playerPosition.x * scale, self.playerPosition.y * scale);
    CGRect playerRect = CGRectMake(scaledPlayerPos.x - 6, scaledPlayerPos.y - 6, 12, 12);
    
    // Shadow
    CGContextSetShadow(context, CGSizeMake(1, 1), 2);
    
    // Gradient xanh cho player
    CGContextSetFillColorWithColor(context, [UIColor systemBlueColor].CGColor);
    CGContextFillEllipseInRect(context, playerRect);
    
    // Xóa shadow
    CGContextSetShadow(context, CGSizeZero, 0);
    
    // 4. Vẽ hướng nhìn
    CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextSetLineWidth(context, 2);
    CGContextMoveToPoint(context, scaledPlayerPos.x, scaledPlayerPos.y);
    CGFloat endX = scaledPlayerPos.x + cos(self.playerDirection) * 12;
    CGFloat endY = scaledPlayerPos.y + sin(self.playerDirection) * 12;
    CGContextAddLineToPoint(context, endX, endY);
    CGContextStrokePath(context);
    
    // 5. Label "MINIMAP"
    NSDictionary *attrs = @{
        NSFontAttributeName: [UIFont boldSystemFontOfSize:9],
        NSForegroundColorAttributeName: [UIColor whiteColor]
    };
    [@"MINIMAP" drawInRect:CGRectMake(4, 4, 60, 12) withAttributes:attrs];
    
    // 6. Số lượng monster
    NSString *monsterCount = [NSString stringWithFormat:@"%lu", (unsigned long)self.monsterPositions.count];
    [monsterCount drawInRect:CGRectMake(rect.size.width - 25, rect.size.height - 16, 25, 12)
              withAttributes:attrs];
}

@end