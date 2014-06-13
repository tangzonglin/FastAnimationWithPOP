//
//  UIView+FastAnimation.m
//  FastAnimationWithPop
//
//  Created by ZangChengwei on 14-6-12.
//  Copyright (c) 2014年 WilliamZang. All rights reserved.
//

#import "UIView+FastAnimation.h"
#import "FastAnimationProtocol.h"
#import <objc/runtime.h>

#define DEFINE_RW_FLAG(ctype, flag, setter, asstype)            \
    static void *flag##Key = &flag##Key;                        \
- (void)setter:(ctype *)value {                                 \
    objc_setAssociatedObject(self, flag##Key, value, asstype);  \
}                                                               \
- (ctype *)flag {                                               \
    return objc_getAssociatedObject(self, flag##Key);           \
}

#define DEFINE_RW_CGFLOAT_FLAG(flag, setter)                    \
    static void *flag##Key = &flag##Key;                        \
- (void)setter: (CGFloat)value {                                \
    objc_setAssociatedObject(self, flag##Key,                   \
        [NSNumber numberWithFloat:value],                       \
        OBJC_ASSOCIATION_RETAIN_NONATOMIC);                     \
}                                                               \
- (CGFloat)flag                                                 \
{                                                               \
    return [objc_getAssociatedObject(self, flag##Key)           \
        floatValue];                                            \
}

#define DEFINE_RW_CGFLOAT_FLAG_WITH_DEFAULT(flag, setter, default)  \
static void *flag##Key = &flag##Key;                                \
- (void)setter: (CGFloat)value {                                    \
objc_setAssociatedObject(self, flag##Key,                           \
[NSNumber numberWithFloat:value],                                   \
OBJC_ASSOCIATION_RETAIN_NONATOMIC);                                 \
}                                                                   \
- (CGFloat)flag                                                     \
{                                                                   \
id value = objc_getAssociatedObject(self, flag##Key);               \
return value ? [value floatValue] : default;                        \
}

#define DEFINE_RW_DOUBLE_FLAG(flag, setter)                     \
static void *flag##Key = &flag##Key;                            \
- (void)setter: (double)value {                                 \
objc_setAssociatedObject(self, flag##Key,                       \
[NSNumber numberWithDouble:value],                              \
OBJC_ASSOCIATION_RETAIN_NONATOMIC);                             \
}                                                               \
- (double)flag                                                  \
{                                                               \
return [objc_getAssociatedObject(self, flag##Key)               \
doubleValue];                                                   \
}

#define DEFINE_RW_DOUBLE_FLAG_WITH_DEFAULT(flag, setter, default)   \
static void *flag##Key = &flag##Key;                                \
- (void)setter: (double)value {                                     \
objc_setAssociatedObject(self, flag##Key,                           \
[NSNumber numberWithDouble:value],                                  \
OBJC_ASSOCIATION_RETAIN_NONATOMIC);                                 \
}                                                                   \
- (double)flag                                                      \
{                                                                   \
    id value = objc_getAssociatedObject(self, flag##Key);           \
    return value ? [value doubleValue] : default;                   \
}
@implementation UIView (FastAnimation)

DEFINE_RW_FLAG(NSString, animationType, setAnimationType, OBJC_ASSOCIATION_COPY_NONATOMIC)
DEFINE_RW_CGFLOAT_FLAG_WITH_DEFAULT(springBounciness, setSpringBounciness, 4.0)
DEFINE_RW_CGFLOAT_FLAG_WITH_DEFAULT(springSpeed, setSpringSpeed, 12)
DEFINE_RW_CGFLOAT_FLAG(dynamicsTension, setDynamicsTension)
DEFINE_RW_CGFLOAT_FLAG(dynamicsFriction, setDynamicsFriction)
DEFINE_RW_CGFLOAT_FLAG(dynamicsMass, setDynamicsMass)
DEFINE_RW_DOUBLE_FLAG(delay, setDelay)


- (void)swizzle_awakeFromNib
{
    [self swizzle_awakeFromNib];
    if (self.animationType) {
        Class animationClass = NSClassFromString(self.animationType);
        if (animationClass == nil) {
            animationClass = NSClassFromString([@"FAAnimation" stringByAppendingString:self.animationType]);
        }
        NSAssert([animationClass conformsToProtocol:@protocol(FastAnimationProtocol)], @"The property 'animationType' must a class name and conforms protocol 'FastAnmationProtocol'");
        NSAssert(self.delay > -0.0000001, @"property 'delay' must > 0");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [animationClass performAnimation:self];
        });

    }
}

+ (void)load
{
    Method original, swizzle;
    
    original = class_getInstanceMethod(self, @selector(awakeFromNib));
    swizzle = class_getInstanceMethod(self, @selector(swizzle_awakeFromNib));
    method_exchangeImplementations(original, swizzle);
}
@end