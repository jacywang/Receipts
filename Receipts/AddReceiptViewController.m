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

@interface AddReceiptViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic) NSMutableArray *labels;
@property (nonatomic) NSArray *fetchedLabels;
@property (nonatomic) NSMutableArray *selectedCategories;
@property (weak, nonatomic) IBOutlet UITextField *amountTextField;
@property (weak, nonatomic) IBOutlet UITextField *descriptionTextfield;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation AddReceiptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.labels = [NSMutableArray arrayWithObjects:@"Personal", @"Family", @"Business", nil];
    self.datePicker.maximumDate = [NSDate date];
    self.selectedCategories = [[NSMutableArray alloc] init];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    self.fetchedLabels = [self.fetchedResultsController fetchedObjects];
}

- (IBAction)dismissViewController:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    
    if ([self.amountTextField.text isEqualToString:@""] || [self.descriptionTextfield.text isEqualToString:@""] || [self.tableView indexPathsForSelectedRows].count == 0) {
        [self.selectedCategories removeAllObjects];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"Amount, description and category cannot be empty!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        NSEntityDescription *labelEntity = [NSEntityDescription entityForName:@"Label" inManagedObjectContext:self.managedObjectContext];
        
        NSEntityDescription *receiptEntity = [NSEntityDescription entityForName:@"Receipt" inManagedObjectContext:self.managedObjectContext];
        
        Receipt *receipt = [[Receipt alloc] initWithEntity:receiptEntity insertIntoManagedObjectContext:self.managedObjectContext];
        receipt.amount = [NSNumber numberWithFloat:[self.amountTextField.text floatValue]];
        receipt.receiptDescription = self.descriptionTextfield.text;
        receipt.timeStamp = self.datePicker.date;
        
        BOOL isFound = NO;
        
        for (NSIndexPath *indexPath in [self.tableView indexPathsForSelectedRows]) {
            
            for (Label *label in self.fetchedLabels) {
                if ([label.labelName isEqualToString:self.labels[indexPath.row]]) {
                    NSMutableSet *newSet = [[NSMutableSet alloc] initWithSet:receipt.label];
                    [newSet addObject:label];
                    receipt.label = newSet;
                    isFound = YES;
                    break;
                } else {
                    isFound = NO;
                }
            }
            
            if (!isFound) {
                Label *label = [[Label alloc] initWithEntity:labelEntity insertIntoManagedObjectContext:self.managedObjectContext];
                label.labelName = self.labels[indexPath.row];
                
                NSError *error = nil;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
                    abort();
                } else {
                    NSMutableSet *newSet = [[NSMutableSet alloc] initWithSet:receipt.label];
                    [newSet addObject:label];
                    receipt.label = newSet;
                }
            }
        }
        
            
        // Save the context.
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
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

#pragma mark - NSFetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Label" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"labelName" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptor];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Detail"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}


@end
