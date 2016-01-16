#import "NMAApplicationController.h"

#define _plistfile @"/private/var/mobile/Library/Preferences/net.tateu.nomoreactions.plist"
static NSMutableDictionary *_settings;

@implementation NMAApplicationController
-(void)updateDataSource:(NSString*)searchText
{
	NSNumber *iconSize = [NSNumber numberWithUnsignedInteger:ALApplicationIconSizeSmall];

	NSString *enabledList = @"";

	if (_row < 0) {
		if (!_settings) {
			_settings = [NSMutableDictionary dictionaryWithContentsOfFile:_plistfile] ?: [NSMutableDictionary dictionary];
		}

		NSMutableArray *filters = nil;
		if (_row == -2) {
			filters = [_settings objectForKey:@"lsApps"];
		} else {
			filters = [_settings objectForKey:@"ncApps"];
		}

		if (filters) {
			NSArray *apps = [[ALApplicationList sharedApplicationList] applications].allKeys;
			for (NSString *bundle in filters) {
				if ([apps containsObject:bundle]) {
					enabledList = [enabledList stringByAppendingString:[NSString stringWithFormat:@"'%@',", bundle]];
				}
			}
		}
	}

	enabledList = [enabledList stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@","]];

	NSString* filter = (searchText && searchText.length > 0) ? [NSString stringWithFormat:@"displayName beginsWith[cd] '%@'", searchText] : nil;

	if (filter) {
		_dataSource.sectionDescriptors = [NSArray arrayWithObjects:
											 [NSDictionary dictionaryWithObjectsAndKeys:
												 @"Search Results", ALSectionDescriptorTitleKey,
												 @"ALCheckCell", ALSectionDescriptorCellClassNameKey,
												 iconSize, ALSectionDescriptorIconSizeKey,
												 @YES, ALSectionDescriptorSuppressHiddenAppsKey,
												 filter, ALSectionDescriptorPredicateKey
											 , nil]
										 , nil];
	} else {
		_dataSource.sectionDescriptors = [NSArray arrayWithObjects:
											[NSDictionary dictionaryWithObjectsAndKeys:
												@"Enabled Applications", ALSectionDescriptorTitleKey,
												@"ALCheckCell", ALSectionDescriptorCellClassNameKey,
												iconSize, ALSectionDescriptorIconSizeKey,
												@YES, ALSectionDescriptorSuppressHiddenAppsKey,
												[NSString stringWithFormat:@"bundleIdentifier in {%@}", enabledList],
												ALSectionDescriptorPredicateKey
											, nil],

											[NSDictionary dictionaryWithObjectsAndKeys:
												@"Available Applications", ALSectionDescriptorTitleKey,
												@"ALCheckCell", ALSectionDescriptorCellClassNameKey,
												iconSize, ALSectionDescriptorIconSizeKey,
												@YES, ALSectionDescriptorSuppressHiddenAppsKey,
												[NSString stringWithFormat:@"not bundleIdentifier in {%@}", enabledList],
												ALSectionDescriptorPredicateKey
											, nil]
										 , nil];
	}

	[_tableView reloadData];
}

-(id)initWithRow:(int)row
{
	_row = row;
	return [self init];
}

-(id)init
{
	if (!(self = [super init])) return nil;
	CGRect bounds = [[UIScreen mainScreen] bounds];

	_dataSource = [[ALApplicationTableDataSource alloc] init];
	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width, bounds.size.height) style:UITableViewStyleGrouped];
	_tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_tableView.delegate = self;
	_tableView.dataSource = _dataSource;
	_dataSource.tableView = _tableView;
	[self updateDataSource:nil];

	_searchBar = [[UISearchBar alloc] initWithFrame:CGRectZero];
	_searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
	_searchBar.delegate = self;

	_settings = [NSMutableDictionary dictionaryWithContentsOfFile:_plistfile] ?: [NSMutableDictionary dictionary];

	isSearching = NO;

	return self;
}

-(void)viewDidLoad
{
	((UIViewController *)self).title = @"Applications";

	UIEdgeInsets insets = UIEdgeInsetsMake(44.0f, 0, 0, 0);
	_tableView.contentInset = insets;
	_tableView.contentOffset = CGPointMake(0, 12.0f);
	insets.top = 0;
	_tableView.scrollIndicatorInsets = insets;
	_searchBar.frame = CGRectMake(0, -44.0f, _tableView.bounds.size.width, 44.0f);

	[_tableView addSubview:_searchBar];
	[self.view addSubview:_tableView];
	[super viewDidLoad];
}

-(void) viewWillAppear:(BOOL) animated
{
	[super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	[_searchBar resignFirstResponder];
}

-(void)dealloc
{
	_searchBar.delegate = nil;
	_tableView.delegate = nil;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
	for (int section = 0, sectionCount = _tableView.numberOfSections; section < sectionCount; ++section) {
		for (int row = 0, rowCount = [_tableView numberOfRowsInSection:section]; row < rowCount; ++row) {
			UITableViewCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.accessoryView = nil;
		}
	}

	isSearching = YES;
	[_searchBar setShowsCancelButton:true animated:true];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
	[_searchBar setShowsCancelButton:false animated:true];
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
	[_searchBar resignFirstResponder];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
	isSearching = NO;
	_searchBar.text = nil;
	[self updateDataSource:nil];
	[_searchBar resignFirstResponder];
	_tableView.contentOffset = CGPointMake(0, -44.0f);
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)searchText
{
	[self updateDataSource:searchText];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	ALCheckCell *cell = (ALCheckCell *)[_tableView cellForRowAtIndexPath:indexPath];
	UITableViewCellAccessoryType cellAccessoryType = [cell accessoryType];

	BOOL remove = !isSearching && ((indexPath.section == 0 && cellAccessoryType == UITableViewCellAccessoryNone) || (indexPath.section != 0 && cellAccessoryType == UITableViewCellAccessoryCheckmark));

	if ((remove && indexPath.section != 0) || (!remove && indexPath.section == 0)) {
		cell.accessoryView = nil;
	} else {
		NSString *text;
		UIColor *fontColor;
		if (isSearching || indexPath.section != 0) {
			text = @"+";
			fontColor = [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0];
		} else {
			text = @"-";
			fontColor = [UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:1.0];
		}
		UIFont *font = [UIFont systemFontOfSize:24.0];
		CGSize size = [text sizeWithAttributes:@ {NSFontAttributeName: font}];

		NSDictionary *attrsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, [NSNumber numberWithFloat:1.0], NSBaselineOffsetAttributeName, fontColor, NSForegroundColorAttributeName, nil];

		UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
		[text drawAtPoint:CGPointZero withAttributes:attrsDictionary];
		UIImage *textImage = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();

		cell.accessoryView = [[UIImageView alloc] initWithImage:textImage];
	}

	BOOL updateDataSource = NO;
	if (isSearching) {
		_searchBar.text = nil;
		[_searchBar resignFirstResponder];
		_tableView.contentOffset = CGPointMake(0, -44.0f);
		isSearching = NO;
		updateDataSource = YES;
	}

	if (_row < 0) {
		NSMutableArray *filters = nil;
		if (_row == -2) {
			filters = [_settings objectForKey:@"lsApps"];
		} else {
			filters = [_settings objectForKey:@"ncApps"];
		}
		if (!filters) {
			filters = [[NSMutableArray alloc] init];
		}

		if (filters) {
			NSString *displayIdentifier = [_dataSource displayIdentifierForIndexPath:indexPath];

			[cell setAccessoryType:(cellAccessoryType == UITableViewCellAccessoryNone) ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone];

			if (remove) {
				[filters removeObject:displayIdentifier];
			} else {
				[filters addObject:displayIdentifier];
			}


			if (_row == -2) {
				[_settings setObject:filters forKey:@"lsApps"];
			} else {
				[_settings setObject:filters forKey:@"ncApps"];
			}

			[_settings writeToFile:_plistfile atomically:YES];

			NSString *post = @"net.tateu.nomoreactions/preferences";
			if (post) {
				CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),  (__bridge CFStringRef)post, NULL, NULL, TRUE);
			}
		}
	}

	[tableView deselectRowAtIndexPath:indexPath animated:true];
	if (updateDataSource) {
		[cell setAccessoryType:UITableViewCellAccessoryNone];
		[self updateDataSource:nil];
	}
}
@end
