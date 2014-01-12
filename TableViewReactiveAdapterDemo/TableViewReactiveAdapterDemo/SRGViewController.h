//
//  SRGViewController.h
//  TableViewReactiveAdapterDemo
//
//  Created by Sergey Gavrilyuk on 1/11/14.
//  Copyright (c) 2014 Sergey Gavrilyuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TableViewReactiveAdapter/SRGTableViewReactiveAdapter.h>

@interface SRGViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic) SRGTableViewReactiveAdapter *tableViewReactiveAdapter;

@end
