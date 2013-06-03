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

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                  target:self
                                  action:@selector(insertNewObject)];
    self.navigationItem.rightBarButtonItem = addButton;
    [self reloadFiles];
}

- (void)insertNewObject {
    // get the name
    UIAlertView *alert =
    [[UIAlertView alloc] initWithTitle:@"Filename"
                               message:@"Enter a name for your new TinyPix document."
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"Create", nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView
didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *filename = [NSString stringWithFormat:@"%@.tinypix",
                              [alertView textFieldAtIndex:0].text];
        NSURL *saveUrl = [self urlForFilename:filename];
        self.chosenDocument = [[BIDTinyPixDocument alloc] initWithFileURL:saveUrl];
        [self.chosenDocument saveToURL:saveUrl
                      forSaveOperation:UIDocumentSaveForCreating
                        completionHandler:^(BOOL success) {
                         if (success) {
                             NSLog(@"save OK");
                             [self reloadFiles];
                             [self performSegueWithIdentifier:@"masterToDetail"
                                                       sender:self];
                         } else {
                             NSLog(@"failed to save!");
                         } }];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender == self) {
        // if sender == self, a new document has just been created,
        // and chosenDocument is already set.
        UIViewController *destination = segue.destinationViewController;
        if ([destination respondsToSelector:@selector(setDetailItem:)]) {
            [destination setValue:self.chosenDocument forKey:@"detailItem"];
        }
    } else {
        // find the chosen document from the tableview
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSString *filename = self.documentFilenames[indexPath.row];
        NSURL *docUrl = [self urlForFilename:filename];
        self.chosenDocument = [[BIDTinyPixDocument alloc] initWithFileURL:docUrl];
        [self.chosenDocument openWithCompletionHandler:^(BOOL success) {
            if (success) {
                NSLog(@"load OK");
                UIViewController *destination = segue.destinationViewController;
                if ([destination respondsToSelector:@selector(setDetailItem:)]) {
                    [destination setValue:self.chosenDocument forKey:@"detailItem"];
                }
            } else {
                NSLog(@"failed to load!");
            } }];
    }
}

@end
