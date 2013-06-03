//
//  BIDTinyView.h
//  TinyPix
//
//  Created by 李 潇磊 on 13-6-3.
//  Copyright (c) 2013年 李 潇磊. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BIDTinyPixDocument;

@interface BIDTinyPixView : UIView

@property (strong, nonatomic) BIDTinyPixDocument *document;
@property (strong, nonatomic) UIColor *highlightColor;

@end
