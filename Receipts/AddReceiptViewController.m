//
//  AddReceiptViewController.m
//  Receipts
//
//  Created by JIAN WANG on 6/12/15.
//  Copyright (c) 2015 JWANG. All rights reserved.
//

#import "AddReceiptViewController.h"
#import "AppDelegate.h"
#import "Receipt.h"
#import "Label.h"

@interface AddReceiptViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

@property (nonatomic) NSMutableArray *labels;
@property (nonatomic) NSMutableArray *selectedCategories;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextfield;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation AddReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.labels = [NSMutableArray arrayWithObjects:@"Personal", @"Family", @"Business", nil];
    self.datePicker.maximumDate = [NSDate date];
    self.selectedCategories = [[NSMutableArray alloc] init];
}

- (IBAction)dismissViewController:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = appDelegate.managedObjectContext ;
    
    if ([self.amountTextField.text isEqualToString:@""] || [self.descriptionTextfield.text isEqualToString:@""] || [self.tableView indexPathsForSelectedRows].count == 0) {
        [self.selectedCategories removeAllObjects];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Amount, description and category cannot be empty!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        
        NSEntityDescription *labelEntity = [NSEntityDescription entityForName:@"Label" inManagedObjectContext:context];
        
        for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
            Label *label = [[Label alloc] initWithEntity:labelEntity insertIntoManagedObjectContext:context];
            label.labelName = self.labels[indexPath.row];
            // Save the context.
            NSError *error = nil;
            if (![context save:&error]) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                abort();
            } else {
                [self.selectedCategories addObject:label];
            }
        }
                
        NSEntityDescription *receiptEntity = [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:context];
        
        Receipt *receipt = [[Receipt alloc] initWithEntity:receiptEntity insertIntoManagedObjectContext:context];
        receipt.amount = [NSNumber numberWithFloat:[self.amountTextField.text floatValue]];
        receipt.receiptDescription = self.descriptionTextfield.text;
        receipt.timeStamp = self.datePicker.date;
        receipt.label = [NSSet setWithArray:self.selectedCategories];
            
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
        
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

- (IBAction)datePickerValueChanged:(UIDatePicker *)sender {
    [self.view endEditing:YES];
}

#pragma mark - UITableViewDataSource

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.labels.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.textLabel.text = self.labels[indexPath.row];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Category";
}

#pragma mark - UITableViewDelegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.view endEditing:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

#pragma mark - UITextFieldDelegeate

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
