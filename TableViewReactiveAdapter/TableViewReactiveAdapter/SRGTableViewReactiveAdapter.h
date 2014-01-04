//
//  SRGTableViewReactiveAdapter.h
//  TestApplication
//
//  Created by Sergey Gavrilyuk on 12/25/13.
//  Copyright (c) 2013 Sergey Gavrilyuk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ReactiveCocoa.h>

@interface SRGTableViewContentModificationEvent : NSObject

+ (instancetype)insertRowsEvent:(NSArray *)items atLocation:(NSIndexPath *)location;
+ (instancetype)deleteRowsEvent:(NSUInteger)count atLocation:(NSIndexPath *)location;

@end

@interface SRGTableViewReactiveAdapter : NSObject <UITableViewDataSource>

- (instancetype)initWithTableView:(UITableView *)tableView
				 withInitialState:(NSArray *)array
			  withCellTuningBlock:(UITableViewCell *(^)(UITableView* tableView, NSIndexPath *indexPath, id item))cellBlock;

- (id<RACSubscriber>)sourceEventsSubscriber;

- (NSUInteger)numberOfSections;
- (NSUInteger)numberOfRowsInSection:(NSUInteger)section;
@end
