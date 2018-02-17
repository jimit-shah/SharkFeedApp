//
//  HTTPService.h
//  SharkFeedApp
//
//  Created by Jimit Shah on 2/17/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^onComplete)(NSDictionary * _Nullable dataDict, NSString * _Nullable errMessage);

@interface HTTPService : NSObject
  
+ (id _Nullable) instance;
- (void) getImages:(nullable onComplete)completionHandler;
- (NSURL *_Nonnull)URLByAppendingQueryParameters:(NSString *_Nonnull)baseURL withQueryParameters:(NSDictionary *_Nullable)queryParameters;
@end

