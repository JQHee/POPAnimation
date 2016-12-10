//
//  PublicViewController.m
//  testSB
//
//  Created by MAC on 2016/12/9.
//  Copyright © 2016年 MAC. All rights reserved.
//

#import "PublicViewController.h"
#import <POP/POP.h>

#define CYScreenW [UIScreen mainScreen].bounds.size.width
#define CYScreenH [UIScreen mainScreen].bounds.size.height


static CGFloat const CYSpringFactor = 10;

@interface PublicViewController ()
/** 标语 */
@property (nonatomic, weak) UIImageView *sloganView;
/** 按钮 */
@property (nonatomic, strong) NSMutableArray *buttons;

/** 动画时间 */
@property (nonatomic, strong) NSArray *times;

@end

@implementation PublicViewController

- (NSMutableArray *)buttons
{
    if (!_buttons) {
        _buttons = [NSMutableArray array];
    }
    return _buttons;
}

- (NSArray *)times
{
    if (!_times) {
        CGFloat interval = 0.1; // 时间间隔
        _times = @[@(5 * interval),
                   @(4 * interval),
                   @(3 * interval),
                   @(2 * interval),
                   @(0 * interval),
                   @(1 * interval),
                   @(6 * interval)]; // 标语的动画时间
    }
    return _times;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 禁止交互
    self.view.userInteractionEnabled = NO;
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
    
    // 按钮
    [self setupButtons];
    
    // 标语
    [self setupSloganView];
}

- (void)setupButtons
{
    // 数据
    NSArray *images = @[@"publish-video", @"publish-picture", @"publish-text", @"publish-audio", @"publish-review", @"publish-offline"];
    NSArray *titles = @[@"发视频", @"发图片", @"发段子", @"发声音", @"审帖", @"离线下载"];
    
    // 一些参数
    NSUInteger count = images.count;
    int maxColsCount = 3; // 一行的列数
    NSUInteger rowsCount = (count + maxColsCount - 1) / maxColsCount;
    
    // 按钮尺寸
    CGFloat buttonW = CYScreenW / maxColsCount;
    CGFloat buttonH = buttonW * 1.2;
    CGFloat buttonStartY = (CYScreenH - rowsCount * buttonH) * 0.5;
    for (int i = 0; i < count; i++) {
        // 创建、添加
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect rect = button.frame;
        rect.size.width = -1; // 按钮的尺寸为0，还是能看见文字缩成一个点，设置按钮的尺寸为负数，那么就看不见文字了
        button.frame = rect;
        
        button.backgroundColor = [UIColor redColor];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.buttons addObject:button];
        [self.view addSubview:button];
        
        // 内容
        [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
        [button setTitle:titles[i] forState:UIControlStateNormal];
        
        // frame
        CGFloat buttonX = (i % maxColsCount) * buttonW;
        CGFloat buttonY = buttonStartY + (i / maxColsCount) * buttonH;
        
        // 动画
        POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
        anim.fromValue = [NSValue valueWithCGRect:CGRectMake(buttonX, buttonY - CYScreenH, buttonW, buttonH)];
        anim.toValue = [NSValue valueWithCGRect:CGRectMake(buttonX, buttonY, buttonW, buttonH)];
        anim.springSpeed = CYSpringFactor;
        anim.springBounciness = CYSpringFactor;
        // CACurrentMediaTime()获得的是当前时间
        anim.beginTime = CACurrentMediaTime() + [self.times[i] doubleValue];
        [button pop_addAnimation:anim forKey:nil];
    }
}

- (void)setupSloganView
{
    CGFloat sloganY = CYScreenH * 0.2;
    
    // 添加
    UIImageView *sloganView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"app_slogan"]];
    CGRect rect = sloganView.frame;
    CGPoint point = sloganView.center;
    rect.origin.y = sloganY - CYScreenH;
    point.x = CYScreenW * 0.5;
    sloganView.frame = rect;
    sloganView.center = point;
    [self.view addSubview:sloganView];
    self.sloganView = sloganView;
    
    __weak typeof (self) weakSelf = self;
    // 动画
    POPSpringAnimation *anim = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    anim.toValue = @(sloganY);
    anim.springSpeed = CYSpringFactor;
    anim.springBounciness = CYSpringFactor;
    // CACurrentMediaTime()获得的是当前时间
    anim.beginTime = CACurrentMediaTime() + [self.times.lastObject doubleValue];
    [anim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        // 开始交互
        weakSelf.view.userInteractionEnabled = YES;
    }];
    [sloganView.layer pop_addAnimation:anim forKey:nil];
}

- (void)buttonClick:(UIButton *)button
{
    //CYLogFunc;
}

- (IBAction)cancel {
    // 禁止交互
    self.view.userInteractionEnabled = NO;
    
    // 让按钮执行动画
    for (int i = 0; i < self.buttons.count; i++) {
        UIButton *button = self.buttons[i];
        
        POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
        anim.toValue = @(button.layer.position.y + CYScreenH);
        // CACurrentMediaTime()获得的是当前时间
        anim.beginTime = CACurrentMediaTime() + [self.times[i] doubleValue];
        [button.layer pop_addAnimation:anim forKey:nil];
    }
    
    __weak typeof (self) weakSelf = self;
    // 让标题执行动画
    POPBasicAnimation *anim = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPositionY];
    anim.toValue = @(self.sloganView.layer.position.y + CYScreenH);
    // CACurrentMediaTime()获得的是当前时间
    anim.beginTime = CACurrentMediaTime() + [self.times.lastObject doubleValue];
    [anim setCompletionBlock:^(POPAnimation *anim, BOOL finished) {
        [weakSelf dismissViewControllerAnimated:NO completion:nil];
    }];
    [self.sloganView.layer pop_addAnimation:anim forKey:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self cancel];
}
@end
