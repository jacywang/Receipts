//
//  Receipt.h
//  Receipts
//
//  Created by JIAN WANG on 6/12/15.
//  Copyright (c) 2015 JWANG. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Label;

@interface Receipt : NSManagedObject

@property (nonatomic, retain) NSNumber * amount;
@property (nonatomic, retain) NSString * receiptDescription;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSSet *label;
@end

@interface Receipt (CoreDataGeneratedAccessors)

- (void)addLabelObject:(Label *)value;
- (void)removeLabelObject:(Label *)value;
- (void)addLabel:(NSSet *)values;
- (void)removeLabel:(NSSet *)values;

@end
