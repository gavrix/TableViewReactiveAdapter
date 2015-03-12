//
//  SRGViewController.m
//  TableViewReactiveAdapterDemo
//
//  Created by Sergey Gavrilyuk on 1/11/14.
//  Copyright (c) 2014 Sergey Gavrilyuk. All rights reserved.
//

#import "SRGViewController.h"

@interface SRGViewController ()

@end

@implementation SRGViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	if (!self.tableViewReactiveAdapter ) {
		self.tableViewReactiveAdapter = [[ SRGTableViewReactiveAdapter alloc] initWithTableView:self.tableView
																			   withInitialState:@[@[]]];
		
	}
	
	static int cellNumber = 0;
	
	[self.tableViewReactiveAdapter.flushSignal subscribeNext:^(id x) {
		NSLog(@"***** ReactiveAdapter flushed");
	}];
	
	
	[[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
		void (^__block recurse)() = ^{
			double delayInSeconds = .25;
			dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, arc4random() % (int64_t)(delayInSeconds * NSEC_PER_SEC));
			dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
				SRGTableViewContentModificationEvent *event = nil;
				if (arc4random() % 2 || ![self.tableViewReactiveAdapter numberOfRowsInSection:0]) {
					event = [SRGTableViewContentModificationEvent insertRowsEvent:@[@(cellNumber++)] atLocation:[NSIndexPath indexPathForRow:arc4random() % ([self.tableViewReactiveAdapter numberOfRowsInSection:0] + 1)
																																   inSection:0]];
				}
				else {
					event = [SRGTableViewContentModificationEvent deleteRowsEvent:1 atLocation:[NSIndexPath indexPathForRow:arc4random() % [self.tableViewReactiveAdapter numberOfRowsInSection:0]
																												  inSection:0]];
				}
				NSLog(@"%@", event);
				[subscriber sendNext:event];
				recurse();
			});
		};
		recurse();
		return nil;
	}] subscribe:self.tableViewReactiveAdapter.sourceEventsSubscriber];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Utility methods 
- (void)configureCell:(UITableViewCell *)cell forItem:(id)item {
	cell.textLabel.text = [item description];
}

#pragma mark - UITableViewDelegate and UITableViewDatasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
	[self configureCell:cell forItem: [self.tableViewReactiveAdapter itemAtIndexPath:indexPath]];
	
	return cell;
}

@end
