//
//  KTPomodoroTableViewController.m
//  KTPomodoro
//
//  Created by Kenny Tang on 12/31/14.
//  Copyright (c) 2014 Kenny Tang. All rights reserved.
//

#import "KTPomodoroTableViewController.h"
#import "KTCoreDataStack.h"
#import "KTPomodoroTableViewCell.h"
#import "KTPomodoroTask.h"
#import "KTActiveTimer.h"

static NSString *kKTPomodoroTableRow = @"kKTPomodoroTableRow";
static CGFloat kKTPomodoroTableRowHeight = 110.0f;


@interface KTPomodoroTableViewController () <KTActiveTimerDelegate>

@property (nonatomic) KTActiveTimer *activeTaskTimer;
@property (nonatomic) NSInteger activeTimerRowIndex;

@end

@implementation KTPomodoroTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"KTPomodoroTableViewCell" bundle:nil] forCellReuseIdentifier:kKTPomodoroTableRow];

    self.title = @"Pomodoro Tasks";

    self.activeTimerRowIndex = -1;
    self.activeTaskTimer = [KTActiveTimer sharedInstance];
    self.activeTaskTimer.delegate = self;

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [self.activeTaskTimer invalidate];
}

#pragma mark - UITableViewController methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[KTCoreDataStack sharedInstance].allTasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    KTPomodoroTableViewCell *cell = (KTPomodoroTableViewCell*)[tableView dequeueReusableCellWithIdentifier:kKTPomodoroTableRow forIndexPath:indexPath];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"KTPomodoroTableViewCell" owner:nil options:nil][0];
    }

    KTPomodoroTask *task = [KTCoreDataStack sharedInstance].allTasks[indexPath.row];
    cell.taskNameLabel.text = task.name;
    cell.descLabel.text = task.desc;
    cell.statusLabel.text = [task.status stringValue];

    if (indexPath.row == self.activeTimerRowIndex) {
        cell.backgroundColor = [UIColor colorWithRed:235.0f/255.0f green:231.0f/255.0f blue:231.0f/255.0f alpha:1.0];

    } else {
        cell.backgroundColor = [UIColor clearColor];
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kKTPomodoroTableRowHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    KTPomodoroTableViewCell *cell = (KTPomodoroTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
    [cell setSelected:NO animated:YES];

    if (![self.activeTaskTimer isValid]) {
        self.activeTimerRowIndex = indexPath.row;
        [self updateTaskTimeLabelsPreStart];
        [self.activeTaskTimer start];

    } else {
        [self.activeTaskTimer invalidate];

        [self resetTaskTimeLabels];
        self.activeTimerRowIndex = -1;
    }
    [self.tableView reloadData];

}

#pragma mark - didSelectRowAtIndexPath helper methods

- (void)resetTaskTimeLabels
{
    KTPomodoroTableViewCell *cell = (KTPomodoroTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.activeTimerRowIndex inSection:0]];
    cell.timeLabel.text = @"00:00";

}

- (void)updateTaskTimeLabelsPreStart
{
    KTPomodoroTableViewCell *cell = (KTPomodoroTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.activeTimerRowIndex inSection:0]];
    cell.timeLabel.text = [NSString stringWithFormat:@"%@:00", @([KTActiveTimer pomodoroDurationMinutes])];
}

#pragma mark - Timer delegate

- (void)timerDidFire:(KTPomodoroTask*)task totalElapsedSecs:(NSUInteger)secs minutes:(NSUInteger)displayMinutes seconds:(NSUInteger)displaySecs
{

    KTPomodoroTableViewCell *cell = (KTPomodoroTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:self.activeTimerRowIndex inSection:0]];

    // update label
    NSString *displayMinutesString = (displayMinutes>9)?[@(displayMinutes) stringValue ]:[NSString stringWithFormat:@"0%@", @(displayMinutes)];
    NSString *displaySecsString = (displaySecs>9)?[@(displaySecs) stringValue ]:[NSString stringWithFormat:@"0%@", @(displaySecs)];

    NSString *remainingTimeString = [NSString stringWithFormat:@"%@:%@", displayMinutesString, displaySecsString];
    cell.timeLabel.text = remainingTimeString;


}

@end
