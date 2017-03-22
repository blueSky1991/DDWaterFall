//
//  DDWaterFolwView.h
//  DDWaterFall
//
//  Created by imac on 15/10/24.
//  Copyright (c) 2015年 zhangdongdong. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DDWaterFolwViewMarginTypeTop = 0,   //顶部
    DDWaterFolwViewMarginTypeBottom,    //底部
    DDWaterFolwViewMarginTypeLeft,      //左部
    DDWaterFolwViewMarginTypeRight,     //右部
    DDWaterFolwViewMarginTypeRow,       //每一行
    DDWaterFolwViewMarginTypecolumn,    //每一列
}DDWaterFolwViewMarginType;

@class DDWaterFolwView,DDWaterFlowViewCell;
#pragma mark --  DDWaterFolwView的数据源方法
@protocol DDWaterFolwViewDataSource <NSObject>

@required
/**
 * 一共有多少个Cell
 */
- (NSUInteger)numberOfCellsInWaterflowView:(DDWaterFolwView *)waterflowView;
/**
 *每行显示返回的cell
 */
- (DDWaterFlowViewCell *)waterflowView:(DDWaterFolwView *)waterflowView cellAtIndex:(NSUInteger)index;
@optional
/**
 *  一共有多少列，不设置的话默认为3
 */
- (NSUInteger)numberOfColumnsInWaterflowView:(DDWaterFolwView *)waterflowView;

@end
#pragma mark --  DDWaterFolwView的代理方法

@protocol DDWaterFolwViewDelegate <UIScrollViewDelegate,NSObject>

@optional
/**
 *  返回每个cell的高度
 */
- (CGFloat)waterflowView:(DDWaterFolwView *)waterflowView heightForCellAtIndex:(NSInteger)index;
/**
 *  单元格的点击事件
 */
- (void)waterflowView:(DDWaterFolwView *)waterflowView didSelectCellAtIndex:(NSInteger)index;
/**
 *  获取cell的宽度
 */
- (CGFloat)widthForCell;

/**
 *  返回间距
 */
- (CGFloat)waterflowView:(DDWaterFolwView *)waterflowView marginForType:(DDWaterFolwViewMarginType)type;

@end

@interface DDWaterFolwView : UIScrollView
/**
 *  数据源
 */
@property (nonatomic,weak)id <DDWaterFolwViewDataSource> dataSource;
/**
 *  代理
 */
@property (nonatomic,weak)id <DDWaterFolwViewDelegate> delegate;

/**
 *  刷新数据源的方法
 */
- (void)reloadData;
/**
 *  根据标识向缓存池中取出可以复用的cell
 */
- (id)dequeueReusableCellWithIdentifier:(NSString *)identifier;


@end
