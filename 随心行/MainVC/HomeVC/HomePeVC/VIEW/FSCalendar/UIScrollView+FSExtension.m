//
//  UIScrollView+FSExtension.m
//  Pods
//
//  Created by Wenchao Ding on 5/3/15.
//
//

#import "UIScrollView+FSExtension.h"

@implementation UIScrollView (FSExtension)

- (void)fs_scrollBy:(CGPoint)offset animate:(BOOL)animate
{
    if (!animate) {
        self.contentOffset = CGPointMake(self.contentOffset.x+offset.x, self.contentOffset.y+offset.y);
    } else {
        
    }
}

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com