#import <Preferences/Preferences.h>
#import <AppList/AppList.h>

@interface NMAApplicationController : PSViewController <UITableViewDelegate, UISearchBarDelegate>
{
	BOOL isSearching;
	UITableView *_tableView;
	ALApplicationTableDataSource *_dataSource;
	UISearchBar *_searchBar;

	NSIndexPath *_checkedIndexPath;
	int _row;
}
-(id)initWithRow:(int)row;
@end
