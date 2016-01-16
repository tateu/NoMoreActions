#import <Preferences/Preferences.h>
#import <AppList/AppList.h>

@interface NMAApplicationController : PSViewController <UITableViewDelegate, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating>
{
	BOOL isSearching;
	UITableView *_tableView;
	ALApplicationTableDataSource *_dataSource;

	int _row;
}
@property (strong, nonatomic) UISearchController *searchController;
-(id)initWithRow:(int)row;
@end
