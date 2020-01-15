//
//  BlockCaptor.h
//  Tweak
//
//  Created by ruanjianqin on 2020/1/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface BlockCaptor : NSObject
+ (void)captureBlockFuncPtrAndSignature:(id)block;
@end

NS_ASSUME_NONNULL_END
