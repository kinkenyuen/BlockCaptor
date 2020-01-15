//
//  BlockCaptor.m
//  Tweak
//
//  Created by ruanjianqin on 2020/1/15.
//

#import "BlockCaptor.h"

struct Block_literal_1 {
    void *isa; // initialized to &_NSConcreteStackBlock or &_NSConcreteGlobalBlock
    int flags;
    int reserved;
    void (*invoke)(void *, ...);
    struct Block_descriptor_1 {
        unsigned long int reserved;         // NULL
        unsigned long int size;         // sizeof(struct Block_literal_1)
        // optional helper functions
        void (*copy_helper)(void *dst, void *src);     // IFF (1<<25)
        void (*dispose_helper)(void *src);             // IFF (1<<25)
        // required ABI.2010.3.16
        const char *signature;                         // IFF (1<<30)
    } *descriptor;
    // imported variables
};

enum {
    BLOCK_DEALLOCATING =      (0x0001),  // runtime
    BLOCK_REFCOUNT_MASK =     (0xfffe),  // runtime
    BLOCK_NEEDS_FREE =        (1 << 24), // runtime
    BLOCK_HAS_COPY_DISPOSE =  (1 << 25), // compiler
    BLOCK_HAS_CTOR =          (1 << 26), // compiler: helpers have C++ code
    BLOCK_IS_GC =             (1 << 27), // runtime
    BLOCK_IS_GLOBAL =         (1 << 28), // compiler
    BLOCK_USE_STRET =         (1 << 29), // compiler: undefined if !BLOCK_HAS_SIGNATURE
    BLOCK_HAS_SIGNATURE  =    (1 << 30), // compiler
    BLOCK_HAS_EXTENDED_LAYOUT=(1 << 31)  // compiler
};

typedef int Block_Flags;

@implementation BlockCaptor

+ (void)captureBlockFuncPtrAndSignature:(id)block {
    struct Block_literal_1 *block_ptr = (__bridge struct Block_literal_1 *)block;
    void *invoke = block_ptr->invoke;
    NSLog(@"block func_ptr : %p",invoke);
    Block_Flags flags = block_ptr->flags;
    if (flags & BLOCK_HAS_SIGNATURE) {
        void *signature = block_ptr->descriptor;
        signature += sizeof(unsigned long int) * 2;
        
        if (flags & BLOCK_HAS_COPY_DISPOSE) {
            signature += sizeof(void(*)(void *dst, void *src));
            signature += sizeof(void (*)(void *src));
        }
        
        const char *_signature = (*(const char **)signature);
        NSLog(@"block signature : %s",_signature);
        NSMethodSignature *s = [NSMethodSignature signatureWithObjCTypes:_signature];
        NSLog(@"%@",[NSString stringWithFormat:
                     @"numberOfArguments : %lu\n"
                     @"methodReturnType  : %s\n",
                     (unsigned long)s.numberOfArguments,
                     s.methodReturnType]);
        for (int i = 0; i < s.numberOfArguments; i++) {
            NSLog(@"argument %@：%@", @(i), [NSString stringWithUTF8String:[s getArgumentTypeAtIndex:i]]);
        }
        return;
    }
    NSLog(@"block does not have any signature");
}

@end
