#import <Preferences/Preferences.h>
#import "NMAApplicationController.h"

// #define DEBUG
#ifdef DEBUG
#define TweakLog(fmt, ...) NSLog((@"[NoMoreActionsSettings] [Line %d]: "  fmt), __LINE__, ##__VA_ARGS__)
#else
#define TweakLog(fmt, ...)
#define NSLog(fmt, ...)
#endif

#define _plistfile @"/private/var/mobile/Library/Preferences/net.tateu.nomoreactions.plist"
static NSMutableDictionary *_settings;

@interface NoMoreActionsListController: PSListController {
}
@end

@implementation NoMoreActionsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [self loadSpecifiersFromPlistName:@"NoMoreActions" target:self];
	}
	return _specifiers;
}

- (id)initForContentSize:(CGSize)size
{
	if ((self = [super initForContentSize:size]) != nil) {
		_settings = [NSMutableDictionary dictionaryWithContentsOfFile:_plistfile] ?: [NSMutableDictionary dictionary];
	}

	return self;
}

-(void)viewWillAppear:(BOOL)animated
{
	_settings = ([NSMutableDictionary dictionaryWithContentsOfFile:_plistfile] ?: [NSMutableDictionary dictionary]);
	[super viewWillAppear:animated];
	[self reload];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier
{
	NSString *key = specifier.properties[@"key"];
	_settings = ([NSMutableDictionary dictionaryWithContentsOfFile:_plistfile] ?: [NSMutableDictionary dictionary]);
	[_settings setObject:value forKey:key];
	[_settings writeToFile:_plistfile atomically:YES];

	if ([key isEqualToString:@"mirror"]) {
		BOOL mirror = [value boolValue];

		PSControlTableCell *cell2 = [super tableView:(UITableView *)self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
		PSControlTableCell *cell3 = [super tableView:(UITableView *)self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];

		cell2.textLabel.alpha = 0;
		cell2.textLabel.text = mirror ? @"Applications:" : @"Notification Center:";

		[UIView animateWithDuration:0.5 animations:^{
			cell2.textLabel.alpha = 1;
			cell3.textLabel.alpha = 0;
			cell3.backgroundColor = mirror ? [UIColor clearColor] : [UIColor whiteColor];
		} completion:^(BOOL finished) {
			cell3.textLabel.text = mirror ? @"" : @"LockScreen:";
			cell3.accessoryType = mirror ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
			cell3.userInteractionEnabled = !mirror;
			cell3.textLabel.enabled = !mirror;
			cell3.detailTextLabel.enabled = !mirror;

			[UIView animateWithDuration:0.5 animations:^{
				cell3.textLabel.alpha = 1;
			} completion:^(BOOL finished) {
			}];
		}];
	}

	NSString *post = specifier.properties[@"PostNotification"];
	if (post) {
		CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),  (__bridge CFStringRef)post, NULL, NULL, TRUE);
	}
}

- (id)readPreferenceValue:(PSSpecifier *)specifier
{
	NSString *key = [specifier propertyForKey:@"key"];
	id defaultValue = [specifier propertyForKey:@"default"];
	id plistValue = [_settings objectForKey:key];
	if (!plistValue) plistValue = defaultValue;

	if ([key isEqualToString:@"mirror"]) {
		BOOL mirror = !plistValue || [plistValue boolValue];

		PSControlTableCell *cell = [super tableView:(UITableView *)self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
		cell.textLabel.text = mirror ? @"" : @"LockScreen:";
		cell.accessoryType = mirror ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
		cell.userInteractionEnabled = !mirror;
		cell.textLabel.enabled = !mirror;
		cell.detailTextLabel.enabled = !mirror;
		cell.backgroundColor = mirror ? [UIColor clearColor] : [UIColor whiteColor];

		cell = [super tableView:(UITableView *)self.table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
		cell.textLabel.text = mirror ? @"Applications:" : @"Notification Center:";
	}

	return plistValue;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = (UITableViewCell *)[super tableView:tableView cellForRowAtIndexPath:indexPath];
	[cell.textLabel setAdjustsFontSizeToFitWidth:YES];

	if (indexPath.row == 2) {
		BOOL mirror = !_settings[@"mirror"] || [_settings[@"mirror"] boolValue];
		cell.textLabel.text = mirror ? @"Applications:" : @"Notification Center:";
	} else if (indexPath.row == 3) {
		BOOL mirror = !_settings[@"mirror"] || [_settings[@"mirror"] boolValue];
		cell.textLabel.text = mirror ? @"" : @"LockScreen:";
		cell.accessoryType = mirror ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
		cell.userInteractionEnabled = !mirror;
		cell.textLabel.enabled = !mirror;
		cell.detailTextLabel.enabled = !mirror;
		cell.backgroundColor = mirror ? [UIColor clearColor] : [UIColor whiteColor];
	}

	return cell;
}

-(void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	if (indexPath.section == 0 && (indexPath.row == 2 || indexPath.row == 3)) {
		NMAApplicationController *controller = [[NMAApplicationController alloc] initWithRow:(1 - indexPath.row)];

		controller.rootController = self.rootController;
		controller.parentController = self;

		[self pushController:controller];
		[tableView deselectRowAtIndexPath:indexPath animated:true];
	} else {
		[super tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}
@end
