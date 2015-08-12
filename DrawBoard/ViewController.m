//
//  ViewController.m
//  DrawBoard
//
//  Created by 凡 张 on 7/27/15.
//  Copyright (c) 2015 CantChat. All rights reserved.
//

#import "ViewController.h"
#import "DrawView.h"

#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)

#define DEFAULT_RED_BRUSH 255
#define DEFAULT_GREEN_BRUSH 0
#define DEFAULT_BLUE_BRUSH 0

#define DEFAULT_RED_BG 255
#define DEFAULT_GREEN_BG 255
#define DEFAULT_BLUE_BG 255

#define DEFAULT_WIDTH 10

typedef NS_ENUM(NSInteger, CurrentColorSelector) {
    brushColorSelector = 0,
    backgroundColorSelector
};

#define SLIDER_TAG_RED 100
#define SLIDER_TAG_GREEN 101
#define SLIDER_TAG_BLUE 102

#define MAX_SCREENLIGHT_TIME 600

//custom color class
@interface CustomColorValue : NSObject
@property (nonatomic) CGFloat v_red;
@property (nonatomic) CGFloat v_green;
@property (nonatomic) CGFloat v_blue;
+ (CustomColorValue *)customColorValueWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue;
@end

@implementation CustomColorValue
+ (CustomColorValue *)customColorValueWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue {
    CustomColorValue * ccv = [[CustomColorValue alloc] init];
    ccv.v_red = red;
    ccv.v_green = green;
    ccv.v_blue = blue;
    return ccv;
}
@end

//color extension
@interface UIColor (custom)
+ (UIColor *)colorWithCustomColor:(CustomColorValue *)ccv;       //alpha default is 1
+ (UIColor *)colorWithCustomColor:(CustomColorValue *)ccv alpha:(CGFloat)alpha;
@end

@implementation UIColor (custom)
+ (UIColor *)colorWithCustomColor:(CustomColorValue *)ccv {
    return [[UIColor alloc]initWithRed:ccv.v_red/255.0f green:ccv.v_green/255.0f blue:ccv.v_blue/255.0f alpha:1];
}
+ (UIColor *)colorWithCustomColor:(CustomColorValue *)ccv alpha:(CGFloat)alpha {
    return [[UIColor alloc]initWithRed:ccv.v_red/255.0f green:ccv.v_green/255.0f blue:ccv.v_blue/255.0f alpha:alpha];
}
@end

//string extension, value transform
@interface NSString (custom)
+ (NSString *)stringWithCGFloat:(CGFloat)value;
+ (NSString *)stringWithNSInteger:(NSInteger)value;
@end

@implementation NSString (custom)
+ (NSString *)stringWithCGFloat:(CGFloat)value {
    return [[NSString alloc] initWithFormat:@"%.0f", value];
}
+ (NSString *)stringWithNSInteger:(NSInteger)value {
    return [[NSString alloc] initWithFormat:@"%lu", value];
}
@end


@interface ViewController ()
{
    //draw view
    __weak IBOutlet DrawView *drawView;
    
    //tool view
    __weak IBOutlet UIView *toolView;
    
    //current color selector type
    CurrentColorSelector currentColorSelector;
    
    //rgb color value labels
    __weak IBOutlet UILabel *lbl_red;
    __weak IBOutlet UILabel *lbl_green;
    __weak IBOutlet UILabel *lbl_blue;
    
    //rgb color sliders
    __weak IBOutlet UISlider *sld_red;
    __weak IBOutlet UISlider *sld_green;
    __weak IBOutlet UISlider *sld_blue;
    
    //current color value
    CustomColorValue * color_brush;
    CustomColorValue * color_bg;
    
    //color value array
    NSArray * ccvArray;
    
    //brush width, integer, need transform
    NSInteger width_brush;
    
    //brush width slider
    __weak IBOutlet UISlider *sld_width;
    
    //brush width value label
    __weak IBOutlet UILabel *lbl_width;
    
    //effects preview
    __weak IBOutlet UIView *effectsPreview;
    
    //cancel screen light always on timer
    NSTimer * screenLightTimer;
}
@end

@implementation ViewController

- (void)awakeFromNib {
    
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self initialValue];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)cancelScreenAlwaysOn {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}
#pragma mark -- Creat/Change Values
- (void)initialValue {
    color_brush = [CustomColorValue customColorValueWithRed:DEFAULT_RED_BRUSH green:DEFAULT_GREEN_BRUSH blue:DEFAULT_BLUE_BRUSH];
    color_bg = [CustomColorValue customColorValueWithRed:DEFAULT_RED_BG green:DEFAULT_GREEN_BG blue:DEFAULT_BLUE_BG];
    ccvArray = @[color_brush, color_bg];
    
    width_brush = DEFAULT_WIDTH;
    sld_width.value = DEFAULT_WIDTH;
    lbl_width.text = [NSString stringWithNSInteger:DEFAULT_WIDTH];
    
    switch (currentColorSelector) {
        case brushColorSelector: {
            sld_red.value = DEFAULT_RED_BRUSH;
            sld_green.value = DEFAULT_GREEN_BRUSH;
            sld_blue.value = DEFAULT_BLUE_BRUSH;
            lbl_red.text = [NSString stringWithNSInteger:DEFAULT_RED_BRUSH];
            lbl_green.text = [NSString stringWithNSInteger:DEFAULT_GREEN_BRUSH];
            lbl_blue.text = [NSString stringWithNSInteger:DEFAULT_BLUE_BRUSH];
        }
            break;
        case backgroundColorSelector: {
            sld_red.value = DEFAULT_RED_BG;
            sld_green.value = DEFAULT_GREEN_BG;
            sld_blue.value = DEFAULT_BLUE_BG;
            lbl_red.text = [NSString stringWithNSInteger:DEFAULT_RED_BG];
            lbl_green.text = [NSString stringWithNSInteger:DEFAULT_GREEN_BG];
            lbl_blue.text = [NSString stringWithNSInteger:DEFAULT_BLUE_BG];
        }
            break;
        default:
            break;
    }
    
    [self updateDrawViewColor];
    
    effectsPreview.backgroundColor = [UIColor colorWithCustomColor:color_brush];
}


//update customColorValue & label text
- (void)updateColorValue:(CGFloat )value withSliderNum:(NSInteger)num {
    
    NSString * strValue = [NSString stringWithCGFloat:value];
    CustomColorValue * ccv = ccvArray[currentColorSelector];
    
    switch (num) {
        case SLIDER_TAG_RED: {
            lbl_red.text = strValue;
            ccv.v_red = value;
        }
            break;
        case SLIDER_TAG_GREEN: {
            lbl_green.text = strValue;
            ccv.v_green = value;
        }
            break;
        case SLIDER_TAG_BLUE: {
            lbl_blue.text = strValue;
            ccv.v_blue = value;
        }
            break;
        default:
            break;
    }
    
    [self updateDrawViewColor];
}

//update color with value
- (void)updateDrawViewColor {
    
    drawView.brushColor = [UIColor colorWithCustomColor:color_brush];
    drawView.backgroundColor = [UIColor colorWithCustomColor:color_bg];
    
    effectsPreview.backgroundColor = drawView.brushColor;
}



#pragma mark -- StoryBoard Interaction Method
- (IBAction)colorSliderValueChanged:(UISlider *)sender {
    [self updateColorValue:sender.value withSliderNum:sender.tag];
    
}

- (IBAction)colorSelectSegmentHandle:(UISegmentedControl *)sender {
    currentColorSelector = sender.selectedSegmentIndex;
    
    switch (currentColorSelector) {
        case brushColorSelector: {
            sld_red.value = color_brush.v_red;
            sld_green.value = color_brush.v_green;
            sld_blue.value = color_brush.v_blue;
            lbl_red.text = [NSString stringWithNSInteger:color_brush.v_red];
            lbl_green.text = [NSString stringWithNSInteger:color_brush.v_green];
            lbl_blue.text = [NSString stringWithNSInteger:color_brush.v_blue];
        }
            break;
        case backgroundColorSelector: {
            sld_red.value = color_bg.v_red;
            sld_green.value = color_bg.v_green;
            sld_blue.value = color_bg.v_blue;
            lbl_red.text = [NSString stringWithNSInteger:color_bg.v_red];
            lbl_green.text = [NSString stringWithNSInteger:color_bg.v_green];
            lbl_blue.text = [NSString stringWithNSInteger:color_bg.v_blue];
        }
            break;
        default:
            break;
    }
}

- (IBAction)widthSliderValueChanged:(UISlider *)sender {
    
    drawView.width = sender.value;
    lbl_width.text = [NSString stringWithCGFloat:sender.value];
    CGPoint center = effectsPreview.center;
    effectsPreview.frame = CGRectMake(CGRectGetMinX(effectsPreview.frame), CGRectGetMinY(effectsPreview.frame), CGRectGetWidth(effectsPreview.frame), sender.value);
    effectsPreview.center = center;
    
}

- (IBAction)undo:(id)sender {
    [drawView undo];
}

- (IBAction)redo:(id)sender {
    [drawView redo];
}

- (IBAction)reset:(id)sender {
    [self initialValue];
}

- (IBAction)clear:(id)sender {
    [drawView clear];
}

- (IBAction)lock:(UIButton *)sender {
    if (drawView.userInteractionEnabled) {
        //lock
        drawView.userInteractionEnabled = NO;
        
        sender.selected = YES;
        
        //set screen light always on☺️
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        screenLightTimer = [NSTimer scheduledTimerWithTimeInterval:600 target:self selector:@selector(cancelScreenAlwaysOn) userInfo:nil repeats:NO];
        NSLog(@"now screen light will always on ☀️☀️");
        
    } else {
        drawView.userInteractionEnabled = YES;
        sender.selected = NO;
        //just should do it 🐶
        [screenLightTimer invalidate];
        [self cancelScreenAlwaysOn];
    }
    
    
}

- (IBAction)tapGestureHandle:(UITapGestureRecognizer *)sender {
    
    [UIView animateWithDuration:0.5 animations:^{
        toolView.alpha = !toolView.alpha;
    }];
    
}
@end
