//
//  NSAttributedString+Attributes.m
//  Kamu
//
//  Created by YGTech on 2017/12/4.
//  Copyright © 2017年 com.Kamu.cme. All rights reserved.
//

#import "NSAttributedString+Attributes.h"

@implementation NSAttributedString (Attributes)










+ (NSAttributedString *)attrText:(NSString *)text withFont:(UIFont *)font color:(UIColor *)color aligment:(NSTextAlignment)aligment{
    return [self stringWithText:text withFont:font color:color aligment:aligment  hasUnderline:NO];
}


+ (NSAttributedString *)underlineAttrText:(NSString *)text withFont:(UIFont *)font color:(UIColor *)color aligment:(NSTextAlignment)aligment{
    return [self stringWithText:text withFont:font color:color aligment:aligment  hasUnderline:YES];
}




+ (NSAttributedString *)stringWithText:(NSString *)text withFont:(UIFont *)font color:(UIColor *)color aligment:(NSTextAlignment)aligment hasUnderline:(BOOL)underline{
    
    

    
//    NSString *syntheticText = [NSString stringWithFormat:@"%@%@",prefix,text];
    NSDictionary *attributes;
    //段落样式
    NSMutableParagraphStyle *paragraphStyle = [[ NSMutableParagraphStyle alloc ] init];
    
    //这是段落 格式！！！  居中对齐  、尾部最后一行自然对齐
    paragraphStyle.alignment = aligment;
    //单词和字符的断行模式 ，单词断行！
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    
    
    if (underline) {
       attributes = @{NSFontAttributeName:font,
                      NSForegroundColorAttributeName:color,
                      NSParagraphStyleAttributeName: paragraphStyle,
                      NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]
                                     };
    }
    
//    if (backgroundColor) {
//        attributes = @{NSFontAttributeName:font,
//                       NSForegroundColorAttributeName:color,
//                       NSParagraphStyleAttributeName: paragraphStyle,
//                       NSBackgroundColorAttributeName: color                      };
//    }
    
    else {
        attributes = @{NSFontAttributeName:font,
                       NSForegroundColorAttributeName:color,
                       NSParagraphStyleAttributeName: paragraphStyle,
                       };
        
    }
    
   
    
   
    
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

@end
