//
//  SRGTableViewReactiveAdapter.m
//  TestApplication
//
//  Created by Sergey Gavrilyuk on 12/25/13.
//  Copyright (c) 2013 Sergey Gavrilyuk. All rights reserved.
//

#import "SRGTableViewReactiveAdapter.h"

#import <libextobjc/extobjc.h>
#import "NSIndexSet+RACSequenceAdditions.h"

typedef NS_ENUM(NSUInteger, SRGContentModificationEventType) {
	SRGInsertRows,
	SRGDeleteRows,
	SRGInsertSection,
	SRGDeleteSection
};


#pragma mark - Events interface

@interface SRGTableViewContentModificationEvent ()

@property (nonatomic, readonly) SRGContentModificationEventType eventType;

@property (nonatomic, readonly) NSArray *items;

+ (instancetype)insertRowsEvent:(NSArray *)items atLocation:(NSIndexPath *)location;
+ (instancetype)deleteRowsEvent:(NSUInteger)count atLocation:(NSIndexPath *)location;
+ (instancetype)insertSectionAtIndexEvent:(NSUInteger)index withItems:(NSArray *)items;
+ (instancetype)deleteSectionAtIndexEvent:(NSUInteger)index;
@end


@interface SRGRowsModificationEvent : SRGTableViewContentModificationEvent

@property (nonatomic, readonly) NSIndexPath *location;
@property (nonatomic, readonly) NSUInteger count;

- (instancetype)initWithInsertItems:(NSArray *)items atLocation:(NSIndexPath *)location;
- (instancetype)initWithDeleteItemsCount:(NSUInteger)count atLocation:(NSIndexPath *)location;

@end


@interface SRGSectionModificationEvent : SRGTableViewContentModificationEvent
@property (nonatomic, readonly) NSUInteger index;

- (instancetype)initWithInsertIndex:(NSUInteger)index items:(NSArray *)items;
- (instancetype)initWithDeleteIndex:(NSUInteger)index;

@end

#pragma mark - Events implementation

@implementation SRGTableViewContentModificationEvent

- (instancetype)initWithEventType:(SRGContentModificationEventType)eventType items:(NSArray *)items {
	self = [super init];
	if (self) {
		_eventType = eventType;
		_items = items;
	}
	return self;
}

+ (instancetype)insertRowsEvent:(NSArray *)items atLocation:(NSIndexPath *)location {
	return [[SRGRowsModificationEvent alloc] initWithInsertItems:items atLocation:location];
}

+ (instancetype)deleteRowsEvent:(NSUInteger)count atLocation:(NSIndexPath *)location {
	return [[SRGRowsModificationEvent alloc] initWithDeleteItemsCount:count atLocation:location];
}

+ (instancetype)insertSectionAtIndexEvent:(NSUInteger)index withItems:(NSArray *)items {
	return [[SRGSectionModificationEvent alloc] initWithInsertIndex:index items:items];
}

+ (instancetype)deleteSectionAtIndexEvent:(NSUInteger)index {
	return [[SRGSectionModificationEvent alloc] initWithDeleteIndex:index];
}

@end

@implementation SRGRowsModificationEvent

- (instancetype)initWithInsertItems:(NSArray *)items atLocation:(NSIndexPath *)location {
	self = [super initWithEventType:SRGInsertRows items:items];
	if (self) {
		_location = location;
		_count = items.count;
	}
	return self;
}

- (instancetype)initWithDeleteItemsCount:(NSUInteger)count atLocation:(NSIndexPath *)location {
	self = [super initWithEventType:SRGDeleteRows items:nil];
	if (self) {
		_location = location;
		_count = count;
	}
	return self;
}

- (NSString *)description {
	if (self.eventType == SRGInsertRows) {
		return [NSString stringWithFormat:@"Insert rows at %d, count %d", self.location.row, self.count];
	}
	else {
		return [NSString stringWithFormat:@"Delete rows at %d, count %d", self.location.row, self.count];
	}
}

@end


@implementation SRGSectionModificationEvent

- (instancetype)initWithInsertIndex:(NSUInteger)index items:(NSArray *)items {
	self = [super initWithEventType:SRGInsertSection items:items];
	if (self) {
		_index = index;
	}
	return self;
}

- (instancetype)initWithDeleteIndex:(NSUInteger)index {
	self = [super initWithEventType:SRGDeleteSection items:nil];
	if (self) {
		_index = index;
	}
	return self;
}

- (NSString *)description {
	if (self.eventType == SRGInsertSection) {
		return [NSString stringWithFormat:@"Insert section at %d", self.index];
	}
	else {
		return [NSString stringWithFormat:@"Delete section at %d", self.index];
	}
}

@end

#pragma mark - SRGTableViewIntermediateState

@interface SRGTableViewIntermediateState : NSObject
{
	NSMutableArray *_initialState;
	NSMutableArray *_deleteIndexPaths;
	NSMutableIndexSet *_deletedSections;
}


- (instancetype)initWithInitialState:(NSArray *)tableViewSource;

- (void)insertRows:(NSUInteger)count atLocation:(NSIndexPath *)location;
- (void)deleteRows:(NSUInteger)count atLocation:(NSIndexPath *)location;

- (void)insertSection:(NSUInteger)index;
- (void)deleteSection:(NSUInteger)index;

- (void)flushAndResetToState:(NSArray *)tableViewSource
				  flushBlock:(void (^)(NSArray *rowsToDelete, NSIndexSet *sectionsToDelete, NSArray *rowsToInsert, NSIndexSet *sectionsToInsert)) flushBlock;

@end

@implementation SRGTableViewIntermediateState

- (void)initInitialState:(NSArray *)tableViewSource {
	_initialState = [NSMutableArray array];
	
	[tableViewSource enumerateObjectsUsingBlock:^(NSArray *subArray, NSUInteger sectionIdx, BOOL *stop) {
		NSAssert([subArray isKindOfClass:[NSArray class]], @"tableViewSource should be two-dimensional array");
		NSMutableArray *arr = [NSMutableArray array];
		for (NSUInteger rowIdx = 0; rowIdx < subArray.count; ++rowIdx) {
			[arr addObject:@(rowIdx)];
		}
		[_initialState addObject: @{@"sectionIdnex":@(sectionIdx), @"rows":arr}];
	}];
}

- (instancetype)initWithInitialState:(NSArray *)tableViewSource {
	self = [super init];
	if (self) {
		[self initInitialState:tableViewSource];
		_deleteIndexPaths = [NSMutableArray array];
		_deletedSections = [NSMutableIndexSet indexSet];

	}
	return self;
}

- (void)insertRows:(NSUInteger)count atLocation:(NSIndexPath *)location {
	while (count--) {
		[_initialState[location.section][@"rows"] insertObject:NSNull.null atIndex:location.row];
	}
}

- (void)deleteRows:(NSUInteger)count atLocation:(NSIndexPath *)location {
	while (count--) {
		if (_initialState[location.section][@"rows"][location.row + count] != NSNull.null) {
			[_deleteIndexPaths addObject:[NSIndexPath indexPathForRow:[_initialState[location.section][@"rows"][location.row + count] unsignedIntegerValue]
															inSection:location.section]];
		}
		[_initialState[location.section][@"rows"] removeObjectAtIndex:location.row + count];

	}
}

- (void)insertSection:(NSUInteger)index {
	[_initialState insertObject:NSNull.null atIndex:index];
}

- (void)deleteSection:(NSUInteger)index {
	if (_initialState[index] != NSNull.null) {
		[_deletedSections addIndex:[_initialState[index][@"sectionIdnex"] unsignedIntegerValue]];
	}
	[_initialState removeObjectAtIndex:index];
}


- (void)flushAndResetToState:(NSArray *)tableViewSource
				  flushBlock:(void (^)(NSArray *rowsToDelete, NSIndexSet *sectionsToDelete, NSArray *rowsToInsert, NSIndexSet *sectionsToInsert)) flushBlock  {
	if (flushBlock) {
		NSMutableArray *insertIndexPaths = [NSMutableArray array];
		NSMutableIndexSet *insertSections = [NSMutableIndexSet indexSet];
		[_initialState enumerateObjectsUsingBlock:^(NSDictionary *rowDict, NSUInteger idx, BOOL *stop) {
			if ([rowDict isKindOfClass: NSNull.class]) {
				[insertSections addIndex:idx];
			}
			else {
				[rowDict[@"rows"] enumerateObjectsUsingBlock:^(NSNumber *row, NSUInteger rowIdx, BOOL *stop) {
					if ([row isKindOfClass:NSNull.class]) {
						[insertIndexPaths addObject:[NSIndexPath indexPathForRow:rowIdx inSection:idx]];
					}
				}];
			}
		}];
		
		flushBlock(_deleteIndexPaths, _deletedSections, insertIndexPaths, insertSections);
	}
	
	[self initInitialState:tableViewSource];
	
	[_deletedSections removeAllIndexes];
	[_deleteIndexPaths removeAllObjects];
}

@end

#pragma mark - SRGTableViewReactiveAdapter

@interface SRGTableViewReactiveAdapter ()

@property (nonatomic) RACCommand *flushCommand;

@property (nonatomic) UITableView *tableView;
@property (nonatomic, copy) UITableViewCell *(^tableViewCellBlock)(UITableView *tableVew, NSIndexPath *indexPath, id item);
@property (nonatomic) RACSubject *sourceEventsSignal;

@property (nonatomic) NSMutableArray *tableViewSource;

@property (nonatomic) SRGTableViewIntermediateState *intermediateState;
@end

@implementation SRGTableViewReactiveAdapter

- (instancetype)initWithTableView:(UITableView *)tableView
				 withInitialState:(NSArray *)array
			  withCellTuningBlock:(UITableViewCell *(^)(UITableView *, NSIndexPath *, id item))cellBlock {
	self = [super init];
	self.tableView = tableView;
	self.tableView.dataSource = self;
	self.flushCommand = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
		return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
			[self processTableViewFlush];
			// since flushCommand has concurrentExecution turned off, this delay will
			// ensure flush is performed not more frequent than this delay. (so tableView can finish it's animations safely)
			[[RACScheduler mainThreadScheduler] afterDelay:.33 schedule:^{
				[subscriber sendCompleted];
			}];
			return nil;
		}];
	}];
	self.sourceEventsSignal = [RACSubject subject];
	self.tableViewCellBlock = cellBlock;
	
	NSMutableArray *arr = [NSMutableArray array];
	for (NSArray *innerArr in array) {
		[arr addObject:innerArr.mutableCopy];
	}
	self.tableViewSource = arr;
	self.intermediateState = [[SRGTableViewIntermediateState alloc] initWithInitialState:self.tableViewSource];
	[self initRelations];
	return self;
}

- (void)initRelations {
	
	RACSignal *allEventsSignal = [self.sourceEventsSignal filter:^BOOL(SRGTableViewContentModificationEvent *value) {
		return [value isKindOfClass:[SRGTableViewContentModificationEvent class]];
	}];

	
	RACSignal *rowsEventSignal = [self.sourceEventsSignal filter:^BOOL(SRGRowsModificationEvent *value) {
		return [value isKindOfClass:[SRGRowsModificationEvent class]];
	}];

	RACSignal *sectionsSignal = [allEventsSignal filter:^BOOL(SRGSectionModificationEvent *value) {
		return [value isKindOfClass:[SRGSectionModificationEvent class]];
	}];
	
	[self rac_liftSelector:@selector(processInsertSectionEvent:)
			   withSignals:[sectionsSignal filter:^BOOL(SRGSectionModificationEvent *value) {
		return value.eventType == SRGInsertSection;
	}], nil];

	[self rac_liftSelector:@selector(processDeleteSectionEvent:)
			   withSignals:[sectionsSignal filter:^BOOL(SRGSectionModificationEvent *value) {
		return value.eventType == SRGDeleteSection;
	}], nil];

	[self rac_liftSelector:@selector(processInsertRowsEvent:) withSignals:[rowsEventSignal filter:^BOOL(SRGRowsModificationEvent *event) {
		return event.eventType == SRGInsertRows;
	}], nil];
	
	[self rac_liftSelector:@selector(processDeleteRowsEvent:) withSignals:[rowsEventSignal filter:^BOOL(SRGRowsModificationEvent *event) {
		return event.eventType == SRGDeleteRows;
	}], nil];
	

	[self.flushCommand rac_liftSelector:@selector(execute:) withSignals:[allEventsSignal logNext], nil];
}


#pragma mark - private helper methods

- (void)processInsertRowsEvent:(SRGRowsModificationEvent *)event {
	
	NSIndexSet *indexSetToInsertAt = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(event.location.row, event.count)];

	[self.intermediateState insertRows:event.count atLocation:event.location];
	[self.tableViewSource[event.location.section] insertObjects:event.items
							  atIndexes:indexSetToInsertAt];
}

- (void)processDeleteRowsEvent:(SRGRowsModificationEvent *)event {
	NSIndexSet *indexSetToDeleteFrom = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(event.location.row, event.count)];
	[self.tableViewSource[event.location.section] removeObjectsAtIndexes:indexSetToDeleteFrom];
	[self.intermediateState deleteRows:event.count atLocation:event.location];
	
}

- (void)processInsertSectionEvent:(SRGSectionModificationEvent *)event {
	[self.intermediateState insertSection:event.index];
	[self.tableViewSource insertObject:event.items atIndex:event.index];
}

- (void)processDeleteSectionEvent:(SRGSectionModificationEvent *)event {
	[self.tableViewSource removeObjectAtIndex:event.index];
	[self.intermediateState deleteSection:event.index];
}

- (void)processTableViewFlush {
	NSLog(@"Flushing TableView");
	
	[self.intermediateState flushAndResetToState: self.tableViewSource
									  flushBlock:^(NSArray *rowsToDelete, NSIndexSet *sectionsToDelete, NSArray *rowsToInsert, NSIndexSet *sectionsToInsert) {
										  [self.tableView beginUpdates];
										  
										  [self.tableView deleteRowsAtIndexPaths:rowsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
										  [self.tableView deleteSections:sectionsToDelete withRowAnimation:UITableViewRowAnimationAutomatic];
										  [self.tableView insertRowsAtIndexPaths:rowsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
										  [self.tableView deleteSections:sectionsToInsert withRowAnimation:UITableViewRowAnimationAutomatic];
										  
										  [self.tableView endUpdates];

									  }];
}


#pragma mark - public interface

- (id<RACSubscriber>)sourceEventsSubscriber {
	return self.sourceEventsSignal;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return self.tableViewSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSAssert(section < self.tableViewSource.count, @"Inconsistency: tableView asking section (%d) I don't have (%d sections)", section, self.tableViewSource.count);
	return [self.tableViewSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = nil;
	if (self.tableViewCellBlock) {
		cell = self.tableViewCellBlock(tableView, indexPath, self.tableViewSource[indexPath.section][indexPath.row]);
	}
	return cell;
}


- (NSUInteger)numberOfSections {
	return self.tableViewSource.count;
}

- (NSUInteger)numberOfRowsInSection:(NSUInteger)section {
	NSAssert(section < self.tableViewSource.count, @"Section requested (%d) not present (%d sections)", section, self.tableViewSource.count);
	return [self.tableViewSource[section] count];
}
@end
