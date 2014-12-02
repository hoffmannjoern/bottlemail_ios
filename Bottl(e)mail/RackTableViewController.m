//
//  MainTableViewController.m
//  Bottl(e)mail
//
//  Created by Jörn Hoffmann on 30.11.14.
//  Copyright (c) 2014 Jörn Hoffmann. All rights reserved.
//

#import "RackTableViewController.h"
#import "MessagesViewController.h"
#import "ModelData.h"
#import "NSUserDefaults+Settings.h"

static NSString *const segueToMessages = @"SegueToMessages";
static NSString *const segueToSettings = @"SegueToSettings";

typedef NS_ENUM(NSUInteger, Section) {
  SectionBottles = 0,
  SectionSettings,
  SectionCount
};

@interface RackTableViewController ()
{
  NSUInteger _selectedRow;
  NSMutableArray *rssi;
  NSTimer *_timer;
}

@end

@implementation RackTableViewController

// ------------------------------------------------------------------------------------------------------------------ //
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return SectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  if (section == SectionBottles)
  {
    NSUInteger bottles = [NSUserDefaults bottlesNumber];
    rssi = [[NSMutableArray alloc] initWithCapacity:bottles];
    
    for (int i = 0; i < bottles; i++) {
      [rssi addObject:@(-40 - (10 * ((rand() % 5))) - ((rand() % 10) +1))];
    }
    
    return bottles;
  }
  
  else if (section == SectionSettings)
    return 1;
  
  else
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Fetch cell
  static NSString *cellIdentifier = @"BottleCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
  
  // Set content
  NSString *text = @"";
  NSString *detail = @"";
  NSUInteger section = indexPath.section;
  if (section == SectionBottles)
  {
    text = [NSString stringWithFormat:@"Bottle %lu", (unsigned long)indexPath.row];
    detail = ((NSNumber *)rssi[indexPath.row]).stringValue;
  }
  
  else if (indexPath.section == SectionSettings)
  {
    text = @"Settings";
  }
  
  // Set cell
  cell.textLabel.text = text;
  cell.detailTextLabel.text = detail;
  return cell;
}

// ------------------------------------------------------------------------------------------------------------------ //
#pragma mark - Table view delegate

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  const NSUInteger section = indexPath.section;
  const NSUInteger row = indexPath.row;
  _selectedRow = row;
  
  // Settings
  if (section == SectionSettings && row == 0)
    [self performSegueWithIdentifier:segueToSettings sender:self];
  
  else
    [self performSegueWithIdentifier:segueToMessages sender:self];
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
  if ([segue.identifier isEqualToString:segueToMessages])
  {
    MessagesViewController *mvc = segue.destinationViewController;
    if (![mvc isKindOfClass:[MessagesViewController class]])
      return;
    
    mvc.modelData = [[ModelData alloc] initBottleIndex:_selectedRow];
  }
}

#pragma mark - View controller overrides

-(void)updateRSSI:(NSTimer*)timer
{
  [self.tableView reloadData];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // Uncomment the following line to preserve selection between presentations.
  // self.clearsSelectionOnViewWillAppear = NO;
  
  // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
  // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  
  // Set background image
  self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_blurred"]];
  self.tableView.backgroundView.contentMode = UIViewContentModeScaleAspectFit;
}

-(void)viewDidAppear:(BOOL)animated
{
  [super viewDidAppear:animated];
  [self.tableView reloadData];
  
  _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateRSSI:) userInfo:nil repeats:true];
}

-(void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  [_timer invalidate];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}




@end
