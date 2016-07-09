//
//  ImageViewController.m
//  Image Gallery
//
//  Created by Irfan Godinjak on 09/05/16.
//  Copyright © 2016 Godinjak. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet LineChartView *lineChart;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayout;

- (IBAction)showGrayImage:(id)sender;
- (IBAction)showNegativeImage:(id)sender;
- (IBAction)showOriginalImage:(id)sender;
- (IBAction)presentHistogram:(id)sender;
- (IBAction)back:(id)sender;
- (IBAction)closeCharts:(id)sender;
@end

@implementation ImageViewController

@synthesize imgeEffectModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.imageView.image = self.imgeEffectModel.image;
    _topLayout.constant = self.view.frame.size.height;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.userInteractionEnabled = YES;
    [self.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareImage)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareImage{
    UIImage *image = self.imageView.image;
    NSMutableArray *activityItems = [NSMutableArray arrayWithObjects:image, nil];
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    
    [self.navigationController presentViewController:activityViewController animated:YES completion:nil];

}

- (IBAction)showGrayImage:(id)sender {
    self.imageView.image = self.imgeEffectModel.greyImage;
}

- (IBAction)showNegativeImage:(id)sender {
    self.imageView.image = self.imgeEffectModel.negativeImage;
}

- (IBAction)showOriginalImage:(id)sender {
    self.imageView.image = self.imgeEffectModel.image;
}

- (IBAction)presentHistogram:(id)sender {
    if (!self.imgeEffectModel.redArray) {
        [self.imgeEffectModel findMeHistogram];
        [self prepareCharts];
        [self showHistogram:YES];
    }
    else
        [self showHistogram:YES];
}

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)closeCharts:(id)sender {
    [self showHistogram:NO];
}

- (void) showHistogram:(BOOL)show{
    _topLayout.constant = !show * self.view.frame.size.height;

    [UIView animateWithDuration:0.8 animations:^{
        _lineChart.alpha = show;
        [self.view layoutIfNeeded];
    }];
}

- (void) prepareCharts{
    _lineChart.delegate = self;
    _lineChart.descriptionText = @"";
    _lineChart.noDataTextDescription = @"You need to provide data for the chart.";
    _lineChart.backgroundColor = [UIColor colorWithWhite:204/255.f alpha:0.8f];
    NSMutableArray *xVals = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.imgeEffectModel.redArray.count; i++)
    {
        [xVals addObject:[@(i) stringValue]];
    }
    NSMutableArray *yVals1 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals2 = [[NSMutableArray alloc] init];
    NSMutableArray *yVals3 = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.imgeEffectModel.redArray.count; i++)
    {
        NSNumber *redNum = self.imgeEffectModel.redArray[i];
        float redVal = [redNum floatValue];
        NSNumber *greenNum = self.imgeEffectModel.greenArray[i];
        float greenVal = [greenNum floatValue];
        NSNumber *blueNum = self.imgeEffectModel.blueArray[i];
        float blueVal = [blueNum floatValue];
        [yVals1 addObject:[[ChartDataEntry alloc] initWithValue:redVal xIndex:i]];
        [yVals2 addObject:[[ChartDataEntry alloc] initWithValue:greenVal xIndex:i]];
        [yVals3 addObject:[[ChartDataEntry alloc] initWithValue:blueVal xIndex:i]];
    }
    LineChartDataSet *set1 = nil, *set2 = nil, *set3 = nil;
    
    set1 = [[LineChartDataSet alloc] initWithYVals:yVals1 label:@"Red"];
    set1.axisDependency = AxisDependencyLeft;
    [set1 setColor:[UIColor redColor]];
    [set1 setCircleColor:UIColor.redColor];
    set1.lineWidth = 1.0;
    set1.circleRadius = 0.0;
    set1.fillAlpha = 1;
    set1.fillColor = [UIColor redColor];
    set1.highlightColor = [UIColor redColor];
    set1.drawCircleHoleEnabled = NO;
    set1.drawFilledEnabled = YES;
    
    
    set2 = [[LineChartDataSet alloc] initWithYVals:yVals2 label:@"Green"];
    set2.axisDependency = AxisDependencyLeft;
    [set2 setColor:[UIColor greenColor]];
    [set2 setCircleColor:UIColor.greenColor];
    set2.lineWidth = 1.0;
    set2.circleRadius = 0.0;
    set2.fillAlpha = 1;
    set2.fillColor = [UIColor greenColor];
    set2.highlightColor = [UIColor greenColor];
    set2.drawCircleHoleEnabled = NO;
    set2.drawFilledEnabled = YES;
    
    
    set3 = [[LineChartDataSet alloc] initWithYVals:yVals3 label:@"Blue"];
    set3.axisDependency = AxisDependencyLeft;
    [set3 setColor:[UIColor blueColor]];
    [set3 setCircleColor:UIColor.blueColor];
    set3.lineWidth = 1.0;
    set3.circleRadius = 0.0;
    set3.fillAlpha = 1;
    set3.fillColor = [UIColor blueColor];
    set3.drawFilledEnabled = YES;
    set3.highlightColor = [UIColor blueColor];
    set3.drawCircleHoleEnabled = NO;
    
    NSMutableArray *dataSets = [[NSMutableArray alloc] init];
    [dataSets addObject:set2];
    [dataSets addObject:set3];
    [dataSets addObject:set1];
    
    LineChartData *data = [[LineChartData alloc] initWithXVals:xVals dataSets:dataSets];
    [data setValueTextColor:UIColor.whiteColor];
    [data setValueFont:[UIFont systemFontOfSize:9.f]];
    
    _lineChart.data = data;
    
    _lineChart.legend.form = ChartLegendFormLine;
    _lineChart.legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    _lineChart.legend.textColor = UIColor.whiteColor;
    _lineChart.legend.position = ChartLegendPositionAboveChartRight;

}
@end
