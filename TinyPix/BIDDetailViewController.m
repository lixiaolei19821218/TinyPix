//
//  BIDDetailViewController.m
//  TinyPix
//
//  Created by 李 潇磊 on 13-5-27.
//  Copyright (c) 2013年 李 潇磊. All rights reserved.
//

#import "BIDDetailViewController.h"
#import "BIDTinyPixView.h"

@interface BIDDetailViewController ()
@property (assign, nonatomic) NSUInteger selectedColorIndex;
- (void)configureView;
@end

@implementation BIDDetailViewController

- (void)setSelectedColorIndex:(NSUInteger)i {
    if (_selectedColorIndex == i) return;
    _selectedColorIndex = i;
    switch (_selectedColorIndex) {
        case 0:            
            self.pixView.highlightColor = [UIColor blackColor];
            break;
        case 1:
            self.pixView.highlightColor = [UIColor redColor];
            break;
        case 2:
            self.pixView.highlightColor = [UIColor greenColor];
            break;
        default:
        break; }
    [self.pixView setNeedsDisplay];
}

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}

- (IBAction)chooseColor:(id)sender {
    NSInteger selectedColorIndex = [(UISegmentedControl *)sender
                                    selectedSegmentIndex];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:selectedColorIndex forKey:@"selectedColorIndex"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    UIDocument *doc = self.detailItem;
    [doc closeWithCompletionHandler:nil];
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.pixView.document = self.detailItem;
        [self.pixView setNeedsDisplay];
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.selectedColorIndex = [prefs integerForKey:@"selectedColorIndex"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
