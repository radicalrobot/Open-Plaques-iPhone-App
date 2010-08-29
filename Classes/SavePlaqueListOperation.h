//
//  SavePlaqueListOperation.h
//  OpenPlaques
//
//  Created by Emily Toop on 21/08/2010.
//  Copyright 2010 BuildBrighton. All rights reserved.
//

#import <Foundation/Foundation.h>


@class SavePlaqueListOperation ;

@protocol SavePlaqueListOperationDelegate 
- (void)operationProgressChanged:(SavePlaqueListOperation *)op; 
@end

@interface SavePlaqueListOperation : NSOperation
{
	NSArray *plaqueList;
	id delegate;
}

@property NSArray *plaqueList;
@property (assign) id<SavePlaqueListOperationDelegate> delegate;

@end
