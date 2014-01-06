#TableViewReactiveAdapter

Small drop-in component which allows UITableView to be manipulated in reactive manner through receiving ReactiveCocoa signals.

## Idea

## Usage 
**TableViewReactiveAdapter** takes a UITableView it manages and act as a datasource for it. It exposes `subscriber` property which you can susbcribe to a ReactiveCocoa signal. This `subscriber` is designed to receive objects of class `SRGTableViewModificationEvent` and it simply filters out any other objects. The simplest items insert to the top of a tableView in response to an event could look like this:

``` objc
[[eventSignal map:^SRGTableViewModificationEvent *(NetworkResponse *response) {
    return [SRGTableViewModificationEvent insertRowsEvent:response.items atLocation:[NSIndexPath indexPathForRow:0 inSection:0]];
}] subscribe: self.tableViewReactiveAdapter.subscriber];
```
## TableView flush
Any insertions or deletions are performed immediately to a backing data structure, however, tableView itself is affected in different way: first event is flushed to a tableView immediately, subseqent events, while tableView animations are in place, are buffered and flushed only when tableView finishes it's first animation. That way, no matter how often or rare events are sent to tableView, it's updating animations will be serial and won't interfere with each other.
## Credits

** TableViewReactiveAdapter** was created by Sergey [@octogavrix] Gavrilyuk.

[@octogavrix]:https://twitter.com/octogavrix

