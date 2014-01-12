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
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Utility methods 
- (void)configureCell:(UITableViewCell *)cell forItem:(id)item {
	
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
