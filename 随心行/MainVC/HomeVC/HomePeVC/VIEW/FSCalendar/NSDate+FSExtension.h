//
//  NSDate+FSExtension.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <Foundation/Foundation.h>

@interface NSDate (FSExtension)

@property (readonly, nonatomic) NSInteger fs_year;
@property (readonly, nonatomic) NSInteger fs_month;
@property (readonly, nonatomic) NSInteger fs_day;
@property (readonly, nonatomic) NSInteger fs_weekday;

@property (readonly, nonatomic) NSInteger numberOfDaysInMonth;

- (NSDate *)fs_dateByAddingMonths:(NSInteger)months;
- (NSDate *)fs_dateBySubtractingMonths:(NSInteger)months;
- (NSDate *)fs_dateByAddingDays:(NSInteger)days;
- (NSDate *)fs_dateBySubtractingDays:(NSInteger)days;
- (NSString *)fs_stringWithFormat:(NSString *)format;

+ (instancetype)fs_dateFromString:(NSString *)string format:(NSString *)format;
+ (instancetype)fs_dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day;

@end
// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com