//
//  ViewController.m
//  Image Gallery
//
//  Created by Irfan Godinjak on 09/05/16.
//  Copyright © 2016 Godinjak. All rights reserved.
//

@import Photos;

#import "ViewController.h"
#import "ImageViewCollectionViewCell.h"
#import "ImageEffectsModel.h"
#import "ImageViewController.h"

@interface ViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>{
    NSMutableArray *imageArray;
}

@property (weak, nonatomic) IBOutlet UICollectionView *imagesCollectionView;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UILabel *loadingLabel;

- (IBAction)downloadImage:(id)sender;

@end

@implementation ViewController

static NSString * const cellIdentifier = @"imageCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _loadingView.layer.cornerRadius = 5;
    
    imageArray = [NSMutableArray array];
    self.imagesCollectionView.delegate = self;
    self.imagesCollectionView.dataSource = self;
    [self.imagesCollectionView registerNib:[UINib nibWithNibName:@"ImageViewCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:cellIdentifier];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
     // authorise the app to get access to images
    if ([PHPhotoLibrary authorizationStatus] != PHAuthorizationStatusAuthorized) {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [self fetchImages];
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [_loadingView removeFromSuperview];
                    [self showAlertWithTitle:@"Error" andText:@"Acccess to photos is denied. Please go to Settings->Privacy->Photos and enable access to photos from the App" withCancelTitle:@"OK"];
                });
            }
        }];
    }else
        [self fetchImages];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Collection View Delegate & Data Source Methods - 

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section{
    return imageArray.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    float width = self.imagesCollectionView.frame.size.width / 4;
    return CGSizeMake(width, width + 20);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    ImageViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];
    PHAsset *asset = imageArray[indexPath.row];
    __block UIImage *thumbnail = nil;
    
    NSArray *resources = [PHAssetResource assetResourcesForAsset:asset];
    NSString *orgFilename = ((PHAssetResource*)resources[0]).originalFilename;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;
    float width = self.imagesCollectionView.frame.size.width / 4;

    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(width, width) contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        thumbnail = result;
    }];

    
    cell.imageView.image = thumbnail;
    cell.imageName.text = orgFilename;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *asset = imageArray[indexPath.row];
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    options.synchronous = YES;

    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        ImageEffectsModel *imgModel = [[ImageEffectsModel alloc] initWithImage:result];
        ImageViewController *imageVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ImageViewController class])];
        imageVC.imgeEffectModel = imgModel;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController pushViewController:imageVC animated:YES];
        });
    }];
}
#pragma mark - Image Fetching Methods -

- (void) fetchImages{
    PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
    allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult *allPhotos = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
    [imageArray removeAllObjects];
    [allPhotos enumerateObjectsUsingBlock:^(PHAsset *asset, NSUInteger idx, BOOL *stop) {
        if (asset) {
            [imageArray addObject:asset];
            _loadingLabel.text = [NSString stringWithFormat:@"%ld Loaded", imageArray.count];
        }
        
            dispatch_async(dispatch_get_main_queue(), ^{
                [_loadingView removeFromSuperview];
            });

    }];
    [self.imagesCollectionView reloadData];
}


- (IBAction)downloadImage:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Download Image" message:@"Enter a valid URL for your image" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:nil];
    __block NSURL *url;
    UITextField *textField = alert.textFields[0];
    textField.placeholder = @"Enter URL";

    [alert addAction: [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if ([textField.text isEqualToString:@""]) {
            url = [NSURL URLWithString: @"http://upload.wikimedia.org/wikipedia/commons/7/7f/Williams_River-27527.jpg"];
        }else
            url = [NSURL URLWithString:textField.text];
        
        NSURLSessionDownloadTask *downloadPhotoTask = [[NSURLSession sharedSession] downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (!error) {
                UIImage *downloadedImage = [UIImage imageWithData: [NSData dataWithContentsOfURL:location]];
                ImageEffectsModel *imgModel = [[ImageEffectsModel alloc] initWithImage:downloadedImage];
                ImageViewController *imageVC = [self.storyboard instantiateViewControllerWithIdentifier:NSStringFromClass([ImageViewController class])];
                imageVC.imgeEffectModel = imgModel;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController pushViewController:imageVC animated:YES];
                });
            }else
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showAlertWithTitle:@"Error" andText:[error description] withCancelTitle:@"OK"];
                });
        }];
        
        [downloadPhotoTask resume];

    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];

}

- (void)showAlertWithTitle:(NSString *)title andText:(NSString *)text withCancelTitle:(NSString *)cancel{
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:text preferredStyle:UIAlertControllerStyleAlert];
        
    UIAlertAction* cancelAction = [UIAlertAction
                             actionWithTitle:cancel
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
        [alert addAction:cancelAction];
        
        [self presentViewController:alert animated:YES completion:^{
            
        }];
    
    
    
}

@end
