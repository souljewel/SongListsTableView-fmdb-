//
//  TabBarViewController.m
//  SongListsTableView
//
//  Created by Pham Thanh on 12/10/15.
//  Copyright © 2015 hdapps. All rights reserved.
//

#import "TabBarViewController.h"


@interface TabBarViewController ()

@end

@implementation TabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// ----------------------
// init data
- (void) initData{
    _musicManagers = [[NSMutableArray alloc] init];
    
    //init item manager for each genre tab and song tab
    MusicManager *genresManager = [[MusicManager alloc] init ];
    [genresManager loadSongFromDatabase:1];
    
    MusicManager *songManager = [[MusicManager alloc] init ];
    [songManager loadSongFromDatabase:2];
    
    [_musicManagers addObject:genresManager];
    [_musicManagers addObject:songManager];
}

// ----------------------
// get Genre items Manager
- (MusicManager*) getGenresManager{
    return [self.musicManagers objectAtIndex:0];
}

// ----------------------
// get Song Items Manager
- (MusicManager*) getSongManager {
    return [self.musicManagers objectAtIndex:1];
}

// ----------------------
// move song from one tab item to another tab bar item
- (void) moveSong:(NSInteger)songId fromTabItemIndex:(NSInteger)fromTabItemIndex toTabItemIndex:(NSInteger)toTabItemIndex{
    MusicManager *fromTab = [self.musicManagers objectAtIndex:fromTabItemIndex];
    MusicManager *toTab = [self.musicManagers objectAtIndex:toTabItemIndex];
    
    Song *moveSong = [fromTab getSongBySongId:songId];
    [fromTab.lstItems removeObject:moveSong];
    [toTab.lstItems addObject:moveSong];
    
    //set badge Value
    UITabBarItem* toTabbarItem = [self.tabBar.items objectAtIndex:toTabItemIndex];
    if(toTabbarItem.badgeValue == nil){
        toTabbarItem.badgeValue = [NSString stringWithFormat:@"%d", 1];
    }else{
        int currentBadgeValue = [toTabbarItem.badgeValue intValue];
        toTabbarItem.badgeValue = [NSString stringWithFormat:@"%d", ++currentBadgeValue];
    }
    
    //update database
    moveSong.songGenre.genreId = toTabItemIndex+1;
    [FMDBManager updateSong:moveSong];
    
    // Post a notification to insertSong
    [[NSNotificationCenter defaultCenter] postNotificationName:@"updateSong" object:nil];
}

- (void) tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item{
    item.badgeValue = nil;
    NSLog(@"tab item");
}

@end
