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

/// Creates rows insertion event
///
/// @param items
/// model objects used as backing items for cells.
///
/// @param location
/// location for events to inserted at as NSIndexPath object - section and row
///
/// @return an event object describing items insertion
+ (instancetype)insertRowsEvent:(NSArray *)items atLocation:(NSIndexPath *)location;

/// Creates rows deletion event
///
/// @param count
/// number of items to be deleted. Should be not more than number objects starting
///	at given row till the end of array.
///
/// @param location
/// location for events to inserted at as NSIndexPath object - section and row
///
/// @return An event object describing items deletion.
+ (instancetype)deleteRowsEvent:(NSUInteger)count atLocation:(NSIndexPath *)location;

/// Creates rows insertion event
///
/// @param index
/// index for the section to be inserted at.
///
/// @param items
/// items the new section to be initially populated with.
///
/// @return An event object describing section insertion
+ (instancetype)insertSectionAtIndexEvent:(NSUInteger)index withItems:(NSArray *)items;

/// Creates rows deletion event
///
/// @param index
/// index for the section to be deleted at.
///
/// @return An event object describing section deletion.
+ (instancetype)deleteSectionAtIndexEvent:(NSUInteger)index;
@end

@interface SRGTableViewReactiveAdapter : NSObject <UITableViewDataSource>

/// Initializes instance with a given tableView and initial datasource state.
///
/// @param tableView
/// UITableView this instance to be used with
///
/// @param array
/// 2-dimensional array with model object items used as initial state for
///	internal UITableView datasource representation.
///
/// @return Initizlied instance.
- (instancetype)initWithTableView:(UITableView *)tableView
				 withInitialState:(NSArray *)array;

/// Subscriber for UITableView source events. Can be used for RACSignal to subscribe to.
- (id<RACSubscriber>)sourceEventsSubscriber;

/// Number of sections in internal UITableView datasource representation.
- (NSUInteger)numberOfSections;

/// Number of sections in internal UITableView datasource representation.
///
/// @param section
/// section to query number of rows in.
///
///
/// @return Number of items in specified section.
- (NSUInteger)numberOfRowsInSection:(NSUInteger)section;

/// Item at the location in internal UITableView datasource representation.
///
/// @param indexPath
/// location to query item at.
///
///
/// @return Model object backing item for the cell at the specified location.
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

/// UITableView's pass-through datasource.
/// @discussion SRGTableViewReactiveAdapter inserts itself as a datasource for a `UITableView`.
/// Only -numberOfSections and -numberOfRowsInSection: are actually used. All other UITableViewDatasource methods
/// are forwarded to object set by this property.
/// Upon initialization, this property is automatically set to whatever UITableView instance had before.
@property (nonatomic, weak) id<UITableViewDataSource> dataSource;

@end
