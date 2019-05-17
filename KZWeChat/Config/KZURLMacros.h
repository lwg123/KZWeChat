//
//  DAURLMacros.h
//  DuiFuDao
//
//  Created by weiguang on 2018/7/23.
//  Copyright © 2018年 DuiA. All rights reserved.
//

#ifndef DAURLMacros_h
#define DAURLMacros_h

//#define TestUrl  0  //测试环境
#define OnLineUrl 0 //正式环境


//测试环境
#ifdef TestUrl

#define KZBaseURL @"http://liaobei.ewm.wiki/"

#endif


// 上线环境
#ifdef OnLineUrl

#define KZBaseURL @"https://liaobei.ewm.wiki/"

#endif


#endif /* DAURLMacros_h */
