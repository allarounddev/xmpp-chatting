/*
 * GITIDToken.h
 * Identity Toolkit iOS SDK
 *
 * Copyright (c) 2014 Google Inc. All rights reserved.
 */

#import <Foundation/Foundation.h>

/**
 * An id token issued by Identity Toolkit server.
 */
@interface GITIDToken : NSObject

/** The original token string returned from Identity Toolkit server. */
@property(nonatomic, copy) NSString *tokenString;
/** Email address in the token. */
@property(nonatomic, copy) NSString *email;
/** Local id in the token. */
@property(nonatomic, copy) NSString *localID;
/** Audience in the token. */
@property(nonatomic, copy) NSString *audience;
/** Issue timestamp in the token. */
@property(nonatomic, copy) NSNumber *issueAt;
/** Expiration timestamp in the token. */
@property(nonatomic, copy) NSNumber *expireAt;
/** Provider id in the token. */
@property(nonatomic, copy) NSString *providerID;

/**
 * Designated initializer.
 *
 * @param tokenString the original token string from Identity Toolkit server.
 */
- (instancetype)initWithString:(NSString *)tokenString;

/**
 * Writes the id token as cookie in cookie storage.
 */
- (void)writeCookie;

/**
 * Constructs a |GITIDToken| from token string.
 *
 * @param tokenString the original token string from Identity Toolkit server.
 */
+ (GITIDToken *)tokenWithString:(NSString *)tokenString;

@end
