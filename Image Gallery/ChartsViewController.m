//
//  ChartsViewController.m
//  Image Gallery
//
//  Created by Irfan Godinjak on 09/05/16.
//  Copyright © 2016 Godinjak. All rights reserved.
//

#import "ChartsViewController.h"

@implementation ChartsViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    LineChartView *lineChartView = [[LineChartView alloc] initWithFrame: CGRectMake(0, 0, super.view.frame.size.width, super.view.frame.size.height-80)];
    lineChartView.delegate = self;
    
    lineChartView.descriptionText = @"";
    lineChartView.noDataTextDescription = @"You need to provide data for the chart.";
    
    lineChartView.dragEnabled = NO;
    [lineChartView setScaleEnabled:YES];
    lineChartView.drawGridBackgroundEnabled = YES;
    lineChartView.pinchZoomEnabled = NO;
    
    lineChartView.backgroundColor = [UIColor colorWithWhite:204/255.f alpha:1.f];
    
    lineChartView.legend.form = ChartLegendFormLine;
    lineChartView.legend.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11.f];
    lineChartView.legend.textColor = UIColor.whiteColor;
    lineChartView.legend.position = ChartLegendPositionBelowChartLeft;
    
    ChartXAxis *xAxis = lineChartView.xAxis;
    xAxis.labelFont = [UIFont systemFontOfSize:12.f];
    xAxis.labelTextColor = UIColor.whiteColor;
    xAxis.drawGridLinesEnabled = NO;
    xAxis.drawAxisLineEnabled = NO;
    xAxis.spaceBetweenLabels = 1.0;
}
@end
