//
//  BIDMasterViewController.m
//  TinyPix
//
//  Created by 李 潇磊 on 13-5-27.
//  Copyright (c) 2013年 李 潇磊. All rights reserved.
//

#import "BIDMasterViewController.h"
#import "BIDDetailViewController.h"
#import "BIDTinyPixDocument.h"

@interface BIDMasterViewController () <UIAlertViewDelegate>

@property (strong, nonatomic) NSArray *documentFilenames;
@property (strong, nonatomic) BIDTinyPixDocument *chosenDocument;
- (NSURL *)urlForFilename:(NSString *)filename;
- (void)reloadFiles;

@end

@implementation BIDMasterViewController

- (NSURL *)urlForFilename:(NSString *)filename {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *urls = [fm URLsForDirectory:NSDocumentDirectory
                               inDomains:NSUserDomainMask];
    NSURL *directoryURL = urls[0];
    NSURL *fileURL = [directoryURL URLByAppendingPathComponent:filename];
    return fileURL;
}

- (void)reloadFiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *path = paths[0];
    NSFileManager *fm = [NSFileManager defaultManager];
    NSError *dirError;
    NSArray *files = [fm contentsOfDirectoryAtPath:path error:&dirError];
    if (!files) {
        NSLog(@"Encountered error while trying to list files in directory %@: %@",
              path, dirError);
    }
    NSLog(@"found files: %@", files);
    files = [files sortedArrayUsingComparator:
             ^NSComparisonResult(id filename1, id filename2) {
                 NSDictionary *attr1 = [fm attributesOfItemAtPath:
                                        [path stringByAppendingPathComponent:filename1]
                                                            error:nil];
                 NSDictionary *attr2 = [fm attributesOfItemAtPath:
                                        [path stringByAppendingPathComponent:filename2]
                                                            error:nil];
                 return [attr2[NSFileCreationDate] compare: attr1[NSFileCreationDate]];
             }];
    self.documentFilenames = files;
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.documentFilenames count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FileCell"];
    NSString *path = self.documentFilenames[indexPath.row];
    cell.textLabel.text = path.lastPathComponent.stringByDeletingPathExtension;
    return cell;
}

- (IBAction)chooseColor:(id)sender {
    NSInteger selectedColorIndex = [(UISegmentedControl *)sender selectedSegmentIndex];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setInteger:selectedColorIndex forKey:@"selectedColorIndex"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSInteger selectedColorIndex = [prefs integerForKey:@"selectedColorIndex"];
    self.colorControl.selectedSegmentIndex = selectedColorIndex;
}

@end
