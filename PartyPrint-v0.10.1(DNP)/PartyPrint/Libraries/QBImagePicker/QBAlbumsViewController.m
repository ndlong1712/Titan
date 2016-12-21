//
//  QBAlbumsViewController.m
//  QBImagePicker
//
//  Created by Katsuma Tanaka on 2015/04/03.
//  Copyright (c) 2015 Katsuma Tanaka. All rights reserved.
//

#import "QBAlbumsViewController.h"
#import <Photos/Photos.h>

// Views
#import "QBAlbumCell.h"

// ViewControllers
#import "QBImagePickerController.h"
#import "QBAssetsViewController.h"

static CGSize CGSizeScale(CGSize size, CGFloat scale) {
    return CGSizeMake(size.width * scale, size.height * scale);
}

@interface QBImagePickerController (Private)
    
    @property (nonatomic, strong) NSBundle *assetBundle;
    
    @end

@interface QBAlbumsViewController () <PHPhotoLibraryChangeObserver>
    
    @property (nonatomic, strong) IBOutlet UIBarButtonItem *doneButton;
    
    @property (nonatomic, copy) NSArray *fetchResults;
    @property (nonatomic, copy) NSArray *assetCollections;
    
    @end

@implementation QBAlbumsViewController
    
- (void)viewDidLoad
    {
        [super viewDidLoad];
        
        [self setUpToolbarItems];
        
        // Fetch user albums and smart albums
        PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        PHFetchResult *userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
        self.fetchResults = @[smartAlbums, userAlbums];
        
        [self updateAssetCollections];
        
        // Register observer
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        self.navigationItem.rightBarButtonItem.title = NSLocalizedString(@"DONE", "");
        self.navigationItem.leftBarButtonItem.title = NSLocalizedString(@"Menu", "");
        [self.navigationController setToolbarHidden:NO animated:YES];
        [self updateSelectionInfo];
    }

- (void)didReceiveMemoryWarning {
    NSLog(@"QB album");
    [super didReceiveMemoryWarning];
}

    
- (void)viewWillAppear:(BOOL)animated
    {
        [super viewWillAppear:animated];
        
        // Configure navigation item
        self.navigationItem.title = NSLocalizedStringFromTableInBundle(@"albums.title", @"QBImagePicker", self.imagePickerController.assetBundle, nil);
        self.navigationItem.prompt = self.imagePickerController.prompt;
        
        // Show/hide 'Done' button
        if (self.imagePickerController.allowsMultipleSelection) {
            [self.navigationItem setRightBarButtonItem:self.doneButton animated:NO];
        } else {
            [self.navigationItem setRightBarButtonItem:nil animated:NO];
        }
        
        if (self.imagePickerController.selectedAssets.count >= 1) {
            // Show toolbar
            [self.navigationController setToolbarHidden:NO animated:YES];
        }
        
        [self updateControlState];
        [self updateSelectionInfo];
    }
    
- (void)dealloc
    {
        // Deregister observer
        [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    }
    
    
#pragma mark - Storyboard
    
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
    {
        QBAssetsViewController *assetsViewController = segue.destinationViewController;
        assetsViewController.imagePickerController = self.imagePickerController;
        assetsViewController.assetCollection = self.assetCollections[self.tableView.indexPathForSelectedRow.row];
    }
    
    
#pragma mark - Actions
    
- (IBAction)cancel:(id)sender
    {
        if ([self.imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerControllerDidCancel:)]) {
            [self.imagePickerController.delegate qb_imagePickerControllerDidCancel:self.imagePickerController];
        }
    }
    
- (IBAction)done:(id)sender
    {
        if ([self.imagePickerController.delegate respondsToSelector:@selector(qb_imagePickerController:didFinishPickingAssets:)]) {
            [self.imagePickerController.delegate qb_imagePickerController:self.imagePickerController
                                                   didFinishPickingAssets:self.imagePickerController.selectedAssets];
        }
    }
    
    
#pragma mark - Toolbar
    
- (void)setUpToolbarItems
    {
        // Space
        UIBarButtonItem *leftSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        UIBarButtonItem *rightSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
        
        // Info label
        NSDictionary *attributes = @{ NSForegroundColorAttributeName: [UIColor blackColor] };
        UIBarButtonItem *infoButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:NULL];
        infoButtonItem.enabled = NO;
        [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
        [infoButtonItem setTitleTextAttributes:attributes forState:UIControlStateDisabled];
        
        self.toolbarItems = @[leftSpace, infoButtonItem, rightSpace];
    }
    
- (void)updateSelectionInfo
    {
        NSMutableArray *selectedAssets = self.imagePickerController.selectedAssets;
        
//        if (selectedAssets.count > 0) {
            //NSBundle *bundle = self.imagePickerController.assetBundle;
            NSString *format = NSLocalizedString(@"SelectedImageExists", "");
            /*
            if (selectedAssets.count > 1) {
                format = NSLocalizedStringFromTableInBundle(@"assets.toolbar.items-selected", @"QBImagePicker", bundle, nil);
            } else {
                format = NSLocalizedStringFromTableInBundle(@"assets.toolbar.item-selected", @"QBImagePicker", bundle, nil);
            }
             */
            
            NSString *title = [NSString stringWithFormat:format, selectedAssets.count];
            [(UIBarButtonItem *)self.toolbarItems[1] setTitle:title];
//        } else {
//            [(UIBarButtonItem *)self.toolbarItems[1] setTitle:@""];
//        }
    }
    
    
#pragma mark - Fetching Asset Collections
    
- (void)updateAssetCollections
    {
        // Filter albums
        NSArray *assetCollectionSubtypes = self.imagePickerController.assetCollectionSubtypes;
        NSMutableDictionary *smartAlbums = [NSMutableDictionary dictionaryWithCapacity:assetCollectionSubtypes.count];
        NSMutableArray *userAlbums = [NSMutableArray array];
        
        for (PHFetchResult *fetchResult in self.fetchResults) {
            [fetchResult enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
                PHAssetCollectionSubtype subtype = assetCollection.assetCollectionSubtype;
                
                if (subtype == PHAssetCollectionSubtypeAlbumRegular) {
                    [userAlbums addObject:assetCollection];
                } else if ([assetCollectionSubtypes containsObject:@(subtype)]) {
                    if (!smartAlbums[@(subtype)]) {
                        smartAlbums[@(subtype)] = [NSMutableArray array];
                    }
                    [smartAlbums[@(subtype)] addObject:assetCollection];
                }
            }];
        }
        
        NSMutableArray *assetCollections = [NSMutableArray array];
        
        // Add Moments as an album, if to include
        if (self.imagePickerController.includeMoments) {
            NSMutableArray *assets = [NSMutableArray array];
            PHFetchResult *fetchResult = [PHAssetCollection fetchMomentsWithOptions:nil];
            for (PHAssetCollection *aMomentsCollection in fetchResult) {
                PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:aMomentsCollection options:self.fetchOptions];
                for (PHAsset *asset in assetsFetchResults) {
                    [assets addObject:asset];
                }
            }
            
            // Create the Moments album
            if (assets.count > 0) {
                NSBundle *bundle = self.imagePickerController.assetBundle;
                NSString *momentsTitle = NSLocalizedStringFromTableInBundle(@"moments.title", @"QBImagePicker", bundle, nil);
                PHAssetCollection *momentsCollection = [PHAssetCollection transientAssetCollectionWithAssets:assets title:momentsTitle];
                [assetCollections addObject:momentsCollection];
            }
        }
        
        // Fetch smart albums
        for (NSNumber *assetCollectionSubtype in assetCollectionSubtypes) {
            NSArray *collections = smartAlbums[assetCollectionSubtype];
            
            if (collections) {
                BOOL shouldAdded = NO;
                for (PHAssetCollection *assetCollection in collections) {
                    PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
                    if (assetsFetchResults.count > 0) {
                        shouldAdded = YES;
                        break;
                    }
                }
                if (shouldAdded) {
                    [assetCollections addObjectsFromArray:collections];
                }
            }
        }
        
        // Fetch user albums
        [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *assetCollection, NSUInteger index, BOOL *stop) {
            PHFetchResult *assetsFetchResults = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
            if (assetsFetchResults.count > 0) {
                [assetCollections addObject:assetCollection];
            }
        }];
        
        self.assetCollections = assetCollections;
    }
    
- (UIImage *)placeholderImageWithSize:(CGSize)size
    {
        UIGraphicsBeginImageContext(size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        UIColor *backgroundColor = [UIColor colorWithRed:(239.0 / 255.0) green:(239.0 / 255.0) blue:(244.0 / 255.0) alpha:1.0];
        UIColor *iconColor = [UIColor colorWithRed:(179.0 / 255.0) green:(179.0 / 255.0) blue:(182.0 / 255.0) alpha:1.0];
        
        // Background
        CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height));
        
        // Icon (back)
        CGRect backIconRect = CGRectMake(size.width * (16.0 / 68.0),
                                         size.height * (20.0 / 68.0),
                                         size.width * (32.0 / 68.0),
                                         size.height * (24.0 / 68.0));
        
        CGContextSetFillColorWithColor(context, [iconColor CGColor]);
        CGContextFillRect(context, backIconRect);
        
        CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
        CGContextFillRect(context, CGRectInset(backIconRect, 1.0, 1.0));
        
        // Icon (front)
        CGRect frontIconRect = CGRectMake(size.width * (20.0 / 68.0),
                                          size.height * (24.0 / 68.0),
                                          size.width * (32.0 / 68.0),
                                          size.height * (24.0 / 68.0));
        
        CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
        CGContextFillRect(context, CGRectInset(frontIconRect, -1.0, -1.0));
        
        CGContextSetFillColorWithColor(context, [iconColor CGColor]);
        CGContextFillRect(context, frontIconRect);
        
        CGContextSetFillColorWithColor(context, [backgroundColor CGColor]);
        CGContextFillRect(context, CGRectInset(frontIconRect, 1.0, 1.0));
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
    
    
#pragma mark - Checking for Selection Limit
    
- (BOOL)isMinimumSelectionLimitFulfilled
    {
        return (self.imagePickerController.minimumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
    }
    
- (BOOL)isMaximumSelectionLimitReached
    {
        NSUInteger minimumNumberOfSelection = MAX(1, self.imagePickerController.minimumNumberOfSelection);
        
        if (minimumNumberOfSelection <= self.imagePickerController.maximumNumberOfSelection) {
            return (self.imagePickerController.maximumNumberOfSelection <= self.imagePickerController.selectedAssets.count);
        }
        
        return NO;
    }
    
- (void)updateControlState
    {
        self.doneButton.enabled = [self isMinimumSelectionLimitFulfilled];
    }
    
    
#pragma mark - Fetch Options
    
- (PHFetchOptions*)fetchOptions {
    PHFetchOptions *options = [PHFetchOptions new];
    
    switch (self.imagePickerController.mediaType) {
        case QBImagePickerMediaTypeImage:
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeImage];
        break;
        
        case QBImagePickerMediaTypeVideo:
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", PHAssetMediaTypeVideo];
        break;
        
        default:
        break;
    }
    return options;
}

- (PHFetchOptions *)fetchOptionsForCollection {
    PHFetchOptions *options = [PHFetchOptions new];
    options.predicate = [NSPredicate predicateWithFormat:@"estimatedAssetCount > 0"];
    return options;
}
    
#pragma mark - UITableViewDataSource
    
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
    {
        return 1;
    }
    
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
    {
        return self.assetCollections.count;
    }
    
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
    {
        QBAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumCell" forIndexPath:indexPath];
        cell.tag = indexPath.row;
        cell.borderWidth = 1.0 / [[UIScreen mainScreen] scale];
        
        // Thumbnail
        PHAssetCollection *assetCollection = self.assetCollections[indexPath.row];
        
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:self.fetchOptions];
        PHImageManager *imageManager = [PHImageManager defaultManager];
        CGFloat scaleScreenHeight = self.view.bounds.size.height;
        CGFloat scaleScreenWidth = self.view.bounds.size.width;
        
        if (fetchResult.count >= 3) {
            cell.imageView3.hidden = NO;
            
            [imageManager requestImageForAsset:fetchResult[fetchResult.count - 3]
                                    targetSize:CGSizeScale(CGSizeMake(scaleScreenWidth * 15 / 100, scaleScreenHeight * 15 /100), [[UIScreen mainScreen] scale])
                                   contentMode:PHImageContentModeAspectFill
                                       options:nil
                                 resultHandler:^(UIImage *result, NSDictionary *info) {
                                     if (cell.tag == indexPath.row) {
                                         cell.imageView3.image = result;
                                     }
                                 }];
        } else {
            cell.imageView3.hidden = YES;
        }
        
        if (fetchResult.count >= 2) {
            cell.imageView2.hidden = NO;
            
            [imageManager requestImageForAsset:fetchResult[fetchResult.count - 2]
                                    targetSize:CGSizeScale(CGSizeMake(scaleScreenWidth * 15 / 100 + 4, scaleScreenHeight * 15 /100 + 4), [[UIScreen mainScreen] scale])
                                   contentMode:PHImageContentModeAspectFill
                                       options:nil
                                 resultHandler:^(UIImage *result, NSDictionary *info) {
                                     if (cell.tag == indexPath.row) {
                                         cell.imageView2.image = result;
                                     }
                                 }];
        } else {
            cell.imageView2.hidden = YES;
        }
        
        if (fetchResult.count >= 1) {
            [imageManager requestImageForAsset:fetchResult[fetchResult.count - 1]
                                    targetSize:CGSizeScale(CGSizeMake(scaleScreenWidth * 15 / 100 + 8, scaleScreenHeight * 15 /100 + 8), [[UIScreen mainScreen] scale])
                                   contentMode:PHImageContentModeAspectFill
                                       options:nil
                                 resultHandler:^(UIImage *result, NSDictionary *info) {
                                     if (cell.tag == indexPath.row) {
                                         cell.imageView1.image = result;
                                     }
                                 }];
        }
        
        if (fetchResult.count == 0) {
            cell.imageView3.hidden = NO;
            cell.imageView2.hidden = NO;
            
            // Set placeholder image
            UIImage *placeholderImage = [self placeholderImageWithSize:cell.imageView1.frame.size];
            cell.imageView1.image = placeholderImage;
            cell.imageView2.image = placeholderImage;
            cell.imageView3.image = placeholderImage;
        }
        
        // Album title
        cell.titleLabel.text = assetCollection.localizedTitle;
        
        // Number of photos
        cell.countLabel.text = [NSString stringWithFormat:@"%lu", (long)fetchResult.count];
        
        return cell;
    }
    
    
#pragma mark - PHPhotoLibraryChangeObserver
    
- (void)photoLibraryDidChange:(PHChange *)changeInstance
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Update fetch results
            NSMutableArray *fetchResults = [self.fetchResults mutableCopy];
            
            [self.fetchResults enumerateObjectsUsingBlock:^(PHFetchResult *fetchResult, NSUInteger index, BOOL *stop) {
                PHFetchResultChangeDetails *changeDetails = [changeInstance changeDetailsForFetchResult:fetchResult];
                
                if (changeDetails) {
                    [fetchResults replaceObjectAtIndex:index withObject:changeDetails.fetchResultAfterChanges];
                }
            }];
            
            if (![self.fetchResults isEqualToArray:fetchResults]) {
                self.fetchResults = fetchResults;
                
                // Reload albums
                [self updateAssetCollections];
                [self.tableView reloadData];
            }
        });
    }
    
    @end
