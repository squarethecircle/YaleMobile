//
//  YMPeopleDetailViewController.m
//  YaleMobile
//
//  Created by Danqing on 1/5/13.
//  Copyright (c) 2013 Danqing Liu. All rights reserved.
//

#import "YMPeopleDetailViewController.h"
#import "YMSubtitleCell.h"
#import "YMGlobalHelper.h"
#import "UIImage+Emboss.h"

#import "YMTheme.h"

@interface YMPeopleDetailViewController ()

@end

@implementation YMPeopleDetailViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
  self.tableView1.backgroundColor = [UIColor clearColor];
  
  [self prettifyData];
  [self updateTableHeader];
}

- (void)back:(id)sender
{
  [[self navigationController] popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)prettifyData
{
  NSMutableDictionary *result = [[NSMutableDictionary alloc] initWithCapacity:self.data.count];
  NSArray *keys = [[self.data allKeys] sortedArrayUsingSelector:@selector(compare:)];
  for (NSString *raw in keys) {
    NSString *index = [raw stringByReplacingOccurrencesOfString:@":" withString:@""];
    index = [index stringByReplacingOccurrencesOfString:@"Student Phone" withString:@"Phone"];
    index = [index stringByReplacingOccurrencesOfString:@"Residential College Name" withString:@"College"];
    index = [index stringByReplacingOccurrencesOfString:@"Email Address" withString:@"Email"];
    index = [index stringByReplacingOccurrencesOfString:@"Office Phone" withString:@"Phone"];
    index = [index stringByReplacingOccurrencesOfString:@"Organization" withString:@"Org"];
    index = [index stringByReplacingOccurrencesOfString:@"Home Org ID" withString:@"Org ID"];
    [result setObject:[self.data objectForKey:raw] forKey:index];
  }
  self.data = result;
}

- (void)updateTableHeader
{
  UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(28, 18, 266, 28)];
  NSString *headerString = [self.data valueForKey:@"Name"];
  UIFont *headerFont = [UIFont fontWithName:@"HelveticaNeue-Medium" size:19];
  /* deprecated
   CGSize headerSize = [headerString sizeWithFont:headerFont constrainedToSize:CGSizeMake(266, 1000)];
   */
  CGSize headerSize = [YMGlobalHelper boundText:headerString withFont:headerFont andConstraintSize:CGSizeMake(266, 1000)];
  CGRect headerFrame = header.frame;
  headerFrame.size.height = headerSize.height;
  header.frame = headerFrame;
  header.text = headerString;
  header.font = headerFont;
  header.textColor = [UIColor colorWithRed:111/255.0 green:132/255.0 blue:132/255.0 alpha:1];
  header.numberOfLines = 0;
  
  NSString *subheaderString = @"";
  
  for (NSString *item in [self.data allKeys]) {
    if ([item isEqualToString:@"Title"]) {
      subheaderString = [self.data valueForKey:item];
      [self.data removeObjectForKey:item];
    } else if ([item isEqualToString:@"Division"] && [subheaderString isEqualToString:@""]) {
      subheaderString = [self.data valueForKey:item];
      [self.data removeObjectForKey:item];
    } else if ([item isEqualToString:@"Curriculum Code"] || [item isEqualToString:@"Office Address"] || [item isEqualToString:@"Residential College"] || [item isEqualToString:@"Name"]) [self.data removeObjectForKey:item];
  }
  
  if ([subheaderString isEqualToString:@""]) subheaderString = @"Yale University";
  
  UILabel *subheader = [[UILabel alloc] initWithFrame:CGRectMake(28, 22 + header.frame.size.height, 260, 28)];
  UIFont *subheaderFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
  /* deprecated
  CGSize subheaderSize = [subheaderString sizeWithFont:subheaderFont constrainedToSize:CGSizeMake(266, 1000)];
   */
  CGSize subheaderSize = [YMGlobalHelper boundText:subheaderString withFont:subheaderFont andConstraintSize:CGSizeMake(266, 1000)];
  CGRect subheaderFrame = subheader.frame;
  subheaderFrame.size.height = subheaderSize.height;
  subheader.frame = subheaderFrame;
  subheader.text = subheaderString;
  subheader.font = subheaderFont;
  subheader.textColor = [UIColor lightGrayColor];
  subheader.numberOfLines = 0;
  header.backgroundColor = [UIColor clearColor]; subheader.backgroundColor = [UIColor clearColor];
  
  UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 25 + header.frame.size.height + subheader.frame.size.height)];
  
  [containerView setBackgroundColor:[UIColor clearColor]];
  
  [containerView addSubview:header];
  [containerView addSubview:subheader];
  //[containerView addSubview:divider];
  self.tableView1.tableHeaderView = containerView;
  [self.tableView1 reloadData];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
  switch (result) {
    case MFMailComposeResultCancelled:
      DLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
      break;
    case MFMailComposeResultSaved:
      DLog(@"Mail saved: you saved the email message in the drafts folder.");
      break;
    case MFMailComposeResultSent:
      DLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
      break;
    case MFMailComposeResultFailed:
      DLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
      break;
    default:
      DLog(@"Mail not sent.");
      break;
  }
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)createActionSheetWithNumber:(NSString *)number
{
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Do you want to call %@? For undergraduate this is the number of dorm landline, which is usually not set up.", number] delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:[NSString stringWithFormat:@"Call %@", number], @"Copy to Clipboard", nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
  [actionSheet showInView:self.view];
}

- (void)createActionSheetWithString:(NSString *)string
{
  UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Copy to Clipboard", nil];
  actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
  [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex != [actionSheet cancelButtonIndex]) [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.phoneURL]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  YMSubtitleCell *cell = (indexPath.row == 0) ? (YMSubtitleCell *)[tableView dequeueReusableCellWithIdentifier:@"People Detail Top Cell"] : (YMSubtitleCell *)[tableView dequeueReusableCellWithIdentifier:@"People Detail Cell"];
  NSString *title = [[[self.data allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row];
  cell.secondary1.text = title;
  cell.primary1.text = [self.data objectForKey:title];
  
  /* Shouldn't do this because we're using LayoutConstraints in SB, the label should determine its size
   * automatically through its content.
//  CGSize textSize = [[self.data objectForKey:title] sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:15.0f] constrainedToSize:CGSizeMake(200.0f, 1000.0f)];
//
//  CGSize textSize2 = [YMGlobalHelper boundText:title withFont:[UIFont fontWithName:@"HelveticaNeue" size:12] andConstraintSize:CGSizeMake(60.0f, 5000.0f)];
//  
//  CGRect primaryFrame = cell.primary1.frame;
//  primaryFrame.size.height = textSize.height;
//  cell.primary1.frame = primaryFrame;
//  
//  CGRect secondaryFrame = cell.secondary1.frame;
//  secondaryFrame.size.height = textSize2.height;
//  cell.secondary1.frame = secondaryFrame;
  */
  
  if (self.data.count == 1) {
    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"shadowbg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"shadowbg_highlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 20, 20)]];
  } else if (indexPath.row == 0) {
    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tablebg_top.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 5, 20)]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tablebg_top_highlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, 20, 5, 20)]];
  } else if (indexPath.row < (self.data.count - 1)) {
    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tablebg_mid.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 10, 20)]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tablebg_mid_highlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 10, 20)]];
  } else {
    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tablebg_bottom.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 10, 20)]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"tablebg_bottom_highlight.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 20, 10, 20)]];
  }
  
  cell.userInteractionEnabled = ([title isEqualToString:@"Email"] || [title isEqualToString:@"Phone"]) ? YES : NO;
  
  
  cell.primary1.textColor = [YMTheme gray];
  cell.secondary1.textColor = [YMTheme lightGray];
  cell.backgroundView.alpha = 0.6;
  
  return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  NSString *title = [[[self.data allKeys] sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:indexPath.row];
  NSString *value = [self.data objectForKey:title];
  
  /* deprecated
  CGSize textSize = [value sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f] constrainedToSize:CGSizeMake(200.0f, 1000.0f)];
  CGSize textSize2 = [title sizeWithFont:[UIFont fontWithName:@"HelveticaNeue" size:12] constrainedToSize:CGSizeMake(60.0f, 5000.0f)];
   */
  CGSize textSize = [YMGlobalHelper boundText:value withFont:[UIFont fontWithName:@"HelveticaNeue" size:15.0f] andConstraintSize:CGSizeMake(200.0f, 1000.0f)];
  CGSize textSize2 = [YMGlobalHelper boundText:title withFont:[UIFont fontWithName:@"HelveticaNeue" size:12] andConstraintSize:CGSizeMake(60.0f, 5000.0f)];
  
  if (self.data.count == 1) return MAX(textSize.height, textSize2.height) + 40;
  return (indexPath.row == 0 || indexPath.row == self.data.count - 1) ? MAX(textSize.height, textSize2.height) + 33 : MAX(textSize.height, textSize2.height) + 23;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  [self.tableView1 deselectRowAtIndexPath:indexPath animated:YES];
  YMSubtitleCell *cell = (YMSubtitleCell *)[tableView cellForRowAtIndexPath:indexPath];
  if ([cell.secondary1.text isEqualToString:@"Email"]) {
    if ([MFMailComposeViewController canSendMail]) {
      MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
      mailer.mailComposeDelegate = self;
      NSArray *toRecipients = [NSArray arrayWithObjects:cell.primary1.text, nil];
      [[mailer navigationBar] setTintColor:[UIColor whiteColor]];
      [mailer setToRecipients:toRecipients];
      [self presentViewController:mailer animated:YES completion:nil];
    } else {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"YaleMobile is unable to launch the email service. Your device doesn't support the composer sheet."
                                                     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
      [alert show];
    }
  }
  if ([cell.secondary1.text isEqualToString:@"Phone"]) {
    NSString *phoneNo = cell.primary1.text;
    if (phoneNo.length < 11) phoneNo = [@"203-" stringByAppendingString:phoneNo];
    self.phoneURL = [@"tel://" stringByAppendingString:phoneNo];
    [self createActionSheetWithNumber:phoneNo];
  }
}

@end
