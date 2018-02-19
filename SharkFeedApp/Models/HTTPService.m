//
//  HTTPService.m
//  SharkFeedApp
//
//  Created by Jimit Shah on 2/17/18.
//  Copyright © 2018 Jimit Shah. All rights reserved.
//

#import "HTTPService.h"
// example: https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=949e98778755d1982f537d56236bbb42&text=shark&format=json&nojsoncallback=1&page=1&extras=url_t,url_c,url_l,url_o
#define URL_BASE "https://api.flickr.com/services/rest/"
#define URL_API "949e98778755d1982f537d56236bbb42"
#define URL_METHOD "flickr.photos.search"
#define URL_TEXT "shark"
#define URL_FORMAT "json"
#define URL_NOJSONCALLBACK "1"
#define URL_EXTRAS "url_t,url_c,url_l,url_o"
#define URL_TAGS "great white sharks, tiger shark, blue shark, mako shark, hammerhead shark"
#define URL_SAFESEARCH "1"
#define URL_CONTENTTYPE "1"

@interface  HTTPService() {
  int pageNumber;
}
@end

@implementation HTTPService

+ (id) instance {
  static HTTPService *sharedInstance = nil;
  
  @synchronized(self) {
    if (sharedInstance == nil) {
      sharedInstance = [[self alloc]init];
    }
  }
  return sharedInstance;
}

- (void) getImages:(nullable onComplete)completionHandler {
  
  NSURLSession *session = [NSURLSession sharedSession];
  
  // generate random number for page number
  //int randomInt = arc4random_uniform(25);
  NSLog(@"Fetching images from page: %@",[@(pageNumber) stringValue]);
  pageNumber += 1;
  
  NSDictionary *parameters = @{
                               @"method":@URL_METHOD,
                               @"api_key": @URL_API,
                               @"text": @URL_TEXT,
                               @"format": @URL_FORMAT,
                               @"nojsoncallback": @URL_NOJSONCALLBACK,
                               @"page": [@(pageNumber) stringValue],
                               @"extras": @URL_EXTRAS,
                               @"safe_search": @URL_SAFESEARCH,
                               @"content_type": @URL_CONTENTTYPE,
                               @"tags": @URL_TAGS
                               };
  
  // call helper method to build url with parameters
  NSURL *url = [self URLByAppendingQueryParameters:@URL_BASE withQueryParameters:parameters];
  NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:url];
  request.HTTPMethod = @"GET";
  
  NSLog(@"Request %@",request.debugDescription);
  
  NSURLSessionDataTask *downloadTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
    
    if (data != nil) {
      NSError *err;
      NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
      
      if (httpResp.statusCode >= 200 && httpResp.statusCode <= 299) {
        
        NSDictionary* json = [NSJSONSerialization
                              JSONObjectWithData:data
                              options:kNilOptions
                              error:&err];
        
        if (err == nil) {
          completionHandler(json, nil);
        } else {
          completionHandler(nil, [@"Data parsing error: " stringByAppendingString: err.debugDescription]);
        }
      } else {
        completionHandler(nil, @"Your request returned a status code other than 2xx!");
      }
    } else {
      NSLog(@"Network Error: %@", error.debugDescription);
      completionHandler(nil, @"Problem connecting to the server, please try again later.");
    }
  }];
  [downloadTask resume];
}

// MARK: - URLByAppendingQueryParameters withQueryParameters
- (NSURL *_Nonnull)URLByAppendingQueryParameters:(NSString *_Nonnull)baseURL withQueryParameters:(NSDictionary *)queryParameters
{
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@",baseURL]];
  if (queryParameters == nil) {
    return url;
  } else if (queryParameters.count == 0) {
    return url;
  }
  
  NSArray *queryKeys = [queryParameters allKeys];
  NSURLComponents *components = [[NSURLComponents alloc] initWithURL:url resolvingAgainstBaseURL:NO];
  NSMutableArray * newQueryItems = [NSMutableArray arrayWithCapacity:1];
  
  for (NSURLQueryItem * item in components.queryItems) {
    if (![queryKeys containsObject:item.name]) {
      [newQueryItems addObject:item];
    }
  }
  
  for (NSString *key in queryKeys) {
    NSURLQueryItem * newQueryItem = [[NSURLQueryItem alloc] initWithName:key value:queryParameters[key]];
    [newQueryItems addObject:newQueryItem];
  }
  
  [components setQueryItems:newQueryItems];
  
  return [components URL];
}


@end
