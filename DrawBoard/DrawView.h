//
//  DrawView.h
//  DrawBoard
//
//  Created by 凡 张 on 7/27/15.
//  Copyright (c) 2015 CantChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawView : UIView


@property (nonatomic) UIColor * brushColor;
@property (nonatomic) CGFloat width;

// get point  in view
-(void)addPA:(CGPoint)nPoint;
-(void)addLA;
-(void)undo;
-(void)redo;
-(void)clear;

@end
