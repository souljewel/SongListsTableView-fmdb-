//
//  GenresTableViewController.m
//  SongListsTableView
//
//  Created by Pham Thanh on 12/10/15.
//  Copyright © 2015 hdapps. All rights reserved.
//

#import "GenresTableViewController.h"
#import "Song.h"
#import "MusicManager.h"
#import "MyTableViewCell.h"
#import "TabBarViewController.h"
#import "SongTableViewController.h"

@interface GenresTableViewController ()<UIAlertViewDelegate,UITabBarControllerDelegate>

@property MusicManager *genreMusicManager;
//@property TabBarViewController *tabBarController;

@end

@implementation GenresTableViewController

static NSString *MyIdentifier = @"MyTableView";

// ----------------------
// init TableView
- (void) initData{
    
    TabBarViewController*  tabBarController= (TabBarViewController*)self.tabBarController;
    self.genreMusicManager = [tabBarController getGenresManager];
    tabBarController.delegate = self;

    // Add an observer that will respond to loginComplete
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDatabaseChange:) name:@"insertSong" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDatabaseChange:) name:@"deleteSong" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDatabaseChange:) name:@"updateSong" object:nil];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self initData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.genreMusicManager getCountItem];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MyTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    // Configure the cell...
    Song *songItem = [_genreMusicManager.lstItems objectAtIndex:indexPath.row];

    cell.image.image = songItem.songImage;
    cell.label.text = songItem.songTitle;
    cell.tag = songItem.songId;
    cell.button.tag = songItem.songId;
    [cell.button addTarget:self action:@selector(moveSong:) forControlEvents:UIControlEventTouchUpInside];
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        Song *song = [self.genreMusicManager getSongAtIndex:indexPath.row];
        [self.genreMusicManager deleteSongBySongId:song.songId indexPath:indexPath];

    }
//    else if (editingStyle == UITableViewCellEditingStyleInsert) {
//        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//    }   
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Alert View Delegate

// ----------------------
// alertView delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex == 1){ //Touch OK
        NSString *songName = [alertView textFieldAtIndex:0].text;
        
        Genre *genre = [[Genre alloc] initGenre:1 genreTitle:@"" genreImage:nil];
        Song *newSong = [[Song alloc] initSong:songName songImageName:nil songGenre:genre];
       

        [_genreMusicManager addSong:newSong];
        

    }
}

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

// ----------------------
// touch Add Track button
- (IBAction)touchAddTrack:(UIBarButtonItem *)sender {
    
    //show alert input add track
    UIAlertView *inputTrackAlertView = [[UIAlertView alloc] initWithTitle:@"Add Track"
                                                                  message:@"Enter Track Name"
                                                                 delegate:self
                                                        cancelButtonTitle:@"Cancel"
                                                        otherButtonTitles:@"OK",nil];
    [inputTrackAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    [inputTrackAlertView show];
    
}

#pragma mark - TableView Cell Event

-(void) moveSong:(UIButton *)sender {
    NSLog(@"move song %d", (int)sender.tag);
    
    //delete in database
    [(TabBarViewController*)self.tabBarController moveSong:(int)sender.tag fromTabItemIndex:0 toTabItemIndex:1];
    
    
    
}

#pragma mark - tab bar item click

// ----------------------
// update table view when change tab
-(void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController{
    if(tabBarController.selectedIndex == 0){//genres tab
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    }else{
        if(tabBarController.selectedIndex == 1){//song tab
            UINavigationController *naviController = tabBarController.selectedViewController;
            SongTableViewController *songController = [naviController.viewControllers objectAtIndex:0];
            [songController.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
        }
    }

}

#pragma mark Database change notifications

- (void)didDatabaseChange:(NSNotification *)notification {
    NSLog(@"Database did change");
    if ([notification.name isEqualToString:@"insertSong"])
    {
        NSArray *insertIndexPaths = [NSArray arrayWithObjects:
                                     [NSIndexPath indexPathForRow:([_genreMusicManager getCountItem]-1) inSection:0],
                                     nil];
        UITableView *tv = (UITableView *)self.view;
        [tv beginUpdates];
        [tv insertRowsAtIndexPaths:insertIndexPaths withRowAnimation:UITableViewRowAnimationRight];
        [tv endUpdates];

    }else{
        if ([notification.name isEqualToString:@"updateSong"])
        {
            [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationBottom];
        }else{
            if ([notification.name isEqualToString:@"deleteSong"])
            {
                NSDictionary *dic = notification.userInfo;
                NSIndexPath* indexPath = [dic objectForKey:@"indexPath"];
                // Delete the row from the data source
                [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

@end
