//
//  ServerSemesterViewController.m
//  OPDBit
//
//  Created by 1000732 on 2015. 8. 1..
//  Copyright (c) 2015년 Minz. All rights reserved.
//

// Controller
#import "ServerSemesterViewController.h"

// View
#import "ServerSemesterCell.h"

// Model
#import "ServerSemesterObject.h"

// Utility
#import "DataManager.h"
#import "NetworkManager.h"

// Library
#import <Masonry/Masonry.h>
#import <KVNProgress/KVNProgress.h>


static NSString * const ServerSemesterCellIdentifier = @"ServerTimeTableCell";
static CGFloat const ServerSemesterCellHeight = 75.0f;

@interface ServerSemesterViewController ()

@property (nonatomic, strong) DataManager *dataManager;
@property (nonatomic, strong) NetworkManager *networkManager;

@property (nonatomic, strong) RLMArray *savedServerSemesters;
@property (nonatomic, strong) UILabel *emptyLabel;

@property (nonatomic, strong) RLMArray *downloadedSemesters;

@end

@implementation ServerSemesterViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _dataManager = [DataManager sharedInstance];
        _networkManager = [NetworkManager sharedInstance];
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    [self setTitle:@"서버 시간표"];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *downloadServerLectureButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"download"]
                                                                                      style:UIBarButtonItemStylePlain
                                                                                     target:self
                                                                                     action:@selector(actionToFetchServerLectures)];
    self.navigationItem.rightBarButtonItem = downloadServerLectureButton;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    [_tableView registerClass:[ServerSemesterCell class] forCellReuseIdentifier:ServerSemesterCellIdentifier];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    _emptyLabel = [[UILabel alloc] init];
    _emptyLabel.text = @"종합강의 시간표가 없어요! XD\n우측 상단 다운로드 버튼을 눌러서 다운로드 받아주세요!";
    _emptyLabel.numberOfLines = 0;
    
    [self.view addSubview:_tableView];
    [self.view addSubview:_emptyLabel];
    [self makeAutoLayoutConstraints];
}

- (void)makeAutoLayoutConstraints
{
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [_emptyLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(_tableView);
    }];
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _savedServerSemesters.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ServerSemesterCell *cell = [tableView dequeueReusableCellWithIdentifier:ServerSemesterCellIdentifier];
    if (!cell)
        cell = [[ServerSemesterCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ServerSemesterCellIdentifier];
    cell.serverSemester = _savedServerSemesters[indexPath.row];
    return cell;
}

#pragma mark - Table View Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([_delegate respondsToSelector:@selector(serverSemesterViewController:didSelectedSemesterObject:)]) {
        ServerSemesterObject *selectedSemester = _savedServerSemesters[indexPath.row];
        [_delegate serverSemesterViewController:self didSelectedSemesterObject:selectedSemester];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ServerSemesterCellHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ServerSemesterCellHeight;
}

#pragma mark - Setter

- (void)setSavedServerSemesters:(RLMArray *)savedServerSemesters
{
    _savedServerSemesters = savedServerSemesters;
    [self hideTableView:[self serverSemestersAreEmpty]];
}

#pragma mark - Instance Method

- (BOOL)serverSemestersAreEmpty
{
    return !_savedServerSemesters.count;
}

- (void)hideTableView:(BOOL)hide
{
    _tableView.hidden = hide;
    _emptyLabel.hidden = !hide;
    
    if (!hide) [_tableView reloadData];
}

#pragma mark - Bar Button Action

- (void)actionToFetchServerLectures
{
    [self downloadServerSemstersWithCompletion:^(id response) {
        if (!_downloadedSemesters) {
            _downloadedSemesters = [[RLMArray alloc] initWithObjectClassName:ServerSemesterObjectID];
        } else {
            [_downloadedSemesters removeAllObjects];
        }
        
        for (NSDictionary *responseDictionary in response) {
            ServerSemesterObject *downloadedSemester = [[ServerSemesterObject alloc] init];
            [downloadedSemester setPropertiesWithResponse:responseDictionary];
            
            [_downloadedSemesters addObject:downloadedSemester];
        }
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"학기 목록"
                                                                                 message:@""
                                                                          preferredStyle:UIAlertControllerStyleActionSheet];
        for (ServerSemesterObject *downloadedSemester in _downloadedSemesters) {
            UIAlertAction *semesterAction = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%@", downloadedSemester.semesterName]
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:^(UIAlertAction *action)
            {
                [self downloadServerLectureWithServerSemester:downloadedSemester
                                                   completion:^(ServerSemesterObject *serverSemester)
                {
                    [_dataManager saveOrUpdateServerSemester:serverSemester completion:^(BOOL isUpdated) {
                        self.savedServerSemesters = [_dataManager savedServerSemesters];
                        [_tableView reloadData];
                        [KVNProgress showSuccessWithStatus:@"성공!"];
                    }];
                } failure:^(NSString *message)
                {
                    [KVNProgress showErrorWithStatus:message];
                }];
            }];
            [alertController addAction:semesterAction];
        }
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"취소"
                                                               style:UIAlertActionStyleCancel
                                                             handler:nil];
        [alertController addAction:cancelAction];
        [self presentViewController:alertController animated:YES completion:nil];
    } failure:^(NSString *message) {
        [KVNProgress showErrorWithStatus:message];
    }];
}

#pragma mark - Network Method

- (void)downloadServerSemstersWithCompletion:(void (^)(id response))completion
                                     failure:(void (^)(NSString *message))failure
{
    [_networkManager getServerSemestersWithCompletion:^(id response) {
        completion(response);
    } failure:^(NSError *error) {
        NSString *errorMessage = @"오류!";
        if (error.code == -1003 || error.code == -1009)
            errorMessage = @"인터넷 연결을 확인해주세요!";
        else
            errorMessage = @"내려받는 도중에\n오류가 발생했습니다!";
        failure(errorMessage);
    }];
}

- (void)downloadServerLectureWithServerSemester:(ServerSemesterObject *)serverSemester
                                     completion:(void (^)(ServerSemesterObject *serverSemester))completion
                                        failure:(void (^)(NSString *message))failure
{
    [_networkManager getServerLecturesWithSemesterID:serverSemester.semesterID
                                          completion:^(id response)
    {
        for (NSDictionary *responseDictionary in response) {
            ServerLectureObject *serverLecture = [[ServerLectureObject alloc] init];
            [serverLecture setPropertiesWithResponse:responseDictionary];
            [serverSemester.serverLectures addObject:serverLecture];
        }
        completion(serverSemester);
    } failure:^(NSError *error)
    {
        NSString *errorMessage = @"오류!";
        if (error.code == -1003 || error.code == -1009)
            errorMessage = @"인터넷 연결을 확인해주세요!";
        else
            errorMessage = @"내려받는 도중에\n오류가 발생했습니다!";
        failure(errorMessage);
    }];
}

#pragma mark - Life Cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.savedServerSemesters = [_dataManager savedServerSemesters];
    [_tableView reloadData];
}

@end
