//
//  ViewController.m
//  GCD
//  原博文   https://www.jianshu.com/p/2d57c72016c6
//  Created by mac on 2018/4/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}
- (IBAction)performTasks:(id)sender {
    NSLog(@"currentThread   ---- %@", [NSThread currentThread]);

//    [self syncSerialQueue];
//    [self syncConcurrentQueue];
//    [self asyncConcurrentQueue];
//    [self asyncSerial];
//    [self syncMain]; // 死锁
//    [self communication];  线程通信
//    [self barrier];    // 栅栏 限制先后执行的顺序，先执行栅栏前面的后执行栅栏后面的
//    [self after];      //延迟执行
//    [self apply];        //快速迭代
//    [self groupNotify];    //执行完group中其他所有任务，再执行notify中的任务
//    [self groupWait];        // dispatch_group_wait 等wait前面的任务都执行结束再执行wait后面的任务，这也是和groupNotify的区别
    [self groupEnterAndLeave];  //dispatch_group_enter 向group中添加任务，任务执行完毕，dispatch_group_leave   
}
#pragma mark ------- dispatch_semaphore GCD信号量

#pragma mark --------- dispatch_group_enter, dispatch_group_leabe
-(void)groupEnterAndLeave
{
    NSLog(@"enter groupEnterAndLeave");
    NSLog(@"13 1111111111111 currentThread = %@",[NSThread currentThread]);
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_enter(group);
    dispatch_async(globalQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"13 22222222222222 currentThread = %@",[NSThread currentThread]);
        dispatch_group_leave(group);
    });
    dispatch_group_enter(group);
    dispatch_async(globalQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"13 33333333333333333 currentThread = %@",[NSThread currentThread]);
        dispatch_group_leave(group);
    });
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"13 4444444444444444 currentThread = %@",[NSThread currentThread]);
    });
    NSLog(@"13 555555555555555 end ----------");
    
    
}

#pragma mark --------暂停当前线程 dispatch_group_wait
-(void)groupWait
{
    NSLog(@"12 1111111111111111111 currentThread = %@",[NSThread currentThread]);
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, globalQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"12 222222222222222 currentThread = %@",[NSThread currentThread]);
    });
    dispatch_group_async(group, globalQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"12 3333333333333 currentThread = %@",[NSThread currentThread]);
    });
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    NSLog(@"12  444444444444444  end-----------");
    dispatch_group_async(group, globalQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"12 5555555555555 currentThead = %@",[NSThread currentThread]);
    });
}

#pragma mark ------- 队列组dispatch_group
-(void)groupNotify
{
    NSLog(@" begin 11 111111111111111 currentThread is %@", [NSThread currentThread]);
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_async(group, globalQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"11 222222222222222 currentThread is %@", [NSThread currentThread]);
    });
    dispatch_group_async(group, globalQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"11 333333333333333 currentThread is %@",[NSThread currentThread]);
    });
    dispatch_group_notify(group, globalQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"11 666666666666666 currentThread is %@",[NSThread currentThread]);
    });
    dispatch_group_async(group, globalQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"11 444444444444444 currentThread is %@",[NSThread currentThread]);
    });

    NSLog(@"end 11 5555555555555555555555555");
}

#pragma mark ------ dispatch_apply  快速迭代方法  for循环一次取出一个数字逐个遍历，dispatch_apply在多个线程同时遍历多个数字
-(void)apply
{
    NSLog(@"apply --------- begin");
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_apply(6, queue, ^(size_t index) {
        NSLog(@"10 1111111111111 index =  %zd, currentThread = %@",index,[NSThread currentThread]);
    });
    NSLog(@"apply --------- end");
}

#pragma mark ------ 只执行一次
-(void)once
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"9 1111111111 %@",[NSThread currentThread]);
    });
    
}

#pragma mark ----延时执行
-(void)after
{
    NSLog(@"currentThead -------- %@", [NSThread currentThread]);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSLog(@"8 11111111111111111currentThead ---------- %@",[NSThread currentThread]);
    });
}

#pragma makr -----栅栏方法
-(void)barrier
{
    dispatch_queue_t queue = dispatch_queue_create("queue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"7 1111111111 currentThread is %@", [NSThread currentThread]);
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"7 22222222222 currentThread is %@",[NSThread currentThread]);
    });
    dispatch_barrier_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"7 3333333333 currentThread is %@", [NSThread currentThread]);
    });
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"7 4444444444 currentThread is %@", [NSThread currentThread]);
    });
}

#pragma mark -------- GCD线程的通信回到主线程
-(void)communication
{
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"611111111111111 currentThread is %@", [NSThread currentThread]);
    });
    dispatch_async(mainQueue, ^{      //回到主线程
        [NSThread sleepForTimeInterval:1];
        NSLog(@"6222222222222222 currentThread is %@",[NSThread currentThread]);
    });
}

#pragma mark ---- 同步任务主队列 出现死锁 Thread 1: EXC_BAD_INSTRUCTION (code=EXC_I386_INVOP, subcode=0x0)
-(void)syncMain
{
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    dispatch_sync(mainQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"511111111111 currentThread is %@",[NSThread currentThread]);
    });
    dispatch_sync(mainQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"5222222222222 currentThread is %@", [NSThread currentThread]);
    });
    dispatch_sync(mainQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"5333333333333 currentThread is %@", [NSThread currentThread]);
    });
}

#pragma mark -------- 异步串行 开辟1个新线程 one by one执行
-(void)asyncSerial
{
    dispatch_queue_t syncConcurrentQueue = dispatch_queue_create("syncConcurrent", DISPATCH_QUEUE_SERIAL);
    dispatch_async(syncConcurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"4111111111111111 currentThread is %@",[NSThread currentThread]);
    });
    dispatch_async(syncConcurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"422222222222222 currentThread is %@",[NSThread currentThread]);
    });
    dispatch_async(syncConcurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"433333333333333 currentThread is %@",[NSThread currentThread]);
    });
}
#pragma makr ----- 异步并行     开辟3个新线程
-(void)asyncConcurrentQueue
{
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"311111111111111 currentThread is %@",[NSThread currentThread]);
    });
    dispatch_async(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"322222222222222 currentThread is %@",[NSThread currentThread]);
    });
    dispatch_async(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"333333333333333 currentThrad is %@", [NSThread currentThread]);
    });
}
#pragma mark ---- 同步并行     未开辟新线程 在当前线程执行
-(void)syncConcurrentQueue
{
    
    dispatch_queue_t concurrentQueue = dispatch_queue_create("concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    dispatch_sync(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"11111111111 currentThread = %@", [NSThread currentThread]);
    });
    dispatch_sync(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"22222222222 currentThread is %@", [NSThread currentThread]);
    });
    dispatch_sync(concurrentQueue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"33333333333 currentThread is %@", [NSThread currentThread]);
    });
}

#pragma mark ----- 同步串行   未开辟线程，在当前线程执行
-(void)syncSerialQueue
{
    dispatch_queue_t serialQueue = dispatch_queue_create("net.bujige.testQueue", DISPATCH_QUEUE_SERIAL);
    
    
    dispatch_sync(serialQueue, ^{
            [NSThread sleepForTimeInterval:1];
            NSLog(@"111111111111111 currentThead = %@",[NSThread currentThread]);
    });
    dispatch_sync(serialQueue, ^{
            [NSThread sleepForTimeInterval:1];
            NSLog(@"222222222222222 currentThread = %@",[NSThread currentThread]);
    });
    dispatch_sync(serialQueue, ^{
            [NSThread sleepForTimeInterval:1];
            NSLog(@"33333333333333 currentThread = %@", [NSThread currentThread]);
    });
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
