//
//  PlaqueViewController.h
//  OpenPlaques
//
//  Created by Emily Toop on 17/08/2010.
//  Copyright 2010 BuildBrighton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaqueVO.h"
#import "asyncimageview.h"


@interface PlaqueDetailViewController : UIViewController {
	AsyncImageView *plaqueImageView;
	UILabel *plaqueTranscriptionLabel;
	UILabel *plaqueLocationLabel;
	UILabel *plaqueErectedDateLabel;
	UILabel *plaquePhotoOwnerLabel;
	UILabel *locationLabel;
	UILabel *erectedLabel;
	PlaqueVO *plaque;
	NSURLConnection *connection;
	NSMutableData *receivedData;
	NSString *plaqueId;
	UIScrollView *scrollView1;
}

@property (nonatomic, retain) AsyncImageView *plaqueImageView;
@property (nonatomic, retain) UILabel *plaqueTranscriptionLabel;
@property (nonatomic, retain) UILabel *plaqueLocationLabel;
@property (nonatomic, retain) UILabel *plaqueErectedDateLabel;
@property (nonatomic, retain) UILabel *plaquePhotoOwnerLabel;
@property (nonatomic, retain) UILabel *locationLabel;
@property (nonatomic, retain) UILabel *erectedLabel;
@property (nonatomic, retain) PlaqueVO *plaque;
@property (nonatomic, retain) NSString *plaqueId;
@property (nonatomic, retain) UIScrollView *scrollView1;


-(void)parseFlickrResult;
-(void)savePlaque;
-(void)refresh;

@end
