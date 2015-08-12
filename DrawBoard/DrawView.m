//
//  DrawView.m
//  DrawBoard
//
//  Created by 凡 张 on 7/27/15.
//  Copyright (c) 2015 CantChat. All rights reserved.
//

#import "DrawView.h"

@implementation DrawView
{
    //line colors
    NSMutableArray *colorArray;
    
    //line width values
    NSMutableArray *WidthArray;
    
    //current touch points
    NSMutableArray *pointArray;
    
    //lines
    NSMutableArray *lineArray;
    
    //deleted line colors
    NSMutableArray *delColorArray;
    
    //deleted line width values
    NSMutableArray *delWidthArray;
    
    //deleted lines
    NSMutableArray *delLineArray;
}

- (void)awakeFromNib {
    
    colorArray=[[NSMutableArray alloc]init];
    WidthArray=[[NSMutableArray alloc]init];
    lineArray=[[NSMutableArray alloc]init];
    
    delColorArray=[[NSMutableArray alloc]init];
    delWidthArray=[[NSMutableArray alloc]init];
    delLineArray=[[NSMutableArray alloc]init];
    
    //颜色和宽度默认都取当前数组第0位为默认值
    self.brushColor = [UIColor redColor];
    self.width = 10.0f;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 10.0f);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    CGContextSetLineCap(context, kCGLineCapRound);
    //if had old line
    if ([lineArray count]>0) {
        for (int i=0; i<[lineArray count]; i++) {
            NSArray * array=[NSArray arrayWithArray:[lineArray objectAtIndex:i]];
            
            if ([array count]>0) {
                CGContextBeginPath(context);
                CGPoint myStartPoint=CGPointFromString([array objectAtIndex:0]);
                CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
                
                for (int j=0; j<[array count]-1; j++)
                {
                    CGPoint myEndPoint=CGPointFromString([array objectAtIndex:j+1]);
                    //--------------------------------------------------------
                    CGContextAddLineToPoint(context, myEndPoint.x,myEndPoint.y);
                }
                UIColor *lineColor = colorArray[i];
                float lineWidth= [WidthArray[i] floatValue];
                CGContextSetStrokeColorWithColor(context,[lineColor CGColor]);
                CGContextSetLineWidth(context, lineWidth);
                CGContextStrokePath(context);
            }
        }
    }
    //current line
    if ([pointArray count]>0) {
        
        CGContextBeginPath(context);
        CGPoint myStartPoint=CGPointFromString([pointArray objectAtIndex:0]);
        CGContextMoveToPoint(context, myStartPoint.x, myStartPoint.y);
        
        for (int j=0; j<[pointArray count]-1; j++)
        {
            CGPoint myEndPoint=CGPointFromString([pointArray objectAtIndex:j+1]);
            CGContextAddLineToPoint(context, myEndPoint.x,myEndPoint.y);
        }
        UIColor *lineColor = self.brushColor;
        float lineWidth = self.width;
        CGContextSetStrokeColorWithColor(context,[lineColor CGColor]);
        CGContextSetLineWidth(context, lineWidth);
        CGContextStrokePath(context);
    }
    
    
}

-(void)addPA:(CGPoint)nPoint {
    NSString *sPoint=NSStringFromCGPoint(nPoint);
    [pointArray addObject:sPoint];
}

-(void)addLA {
    [colorArray addObject:self.brushColor];
    [WidthArray addObject:[NSNumber numberWithFloat:self.width]];
    
    NSArray *line=[NSArray arrayWithArray:pointArray];
    [lineArray addObject:line];
    
    pointArray = nil;
}

#pragma mark -
static CGPoint MyBeganpoint;
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    pointArray=[[NSMutableArray alloc]init];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch* touch=[touches anyObject];
    MyBeganpoint=[touch locationInView:self];
    NSString *sPoint=NSStringFromCGPoint(MyBeganpoint);
    [pointArray addObject:sPoint];
    [self setNeedsDisplay];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self addLA];
    NSLog(@"touches end");
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    NSLog(@"touches Canelled");
}

-(void)undo {
    
    if ([lineArray count]) {
        [delLineArray addObject:[lineArray lastObject]];
        [lineArray removeLastObject];
    }
    if ([colorArray count]) {
        [delColorArray addObject:[colorArray lastObject]];
        [colorArray removeLastObject];
    }
    if ([WidthArray count]) {
        [delWidthArray addObject:[WidthArray lastObject]];
        [WidthArray removeLastObject];
    }
    
    [self setNeedsDisplay];
}

-(void)redo {
    
    if ([delLineArray count]) {
        [lineArray addObject:[delLineArray lastObject]];
        [delLineArray removeLastObject];
    }
    if ([delColorArray count]) {
        [colorArray addObject:[delColorArray lastObject]];
        [delColorArray removeLastObject];
    }
    if ([delWidthArray count]) {
        [WidthArray addObject:[delWidthArray lastObject]];
        [delWidthArray removeLastObject];
    }
    
    [self setNeedsDisplay];
    
}

-(void)clear {
    
    [colorArray removeAllObjects];
    [WidthArray removeAllObjects];
    [lineArray removeAllObjects];
    [pointArray removeAllObjects];
    [delColorArray removeAllObjects];
    [delWidthArray removeAllObjects];
    [delLineArray removeAllObjects];
    
    [self setNeedsDisplay];
}

@end
