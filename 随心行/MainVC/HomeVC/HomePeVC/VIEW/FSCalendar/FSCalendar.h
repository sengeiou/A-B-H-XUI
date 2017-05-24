//
//  FScalendar.h
//  Pods
//
//  Created by Wenchao Ding on 29/1/15.
//
//

#import <UIKit/UIKit.h>

@class FSCalendar, FSCalendarUnit, FSCalendarHeader;

typedef NS_ENUM(NSInteger, FSCalendarFlow) {
    FSCalendarFlowHorizontal = 0,
    FSCalendarFlowVertical   = 1
};

typedef NS_OPTIONS(NSInteger, FSCalendarUnitAnimation) {
    FSCalendarUnitAnimationNone  = 0,
    FSCalendarUnitAnimationScale = 1,
    FSCalendarUnitAnimationShade = 2
};

typedef NS_OPTIONS(NSInteger, FSCalendarUnitStyle) {
    FSCalendarUnitStyleCircle         = 0,
    FSCalendarUnitStyleRectangle      = 1
};

typedef NS_OPTIONS(NSInteger, FSCalendarUnitState) {
    FSCalendarUnitStateNormal       = 0,
    FSCalendarUnitStateSelected     = 1,
    FSCalendarUnitStatePlaceholder  = 1 << 1,
    FSCalendarUnitStateDisabled     = 1 << 2,
    FSCalendarUnitStateToday        = 1 << 3,
    FSCalendarUnitStateWeekend      = 1 << 4,
    FSCalendarUnitStateMonth        = 1 << 5
};

@protocol FSCalendarDelegate <NSObject>

@optional
- (BOOL)calendar:(FSCalendar *)calendar shouldSelectDate:(NSDate *)date;
- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date;
- (void)calendarCurrentMonthDidChange:(FSCalendar *)calendar;

@end

@protocol FSCalendarDataSource <NSObject>

@optional
- (NSString *)calendar:(FSCalendar *)calendar subtitleForDate:(NSDate *)date;
- (BOOL)calendar:(FSCalendar *)calendar hasEventForDate:(NSDate *)date;

@end

@interface FSCalendar : UIView<UIAppearance>

@property (weak, nonatomic) IBOutlet id<FSCalendarDelegate> delegate;
@property (weak, nonatomic) IBOutlet id<FSCalendarDataSource> dataSource;
@property (weak, nonatomic) IBOutlet FSCalendarHeader *header;

@property (copy, nonatomic) NSDate *currentDate;
@property (copy, nonatomic) NSDate *selectedDate;
@property (copy, nonatomic) NSDate *currentMonth;


@property (assign, nonatomic) FSCalendarFlow flow;

@property (assign, nonatomic) BOOL autoAdjustTitleSize;
@property (assign, nonatomic) BOOL turnRight;

@property (assign, nonatomic) NSInteger currentPage;
@property (assign, nonatomic) NSInteger oldCurrentPage;

@property (assign, nonatomic) CGFloat minDissolvedAlpha UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) FSCalendarUnitStyle unitStyle UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *titleFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *subtitleFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *weekdayFont UI_APPEARANCE_SELECTOR;
@property (strong, nonatomic) UIFont *headerTitleFont UI_APPEARANCE_SELECTOR;

- (void)setWeekdayTextColor:(UIColor *)weekdayTextColor UI_APPEARANCE_SELECTOR;

- (void)setHeaderTitleColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setHeaderDateFormat:(NSString *)dateFormat UI_APPEARANCE_SELECTOR;

- (void)setTitleDefaultColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setTitleSelectionColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setTitleTodayColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setTitlePlaceholderColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setTitleWeekendColor:(UIColor *)color UI_APPEARANCE_SELECTOR;

- (void)setSubtitleDefaultColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setSubtitleSelectionColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setSubtitleTodayColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setSubtitlePlaceholderColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setSubtitleWeekendColor:(UIColor *)color UI_APPEARANCE_SELECTOR;

- (void)setSelectionColor:(UIColor *)color UI_APPEARANCE_SELECTOR;
- (void)setTodayColor:(UIColor *)color UI_APPEARANCE_SELECTOR;

- (void)setEventColor:(UIColor *)color UI_APPEARANCE_SELECTOR;

- (void)reloadData;

- (void)initialize;

- (void)setscrollviewOffset:(NSInteger)tage;

- (void)changeDateWithSelectedDate:(NSDate *)date currentDate:(NSDate *)currentDate;
@end



// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com
