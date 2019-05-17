//
//  DANetworkManager.m
//  DuiFuDao
//
//  Created by weiguang on 2018/7/25.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#import "KZNetworkManager.h"


@interface KZNetworkManager ()

@property (nonatomic,strong) AFHTTPSessionManager *manager;

//保存task的dic
@property (nonatomic, strong) NSMutableDictionary *requestTasks;

@end


@implementation KZNetworkManager


+ (instancetype)defaultManager {
    static KZNetworkManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        
    });
    return instance;
}


// 配置mananger
- (AFHTTPSessionManager *)configAFNManager:(NSString *)baseUrlString {
    // 拼接参数，得到完整的接口地址
    NSURL *baseUrl = [NSURL URLWithString:baseUrlString];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:baseUrl];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/plain", @"text/javascript", @"text/xml", @"image/*",@"json/text", nil];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.requestSerializer.timeoutInterval = 20;
   // [manager.requestSerializer setValue:[KZAppManager getuuid] forHTTPHeaderField:@"uuid"];
    
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    return manager;
}



+ (void)GET:(NSString *)URL
 parameters:(id)parameters
completeHandler:(ResponseCallBack)responseCallBack {
    
    [self requestType:GET path:URL paramters:parameters completeHandler:responseCallBack];
}

+ (void)POST:(NSString *)URL
  parameters:(id)parameters
completeHandler:(ResponseCallBack)responseCallBack {
    
    [self requestType:POST path:URL paramters:parameters completeHandler:responseCallBack];
    
}



+ (void)uploadFileWithURL:(NSString *)URL
                imageData:(NSData *)imageData
               parameters:(NSDictionary *)parameters
                 progress:(ProgressCallBack)progress
          completeHandler:(ResponseCallBack)responseCallBack {
    
    NSString *pathUrl = [NSString stringWithFormat:@"%@%@",KZBaseURL,URL];

    // 创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/plain",@"multipart/form-data"]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [tempDict setObject:[KZAppManager getuuid] forKey:@"uuid"];
    parameters = tempDict;
    
    // 发送post请求上传路径
    [manager POST:pathUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formormat = [[NSDateFormatter alloc]init];
        [formormat setDateFormat:@"HHmmss"];
        NSString *dateString = [formormat stringFromDate:date];
        NSString *fileName = [NSString  stringWithFormat:@"%@.png",dateString];
        
        //使用formData拼接数据
        [formData appendPartWithFileData:imageData name:@"headPic" fileName:fileName mimeType:@"image/*"];
    }progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
        
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        NSLog(@"%@",str);
        NSDictionary *datas = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
        responseCallBack(datas,nil);
        
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        responseCallBack(nil,error);
    }];
    
    
}

+ (void)uploadFileWithURL:(NSString *)URL
                videoData:(NSData *)videoData
               parameters:(NSDictionary *)parameters
                 progress:(ProgressCallBack)progress
          completeHandler:(ResponseCallBack)responseCallBack
{
    
    NSString *pathUrl = [NSString stringWithFormat:@"%@%@",KZBaseURL,URL];
    
    // 创建会话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"text/plain",@"multipart/form-data"]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [tempDict setObject:[KZAppManager getuuid] forKey:@"uuid"];
    parameters = tempDict;
    
    // 发送post请求上传路径
    [manager POST:pathUrl parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        NSDate *date = [NSDate date];
        NSDateFormatter *formormat = [[NSDateFormatter alloc]init];
        [formormat setDateFormat:@"HHmmss"];
        NSString *dateString = [formormat stringFromDate:date];
        NSString *fileName = [NSString  stringWithFormat:@"%@.mp4",dateString];
        
        //使用formData拼接数据
        [formData appendPartWithFileData:videoData name:@"headPic" fileName:fileName mimeType:@"video/*"];
    }progress:^(NSProgress * _Nonnull uploadProgress) {
        progress(uploadProgress);
        
    }success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        //        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        //        NSLog(@"%@",str);
        NSDictionary *datas = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers | NSJSONReadingMutableLeaves error:nil];
        responseCallBack(datas,nil);
        
    }failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        responseCallBack(nil,error);
    }];
    
}


+ (void)downloadFileWithURL:(NSString *)URL
                 parameters:(id)parameters
                   progress:(ProgressCallBack)progress
            completeHandler:(ResponseCallBack)responseCallBack
{
    
    NSString *pathUrl = URL;
    
    //创建传话管理者
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:pathUrl]];
    //下载文件
    /*
     第一个参数:请求对象
     第二个参数:progress 进度回调
     第三个参数:destination 回调(目标位置)
     有返回值
     targetPath:临时文件路径
     response:响应头信息
     第四个参数:completionHandler 下载完成后的回调
     filePath:最终的文件路径
     */
    NSURLSessionDownloadTask *download = [manager downloadTaskWithRequest:request
                                                                 progress:^(NSProgress * _Nonnull downloadProgress) {
                                                                     //下载进度
                                                                     //NSLog(@"%f",1.0 * downloadProgress.completedUnitCount / downloadProgress.totalUnitCount);
                                                                     progress(downloadProgress);
                                                                 }
                                                              destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
                                                                  //保存的文件路径
                                                                  NSString *fullPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:response.suggestedFilename];
                                                                  return [NSURL fileURLWithPath:fullPath];
                                                                  
                                                              }
                                                        completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
                                                            
                                                            DLog(@"%@",filePath);
                                                            
                                                            responseCallBack(filePath,error);
                                                        }];
    
    //执行Task
    [download resume];
}


// 网络请求核心
+ (void)requestType:(RequestMethod)requestType
               path:(NSString *)path
          paramters:(id)paramter
    completeHandler:(ResponseCallBack)responseCallBack
{
    KZNetworkManager *netWorkManager = [KZNetworkManager defaultManager];

    AFHTTPSessionManager *manager = [netWorkManager configAFNManager:KZBaseURL];
    
    if ([paramter isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tempDict = [NSMutableDictionary dictionaryWithDictionary:paramter];
        [tempDict setObject:[KZAppManager getuuid] forKey:@"uuid"];
        paramter = tempDict;
    }
    
    NSURLSessionDataTask *task = nil;
    switch (requestType) {
        case GET:
        {
            
            task = [manager GET:path parameters:paramter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                //打印相关数据
                [self logUrl:[manager.baseURL.absoluteString stringByAppendingString:path] respondse:responseObject parameters:paramter requestOperation:task];
                
                [netWorkManager clearTaskSessionWithUrl:path];
                
                //处理返回数据
                [self handleTask:task response:responseObject completeHandler:responseCallBack];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                //打印相关数据
                [self logUrl:[manager.baseURL.absoluteString stringByAppendingString:path] respondse:error parameters:paramter requestOperation:task];
                
                if (error.code != NSURLErrorCancelled){
                    [netWorkManager clearTaskSessionWithUrl:path];
                }
                
                [self handdleError:error completeHandler:responseCallBack];
                
            }];
        }
            
            break;
            
        case POST:
        {
            task = [manager POST:path parameters:paramter progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                //打印相关数据
                [self logUrl:[manager.baseURL.absoluteString stringByAppendingString:path] respondse:responseObject parameters:paramter requestOperation:task];
                
                [netWorkManager clearTaskSessionWithUrl:path];
                
                //处理返回数据
                [self handleTask:task response:responseObject completeHandler:responseCallBack];
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                //打印相关数据
                [self logUrl:[manager.baseURL.absoluteString stringByAppendingString:path] respondse:error parameters:paramter requestOperation:task];
                
                if (error.code != NSURLErrorCancelled){
                    [netWorkManager clearTaskSessionWithUrl:path];
                }
                // 处理失败情况
                [self handdleError:error completeHandler:responseCallBack];
                
            }];
        }
            break;
            
        default:
            break;
    }
    
    [netWorkManager addLastTaskSessionWithUrl:path currentTaskSession:task];
}


/// 处理失败的信息
+ (void)handdleError:(NSError *)error
     completeHandler:(ResponseCallBack)responseCallBack {
    NSDictionary *userInfo = error.userInfo;
    NSString *message = userInfo[@"NSLocalizedDescription"];
    if (responseCallBack){
        
        if (message.length != 0){
            NSError *error1 = [NSError errorWithDomain:message code:error.code userInfo:nil];
            responseCallBack(nil,error1);
        }else{
            responseCallBack(nil,error);
        }
    }
}

// 处理成功的信息
+(void)handleTask:(NSURLSessionDataTask *)task response:(id )responseObject completeHandler:(ResponseCallBack)responseCallBack{
    if (responseObject && [responseObject isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictObject = (NSDictionary *)responseObject;
        NSInteger code = [[dictObject valueForKey:@"code"] integerValue];
        if (code == 200) { // 业务逻辑意义上的正确返回
            
            NSDictionary *dict = (NSDictionary *)responseObject[@"data"];
            responseCallBack(dict,nil);
            
        }else {
            NSError *error = [NSError errorWithDomain:responseObject[@"msg"] code:code userInfo:nil];
            responseCallBack(nil,error);
        }
        
    }else { // 数据异常
        NSError *error = [NSError errorWithDomain:@"服务器返回数据异常" code:-1 userInfo:nil];
        responseCallBack(nil,error);
    }
}



//显示成功的信息
+ (void)logUrl:(NSString *)url respondse:(id )responseObject parameters:(id )parameters requestOperation:(NSURLSessionDataTask * _Nullable) operation{
    DLog(@"返回信息====>>\n申请地址:%@\n返回数据%@\n上传数据:%@\n\n",url,responseObject,parameters);
    
    DLog(@"allHTTPHeaderFields:%@",operation.currentRequest.allHTTPHeaderFields);
}

//将url和parameters转换为key
+ (NSString *)cacheKeyWithURL:(NSString *)URL parameters:(NSDictionary *)parameters {
    if(!parameters){return URL;};
    // 将参数字典转换成字符串
    NSData *stringData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSString *paraString = [[NSString alloc] initWithData:stringData encoding:NSUTF8StringEncoding];
    
    // 将URL与转换好的参数字符串拼接在一起,成为最终存储的KEY值
    NSString *cacheKey = [NSString stringWithFormat:@"%@%@",URL,paraString];
    
    return cacheKey;
}


/** 添加url绑定的sessionTask */
- (void)addLastTaskSessionWithUrl:(NSString *)url currentTaskSession:(NSURLSessionTask *)task
{
    [self.requestTasks setObject:task forKey:url];
}

/** 清除url绑定的sessionTask */
- (void)clearTaskSessionWithUrl:(NSString *)url
{
    [self.requestTasks removeObjectForKey:url];
}

+ (BOOL)isWWANNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWWAN;
}

+ (BOOL)isWiFiNetwork {
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

+ (BOOL)isReachable {
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}


+ (void )cancelRequest:(NSString *)url{
    [[KZNetworkManager defaultManager] cancelRequest:url];
}

- (void )cancelRequest:(NSString *)url
{
    NSURLSessionTask *lastSessionTask = [self.requestTasks objectForKey:url];
    
    [lastSessionTask cancel];
}


@end

