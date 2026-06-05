#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface MinimapView : UIView

@property (nonatomic, assign) CGPoint playerPosition;
@property (nonatomic, assign) CGFloat playerDirection;
@property (nonatomic, strong) NSArray<NSValue *> *monsterPositions;
@property (nonatomic, strong) NSArray<NSValue *> *dungeonRects;

- (void)updateWithPlayerX:(CGFloat)x 
                         y:(CGFloat)y 
                 direction:(CGFloat)direction
                  monsters:(NSArray<NSValue *> *)monsters
                   dungeons:(NSArray<NSValue *> *)dungeons;

- (void)updatePlayerPosition:(CGPoint)position direction:(CGFloat)direction;
- (void)updateMonsters:(NSArray<NSValue *> *)monsters;
- (void)refresh;

@end

NS_ASSUME_NONNULL_END
