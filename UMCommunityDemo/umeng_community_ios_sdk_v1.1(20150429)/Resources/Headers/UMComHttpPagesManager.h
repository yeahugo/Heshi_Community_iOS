//
//  UMComHttpPagesManager.h
//  UMCommunity
//
//  Created by luyiyuan on 14/10/28.
//  Copyright (c) 2014年 Umeng. All rights reserved.
//

#import "UMComHttpPagesRequest.h"


#pragma mark -
#pragma mark User



@interface UMComHttpPagesUserFeeds : UMComHttpPagesRequest
//获取用户首页的feeds
- (id)initWithCount:(NSUInteger)count response:(PageDataResponse)response;
@end

@interface UMComHttpPagesOneFeed : UMComHttpPagesRequest
//获取单个feed
- (id)initWithFeedId:(NSString *)feedId response:(PageDataResponse)response;
@end



@interface UMComHttpPagesUserTimeline : UMComHttpPagesRequest
//获取用户自己发布的时间线
- (id)initWithCount:(NSUInteger)count uid:(NSString *)uid response:(PageDataResponse)response;
@end

@interface UMComHttpPagesUserTopics : UMComHttpPagesRequest
//获取用户的已关注的话题(注意，已关注的话题不需要再获取，第一次进入需要获取)
- (id)initWithCount:(NSUInteger)count uid:(NSString *)uid response:(PageDataResponse)response;
@end

@interface UMComHttpPagesUserFans : UMComHttpPagesRequest
//获取用户的粉丝
- (id)initWithCount:(NSUInteger)count uid:(NSString *)uid response:(PageDataResponse)response;
@end

@interface UMComHttpPagesUserFollowings : UMComHttpPagesRequest
//获取用户的关注人
- (id)initWithCount:(NSUInteger)count uid:(NSString *)uid response:(PageDataResponse)response;
@end

@interface UMComHttpUserProfile : UMComHttpPagesRequest

- (id)initWithUid:(NSString *)uid response:(LoadDataCompletion)response;

@end


#pragma mark -
#pragma mark Feed

@interface UMComHttpPagesComments : UMComHttpPagesRequest

//获取消息对应的所有评论
- (id)initWithFeedId:(NSString *)feedId response:(PageDataResponse)response;

@end

@interface UMComHttpPagesFeedLikes : UMComHttpPagesRequest

- (id)initWithFeedId:(NSString *)feedId response:(PageDataResponse)response;

@end

#pragma mark -
#pragma mark topic



@interface UMComHttpPagesTopics : UMComHttpPagesRequest
//获取所有的话题
- (id)initWithCount:(NSUInteger)count response:(PageDataResponse)response;
@end

@interface UMComHttpPagesTopicsSearch : UMComHttpPagesRequest
//话题搜索
- (id)initWithCount:(NSUInteger)count keywords:(NSString *)keywords response:(PageDataResponse)response;

@end

@interface UMComHttpPagesTopicFeeds : UMComHttpPagesRequest
//获取该话题下的feeds
- (id)initWithCount:(NSUInteger)count topicId:(NSString *)topicId response:(PageDataResponse)response;
@end



#pragma mark - recommend 

@interface UMComHttpPagesRecommendUsers : UMComHttpPagesRequest

- (id)initWithCount:(NSInteger)count response:(PageDataResponse)response;

@end

@interface UMComHttpPagesRecommendFeeds : UMComHttpPagesRequest

- (id)initWithCount:(NSInteger)count response:(PageDataResponse)response;

@end

@interface UMComHttpPagesRecommendTopics : UMComHttpPagesRequest

- (id)initWithCount:(NSInteger)count response:(PageDataResponse)response;

@end

@interface UMComHttpPagesRecommendTopicUsers : UMComHttpPagesRequest

- (id)initWithCount:(NSInteger)count topicId:(NSString *)topicId response:(PageDataResponse)response;
@end

