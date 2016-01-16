// #define DEBUG
#ifdef DEBUG
#define TweakLog(fmt, ...) NSLog((@"[NoMoreActions] [Line %d]: "  fmt), __LINE__, ##__VA_ARGS__)
#else
#define TweakLog(fmt, ...)
#define NSLog(fmt, ...)
#endif

/*
██╗  ██╗███████╗ █████╗ ██████╗ ███████╗██████╗ ███████╗
██║  ██║██╔════╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██╔════╝
███████║█████╗  ███████║██║  ██║█████╗  ██████╔╝███████╗
██╔══██║██╔══╝  ██╔══██║██║  ██║██╔══╝  ██╔══██╗╚════██║
██║  ██║███████╗██║  ██║██████╔╝███████╗██║  ██║███████║
╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝  ╚═╝╚══════╝
*/
@interface BBBulletin : NSObject
@property(copy, nonatomic) NSString *sectionID;
@end

@interface UITableViewRowAction (NoMoreActions)
-(id)_button;
@end

@interface SBLockScreenNotificationListView : UIView
- (id)_activeBulletinForIndexPath:(id)arg1;
@end

@interface SBBulletinViewController : UITableViewController
- (id)_representedBulletinAtIndexPath:(id)arg1;
- (id)_bulletinInfoAtIndexPath:(id)arg1;
@end

@interface SBNCTableViewController : UITableViewController
- (id)_representedBulletinAtIndexPath:(id)arg1;
- (id)_bulletinInfoAtIndexPath:(id)arg1;
@end


/*
██╗   ██╗ █████╗ ██████╗ ██╗ █████╗ ██████╗ ██╗     ███████╗███████╗
██║   ██║██╔══██╗██╔══██╗██║██╔══██╗██╔══██╗██║     ██╔════╝██╔════╝
██║   ██║███████║██████╔╝██║███████║██████╔╝██║     █████╗  ███████╗
╚██╗ ██╔╝██╔══██║██╔══██╗██║██╔══██║██╔══██╗██║     ██╔══╝  ╚════██║
 ╚████╔╝ ██║  ██║██║  ██║██║██║  ██║██████╔╝███████╗███████╗███████║
  ╚═══╝  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚══════╝╚══════╝
*/

#define kCFCoreFoundationVersionNumber_iOS_9 1240.10
#define PreferencesChangedNotification "net.tateu.nomoreactions/preferences"

static BOOL enabled = NO;
static BOOL mirror = YES;
static NSMutableSet *ncApps = nil;
static NSMutableSet *lsApps = nil;

/*
███████╗██╗   ██╗███╗   ██╗ ██████╗████████╗██╗ ██████╗ ███╗   ██╗███████╗
██╔════╝██║   ██║████╗  ██║██╔════╝╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
█████╗  ██║   ██║██╔██╗ ██║██║        ██║   ██║██║   ██║██╔██╗ ██║███████╗
██╔══╝  ██║   ██║██║╚██╗██║██║        ██║   ██║██║   ██║██║╚██╗██║╚════██║
██║     ╚██████╔╝██║ ╚████║╚██████╗   ██║   ██║╚██████╔╝██║ ╚████║███████║
╚═╝      ╚═════╝ ╚═╝  ╚═══╝ ╚═════╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝
*/

static void LoadSettings()
{
	NSMutableDictionary *preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/net.tateu.nomoreactions.plist"];

	if (preferences == nil) {
		enabled = NO;
	} else {
		enabled = preferences[@"enabled"] ? [preferences[@"enabled"] boolValue] : NO;
		mirror = preferences[@"mirror"] ? [preferences[@"mirror"] boolValue] : YES;

		ncApps = nil;
		lsApps = nil;
		ncApps = [[NSMutableSet alloc] init];
		lsApps = [[NSMutableSet alloc] init];

		if (enabled) {
			for (NSString *key in preferences[@"ncApps"]) {
				[ncApps addObject:key];
			}

			if (!mirror) {
				for (NSString *key in preferences[@"lsApps"]) {
					[lsApps addObject:key];
				}
			}
		}
	}
}

static void TweakReceivedNotification(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo)
{
	NSString *notificationName = (__bridge NSString *)name;
	if ([notificationName isEqualToString:[NSString stringWithUTF8String:PreferencesChangedNotification]]) {
		LoadSettings();
	}
}


/*
 ██████╗██╗      █████╗ ███████╗███████╗███████╗███████╗
██╔════╝██║     ██╔══██╗██╔════╝██╔════╝██╔════╝██╔════╝
██║     ██║     ███████║███████╗███████╗█████╗  ███████╗
██║     ██║     ██╔══██║╚════██║╚════██║██╔══╝  ╚════██║
╚██████╗███████╗██║  ██║███████║███████║███████╗███████║
 ╚═════╝╚══════╝╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚══════╝
*/



/*
██╗  ██╗ ██████╗  ██████╗ ██╗  ██╗███████╗
██║  ██║██╔═══██╗██╔═══██╗██║ ██╔╝██╔════╝
███████║██║   ██║██║   ██║█████╔╝ ███████╗
██╔══██║██║   ██║██║   ██║██╔═██╗ ╚════██║
██║  ██║╚██████╔╝╚██████╔╝██║  ██╗███████║
╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚══════╝
*/
%group Group_All
%hook SBLockScreenNotificationListView
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *original = %orig;

	if ((mirror && ncApps.count > 0) || (!mirror && lsApps.count > 0)) {
		id bulletin = [self _activeBulletinForIndexPath:indexPath];
		if (bulletin && [bulletin isKindOfClass:%c(BBBulletin)] && [bulletin sectionID]) {
			if ((mirror && [ncApps containsObject:[bulletin sectionID]]) || (!mirror && [lsApps containsObject:[bulletin sectionID]])) {
				for (UITableViewRowAction *action in original) {
					TweakLog(@"SBNCTableViewController %ld - %@ - %@", (long)[action style], [action title], [action _button]);
					if ([[action _button] isKindOfClass:%c(SBTableViewCellDismissActionButton)]) {
						return [NSArray arrayWithObjects:action, nil];
					}
				}

				return nil;
			}
		}
	}

	return original;
}
%end
%end // Group_All

%group Group_iOS8
%hook SBBulletinViewController
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *original = %orig;

	if (ncApps.count > 0) {
		id bulletin = [self _representedBulletinAtIndexPath:indexPath];
		if (bulletin && [bulletin isKindOfClass:%c(BBBulletin)] && [bulletin sectionID]) {
			if ([ncApps containsObject:[bulletin sectionID]]) {
				for (UITableViewRowAction *action in original) {
					TweakLog(@"SBBulletinViewController %ld - %@ - %@", (long)[action style], [action title], [action _button]);
					if ([[action _button] isKindOfClass:%c(SBTableViewCellDismissActionButton)]) {
						return [NSArray arrayWithObjects:action, nil];
					}
				}

				return nil;
			}
		}
	}

	return original;
}
%end
%end // Group_iOS8

%group Group_iOS9
%hook SBNCTableViewController
- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSArray *original = %orig;

	if (ncApps.count > 0) {
		id bulletin = [self _representedBulletinAtIndexPath:indexPath];
		if (bulletin && [bulletin isKindOfClass:%c(BBBulletin)] && [bulletin sectionID]) {
			if ([ncApps containsObject:[bulletin sectionID]]) {
				for (UITableViewRowAction *action in original) {
					TweakLog(@"SBNCTableViewController %ld - %@ - %@", (long)[action style], [action title], [action _button]);
					if ([[action _button] isKindOfClass:%c(SBTableViewCellDismissActionButton)]) {
						return [NSArray arrayWithObjects:action, nil];
					}
				}

				return nil;
			}
		}
	}

	return original;
}
%end
%end // Group_iOS9


/*
██╗███╗   ██╗██╗████████╗██╗ █████╗ ██╗     ██╗███████╗███████╗
██║████╗  ██║██║╚══██╔══╝██║██╔══██╗██║     ██║╚══███╔╝██╔════╝
██║██╔██╗ ██║██║   ██║   ██║███████║██║     ██║  ███╔╝ █████╗
██║██║╚██╗██║██║   ██║   ██║██╔══██║██║     ██║ ███╔╝  ██╔══╝
██║██║ ╚████║██║   ██║   ██║██║  ██║███████╗██║███████╗███████╗
╚═╝╚═╝  ╚═══╝╚═╝   ╚═╝   ╚═╝╚═╝  ╚═╝╚══════╝╚═╝╚══════╝╚══════╝
*/

%ctor
{
	@autoreleasepool {
		LoadSettings();
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, TweakReceivedNotification, CFSTR(PreferencesChangedNotification), NULL, CFNotificationSuspensionBehaviorCoalesce);

		%init(Group_All);

		if (kCFCoreFoundationVersionNumber < kCFCoreFoundationVersionNumber_iOS_9) {
			%init(Group_iOS8);
		} else {
			%init(Group_iOS9);
		}
	}
}
