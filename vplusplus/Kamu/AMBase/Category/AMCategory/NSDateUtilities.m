/*
 Erica Sadun, http://ericasadun.com
 iPhone Developer's Cookbook 3.x and beyond
 BSD License, Use at your own risk
 */

/*
 #import <humor.h> : Not planning to implement: dateByAskingBoyOut and dateByGettingBabysitter
 ----
 General Thanks: sstreza, Scott Lawrence, Kevin Ballard, NoOneButMe, Avi`, August Joki. Emanuele Vulcano, jcromartiej, Blagovest Dachev, Matthias Plappert,  Slava Bushtruk, Ali Servet Donmez, Ricardo1980, pip8786, Danny Thuerin, Dennis Madsen
*/

#import "NSDateUtilities.h"

#define DATE_COMPONENTS (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekOfYear | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond | NSCalendarUnitWeekday | NSCalendarUnitWeekdayOrdinal)
#define CURRENT_CALENDAR [NSCalendar currentCalendar]

@implementation NSDate (Utilities)

// testing !!!
- (NSString *)weekdayStr {
    NSArray *weekdays = @[@"周日", @"周一", @"周二", @"周三", @"周四", @"周五", @"周六"];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:self];
    return  [weekdays objectAtIndex:theComponents.weekday - 1];
}

#pragma mark Relative Dates

+ (NSInteger)daysOfMonth:(NSInteger)month ofYear:(NSInteger)year {
    NSInteger days;
    switch (month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:
            days = 31;
            break;
        case 4:
        case 6:
        case 9:
        case 11:
            days = 30;
            break;
        case 2: {
            if((year % 4==0 && year % 100!=0) || year % 400==0)
				days = 29;
			else
				days = 28;
            break;
        }
        default:
            days = 30;
            break;
    }
    return days;
}

+ (NSInteger)daysOfMonth:(NSInteger)month {
    return [NSDate daysOfMonth:month ofYear:[[NSDate date] year]];
}


+ (NSDate *)dateWithString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([dateString rangeOfString:@":"].location != NSNotFound) {
        formatter.dateFormat = [NSString stringWithFormat:@"%@ %@",D_BII_DATE_Format, D_BII_TIME_Format];
    } else {
        formatter.dateFormat = D_BII_DATE_Format;
    }
    return [formatter dateFromString:dateString];
}



- (NSString *)dateTimeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = [NSString stringWithFormat:@"%@ %@",D_BII_DATE_Format, D_BII_TIME_Format];
    return [formatter stringFromDate:self];
}

- (NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = D_BII_DATE_Format;
    return [formatter stringFromDate:self];
}

- (NSString *)timeString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = D_BII_TIME_Format;
    return [formatter stringFromDate:self];
}

+ (NSDate *)tomorrow {
	return [NSDate dateWithDaysFromNow:1];
}

+ (NSDate *)yesterday {
	return [NSDate dateWithDaysBeforeNow:1];
}

- (NSDate *)yearsAgo:(NSInteger)years {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [comps setYear: -years];
    NSDate *newDate = [calendar dateByAddingComponents:comps toDate:self options:0];
    return newDate;
}

- (NSDate *)yearsLater:(NSInteger)years {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [comps setYear: years];
    NSDate *newDate = [calendar dateByAddingComponents:comps toDate:self options:0];
    return newDate;
}

- (NSDate *)monthsAgo:(NSInteger)months{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [comps setMonth:-months];
    NSDate *newDate = [calendar dateByAddingComponents:comps toDate:self options:0];
    return newDate;
}

- (NSDate *) monthsLater:(NSInteger)months {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [comps setMonth:months];
    NSDate *newDate = [calendar dateByAddingComponents:comps toDate:self options:0];
    return newDate;
}

- (NSDate *)daysAgo:(NSInteger)days {
    return [self dateBySubtractingDays:days];
}

- (NSDate *)daysLater:(NSInteger)days {
    return [self dateByAddingDays:days];
}

- (NSDate *)hoursAgo:(NSInteger)hours {
    return [self dateBySubtractingHours:hours];
}

- (NSDate *)hoursLater:(NSInteger)hours {
    return [self dateByAddingHours:hours];
}

- (NSDate *)minutesAgo:(NSInteger)minutes {
    return [self dateBySubtractingMinutes:minutes];
}

- (NSDate *)minutesLater:(NSInteger)minutes {
    return [self dateByAddingMinutes:minutes];
}

+ (NSDate *)dateWithTimeIntervalString:(NSString *)string {
    return [NSDate dateWithTimeIntervalSince1970:[string longLongValue]];
}

+ (NSDate *)dateWithMonthsFromNow:(NSInteger)months {
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [comps setMonth:months];
    NSDate *newDate = [calendar dateByAddingComponents:comps toDate:[NSDate date] options:0];
    return newDate;
}

+ (NSDate *)dateWithMonthsBeforeNow:(NSInteger)months {
    return [NSDate dateWithMonthsFromNow:-months];
}

+ (NSDate *)dateWithDaysFromNow:(NSInteger)days {
	return [[NSDate date] dateByAddingDays:days];
}

+ (NSDate *)dateWithDaysBeforeNow:(NSInteger)days {
	return [[NSDate date] dateBySubtractingDays:days];
}

+ (NSDate *)dateWithHoursFromNow:(NSInteger)dHours {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *)dateWithHoursBeforeNow:(NSInteger)dHours {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *)dateWithMinutesFromNow:(NSInteger)dMinutes {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *)dateWithMinutesBeforeNow:(NSInteger)dMinutes {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;
}

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day {
    return [NSDate dateWithYear:year month:month day:day hour:0 minute:0 second:0];
}

+ (NSDate *)dateWithYear:(NSInteger)year month:(NSInteger)month day:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second {
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *systemTimeZone = [NSTimeZone timeZoneForSecondsFromGMT:8];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    [dateComps setCalendar:gregorian];
    [dateComps setYear:year];
    [dateComps setMonth:month];
    [dateComps setDay:day];
    [dateComps setTimeZone:systemTimeZone];
    [dateComps setHour:hour];
    [dateComps setMinute:minute];
    [dateComps setSecond:second];
    return [dateComps date];
}


+ (NSUInteger)executeTimesWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate type:(MBExecuteType)type {
    NSUInteger times = 0;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSDate *newStartDate = [NSDate dateWithYear:startDate.year month:startDate.month day:startDate.day];
    NSDate *newEndDate = [NSDate dateWithYear:endDate.year month:endDate.month day:endDate.day];
    NSDate *tempDate = newStartDate;
    if ([newStartDate isLaterThanDate:newEndDate]) {
        NSLog(@"error: 结束日期不能早于开始日期");
    } else {
        switch (type) {
            case MBExecuteTypeMonth: {
                do {
                    times++;
                    [comps setMonth:1];
                    tempDate = [calendar dateByAddingComponents:comps toDate:tempDate options:0];
                } while (![tempDate isLaterThanDate:newEndDate]);
                break;
            }
            case MBExecuteTypeDoubleWeek: {
                do {
                    times++;
                    [comps setDay:14];
                    tempDate = [calendar dateByAddingComponents:comps toDate:tempDate options:0];
                } while (![tempDate isLaterThanDate:newEndDate]);
                break;
            }
            case MBExecuteTypeWeek: {
                do {
                    times++;
                    [comps setDay:7];
                    tempDate = [calendar dateByAddingComponents:comps toDate:tempDate options:0];
                } while (![tempDate isLaterThanDate:newEndDate]);
                break;
            }
            default:
                break;
        }
    }
    NSLog(@"times:%lu",(unsigned long)times);
    return times;
}

#pragma mark -
#pragma mark Comparing Dates

- (BOOL)isEqualToDateIgnoringTime:(NSDate *)aDate {
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
	return ((components1.year == components2.year) &&
			(components1.month == components2.month) && 
			(components1.day == components2.day));
}

- (BOOL)isToday {
	return [self isEqualToDateIgnoringTime:[NSDate date]];
}

- (BOOL)isTomorrow {
	return [self isEqualToDateIgnoringTime:[NSDate tomorrow]];
}

- (BOOL)isYesterday {
	return [self isEqualToDateIgnoringTime:[NSDate yesterday]];
}

- (BOOL)isSameWeekAsDate: (NSDate *)aDate {
	NSDateComponents *components1 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate];
	
	// Must be same week. 12/31 and 1/1 will both be week "1" if they are in the same week
	if (components1.weekOfMonth != components2.weekOfMonth) return NO;
	
	// Must have a time interval under 1 week. Thanks @aclark
	return (fabs([self timeIntervalSinceDate:aDate]) < D_WEEK);
}

- (BOOL)isThisWeek {
	return [self isSameWeekAsDate:[NSDate date]];
}

- (BOOL)isNextWeek {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] + D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameWeekAsDate:newDate];
}

- (BOOL)isLastWeek {
	NSTimeInterval aTimeInterval = [[NSDate date] timeIntervalSinceReferenceDate] - D_WEEK;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return [self isSameWeekAsDate:newDate];
}

- (BOOL)isSameMonthAsDate:(NSDate *)aDate {
    NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:self];
    NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear | NSCalendarUnitMonth fromDate:aDate];
    return ((components1.month == components2.month) &&
            (components1.year == components2.year));
}

- (BOOL)isThisMonth {
    return [self isSameMonthAsDate:[NSDate date]];
}

- (BOOL)isSameYearAsDate:(NSDate *)aDate {
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:aDate];
	return (components1.year == components2.year);
}

- (BOOL)isThisYear {
	return [self isSameYearAsDate:[NSDate date]];
}

- (BOOL)isNextYear {
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:[NSDate date]];
	return (components1.year == (components2.year + 1));
}

- (BOOL)isLastYear {
	NSDateComponents *components1 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:self];
	NSDateComponents *components2 = [CURRENT_CALENDAR components:NSCalendarUnitYear fromDate:[NSDate date]];
	return (components1.year == (components2.year - 1));
}

- (BOOL)isEarlierThanDate:(NSDate *)aDate {
	return ([self compare:aDate] == NSOrderedAscending);
}

- (BOOL)isLaterThanDate:(NSDate *)aDate {
	return ([self compare:aDate] == NSOrderedDescending);
}

- (BOOL)isInFuture {
    return ([self isLaterThanDate:[NSDate date]]);
}

- (BOOL)isInPast {
    return ([self isEarlierThanDate:[NSDate date]]);
}

- (BOOL)isLeapYear {
    if (((self.year % 4==0 && self.year % 100!=0) || self.year % 400==0)) {
        return YES;
    }
    return NO;
}


#pragma mark -
#pragma mark Roles

- (BOOL)isTypicallyWeekend {
    NSDateComponents *components = [CURRENT_CALENDAR components:NSCalendarUnitWeekday fromDate:self];
    if ((components.weekday == 1) ||
        (components.weekday == 7))
        return YES;
    return NO;
}

- (BOOL)isTypicallyWorkday {
    return ![self isTypicallyWeekend];
}


#pragma mark -
#pragma mark Adjusting Dates

- (NSDate *)dateByAddingDays: (NSInteger)dDays {
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_DAY * dDays;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;		
}

- (NSDate *)dateBySubtractingDays: (NSInteger)dDays {
	return [self dateByAddingDays: (dDays * -1)];
}

- (NSDate *)dateByAddingHours: (NSInteger)dHours {
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_HOUR * dHours;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;		
}

- (NSDate *)dateBySubtractingHours:(NSInteger)dHours {
	return [self dateByAddingHours: (dHours * -1)];
}

- (NSDate *)dateByAddingMinutes:(NSInteger)dMinutes {
	NSTimeInterval aTimeInterval = [self timeIntervalSinceReferenceDate] + D_MINUTE * dMinutes;
	NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:aTimeInterval];
	return newDate;			
}

- (NSDate *)dateBySubtractingMinutes:(NSInteger)dMinutes {
	return [self dateByAddingMinutes: (dMinutes * -1)];
}

- (NSDate *)dateAtStartOfDay {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	components.hour = 0;
	components.minute = 0;
	components.second = 0;
	return [CURRENT_CALENDAR dateFromComponents:components];
}

- (NSDateComponents *)componentsWithOffsetFromDate:(NSDate *)aDate {
	NSDateComponents *dTime = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:aDate toDate:self options:0];
	return dTime;
}


#pragma mark -
#pragma mark Retrieving Intervals

- (NSInteger)minutesAfterDate:(NSDate *)aDate {
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger)minutesBeforeDate:(NSDate *)aDate {
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_MINUTE);
}

- (NSInteger)hoursAfterDate:(NSDate *)aDate {
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger)hoursBeforeDate:(NSDate *)aDate {
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_HOUR);
}

- (NSInteger)daysAfterDate:(NSDate *)aDate {
	NSTimeInterval ti = [self timeIntervalSinceDate:aDate];
	return (NSInteger) (ti / D_DAY);
}

- (NSInteger)daysBeforeDate:(NSDate *)aDate {
	NSTimeInterval ti = [aDate timeIntervalSinceDate:self];
	return (NSInteger) (ti / D_DAY);
}

- (NSInteger)distanceInDaysToDate:(NSDate *)anotherDate {
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay fromDate:self toDate:anotherDate options:0];
    return components.day;
}


#pragma mark -
#pragma mark Decomposing Dates

- (NSInteger)hour {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.hour;
}

- (NSInteger)minute {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.minute;
}

- (NSInteger)seconds {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.second;
}

- (NSInteger)day {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.day;
}

- (NSInteger)month {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.month;
}

- (NSInteger)week {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.weekOfMonth;
}

- (NSInteger)weekday {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.weekday - 1;
}

- (NSInteger)year {
	NSDateComponents *components = [CURRENT_CALENDAR components:DATE_COMPONENTS fromDate:self];
	return components.year;
}

@end
