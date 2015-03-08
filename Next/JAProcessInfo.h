#import <Foundation/Foundation.h>

@interface JAProcessInfo : NSObject {
    
@private
    int numberOfProcesses;
    NSMutableArray *processList;
}

@property (assign) int numberOfProcesses;
@property (readonly) NSMutableArray* processList;

- (id) init;
- (void)obtainFreshProcessList;
- (BOOL)findProcessWithName:(NSString *)procNameToSearch;

@end