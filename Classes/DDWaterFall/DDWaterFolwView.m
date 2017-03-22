//
//  DDWaterFolwView.m
//  DDWaterFall
//
//  Created by imac on 15/10/24.
//  Copyright (c) 2015年 zhangdongdong. All rights reserved.
//

#import "DDWaterFolwView.h"
#import "DDWaterFlowViewCell.h"

#define DDWaterFolwViewDefaultCellHeight 70
#define DDWaterFolwViewDefaultNumberOfColuns 3
#define DDWaterFolwViewDefalutMargin 8


@interface DDWaterFolwView()
/** 存放cell的frame的数组 */
@property (nonatomic,strong)NSMutableArray *cellFrames;
/** 正在展示的cell */
@property (nonatomic,strong)NSMutableDictionary *disPlayCells;
/** 存放cell的缓存池  */
@property (nonatomic,strong)NSMutableSet *reusableCell;

@end


@implementation DDWaterFolwView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}
/** 存放cell的缓存池  */
-(NSMutableSet *)reusableCell{
    if (!_reusableCell) {
        _reusableCell = [NSMutableSet set];
    }
    return _reusableCell;
}
/** 存放cell的frame的数组 */
-(NSMutableArray *)cellFrames{
    if (!_cellFrames) {
        _cellFrames = [NSMutableArray array];
    }
    return _cellFrames;
}

/** 正在展示的cell */
-(NSMutableDictionary *)disPlayCells{

    if (!_disPlayCells) {
        _disPlayCells = [NSMutableDictionary dictionary];
    }
    return _disPlayCells;
}
/**
 *  系统自动监测当加载到父控件上的时候自动调用
 */
-(void)willMoveToSuperview:(UIView *)newSuperview{

    [self reloadData];
}

-(CGFloat)widthForCell{
    

    //总的列数
    NSUInteger numbersOfColums = [self numberOfColums];

    CGFloat leftMargin = [self marginForType:DDWaterFolwViewMarginTypeLeft];
    CGFloat rightMargin = [self marginForType:DDWaterFolwViewMarginTypeRight];
    CGFloat columsMargin = [self marginForType:DDWaterFolwViewMarginTypecolumn];
    
    //求出每个cell的宽度
    return  (self.bounds.size.width - leftMargin - rightMargin -(numbersOfColums - 1)*columsMargin)/numbersOfColums;

}

/**
 *  公共的接口（刷新数据）
 */
-(void)reloadData{
    
    
    
    // 清空之前的所有数据
    // 移除正在正在显示cell
        [self.disPlayCells.allValues makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.disPlayCells removeAllObjects];
        [self.cellFrames removeAllObjects];
        [self.reusableCell removeAllObjects];
    
    //总的cell的个数
    NSUInteger numberOfCells = [self.dataSource numberOfCellsInWaterflowView:self];
     //总的列数
    NSUInteger numbersOfColums = [self numberOfColums];
    

    
    //求出每个cell的间距
    CGFloat topMargin = [self marginForType:DDWaterFolwViewMarginTypeTop];
    CGFloat bottomMargin = [self marginForType:DDWaterFolwViewMarginTypeBottom];
    CGFloat leftMargin = [self marginForType:DDWaterFolwViewMarginTypeLeft];
    CGFloat rowMargin = [self marginForType:DDWaterFolwViewMarginTypeRow];
    CGFloat columsMargin = [self marginForType:DDWaterFolwViewMarginTypecolumn];
    
    //求出每个cell的宽度
    CGFloat cellW = [self widthForCell];

    //定义数组用来存放每列最大的Y值,并对数组进行初始化
    CGFloat maxYcolums[numbersOfColums];
    for (int i = 0; i < numbersOfColums; i ++) {
        maxYcolums[i] = 0.0;
    }
    
    // 计算所有cell的frame
    for (int i = 0; i<numberOfCells; i++) {
        // cell处在第几列(最短的一列)
        NSUInteger cellColumn = 0;
        // cell所处那列的最大Y值(最短那一列的最大Y值)
        CGFloat maxYOfCellColumn = maxYcolums[cellColumn];
        // 求出最短的一列
        for (int j = 1; j<numbersOfColums; j++) {
            if (maxYcolums[j] < maxYOfCellColumn) {
                cellColumn = j;
                maxYOfCellColumn = maxYcolums[j];
            }
        }
        //求出每个cell的高度
        CGFloat cellH = [self heightForCellAtIndex:i];

        //求出每个cell的X
        CGFloat cellX = leftMargin + cellColumn * (columsMargin + cellW);

        //求出每个cell的Y
        CGFloat cellY = 0;
        
        if (maxYOfCellColumn == 0) {
            
            cellY = topMargin;
            
        }else{
        
            cellY = maxYOfCellColumn+ rowMargin;
        }

        
        CGRect frame  =CGRectMake(cellX, cellY, cellW, cellH);
        [self.cellFrames addObject:[NSValue valueWithCGRect:frame]];
        
        //更新值
        maxYcolums[cellColumn] = CGRectGetMaxY(frame);
        
        //得到最大的Y值并赋值给self，使self能够滚动
        CGFloat contentH = maxYcolums[0];
        for (int j = 1; j<numbersOfColums; j++) {
            if (maxYcolums[j] < maxYOfCellColumn) {

                contentH = maxYcolums[j];
            }
        }

        contentH += bottomMargin;
        
        self.contentSize = CGSizeMake(0, contentH);
        
    }
    
}
-(void)layoutSubviews{
    [super layoutSubviews];
    
    NSUInteger count = self.cellFrames.count;

    for (int i = 0; i < count; i ++) {
        // 取出第i位置的frame
        CGRect frame = [self.cellFrames[i] CGRectValue];
        // 从字典中取出cell
        DDWaterFlowViewCell *cell = self.disPlayCells[@(i)];
        
        //判断该位置是否显示在屏幕上
        if ([self isInScreenWithFrame:frame]) {// 在屏幕上
            
            if (!cell) {//如果cell不存在，则从控制器中取
                cell = [self.dataSource waterflowView:self cellAtIndex:i];
                cell.frame = frame;
                [self addSubview:cell];
                // 把cell加进字典中
                self.disPlayCells[@(i)] =cell;
            }
            
        }else{// 不在屏幕上

            if (cell) {//cell已经存在且不在屏幕上
            
                [cell removeFromSuperview];//从屏幕上移除
                [self.disPlayCells removeObjectForKey:@(i)];//从展示的字典中移除
                [self.reusableCell addObject:cell];//加入到缓存池中
                
            }
            
        }
    }
    

}
-(id)dequeueReusableCellWithIdentifier:(NSString *)identifier{

    __block DDWaterFlowViewCell *reusableCell = nil;
    
    [self.reusableCell enumerateObjectsUsingBlock:^(DDWaterFlowViewCell *cell, BOOL *stop) {
        if ([cell.identifier isEqualToString:identifier]) {
            reusableCell = cell;
            *stop = YES;
        }
    }];
    
    if (reusableCell) {
        [self.reusableCell removeObject:reusableCell];
    }
    
    return reusableCell;
    
}
/**
 判断该位是否显示在屏幕上
 */
-(BOOL)isInScreenWithFrame:(CGRect)frame{


  return ((CGRectGetMinY(frame)<(self.contentOffset.y + self.bounds.size.height))&&(CGRectGetMaxY(frame)>self.contentOffset.y));

}

/**
 *  求烈数，如果代理没有设置列数的话，返回默认的列数3
 */
- (CGFloat)numberOfColums{
    if ([self.dataSource respondsToSelector:@selector(numberOfColumnsInWaterflowView:)]) {
        return [self.dataSource numberOfColumnsInWaterflowView:self];
    }else{
    
        return DDWaterFolwViewDefaultNumberOfColuns;
    }
}
/**
 *  根据设置的枚举类型返回响应的高度，没有设置的话默认返回8
*/
-(CGFloat)marginForType:(DDWaterFolwViewMarginType)type{
    if ([self.delegate waterflowView:self marginForType:type]) {
       return  [self.delegate waterflowView:self marginForType:type];
    }else{
        return DDWaterFolwViewDefalutMargin;
    }
}
/**
 * 根据每个位置返回该位置的cell对应的高度 ,如果代理没有设置的话默认返回默认的高度70
 */
- (CGFloat)heightForCellAtIndex:(NSInteger)index {

    if ([self.delegate waterflowView:self heightForCellAtIndex:index]) {
     return [self.delegate waterflowView:self heightForCellAtIndex:index];
    }else{
        return DDWaterFolwViewDefaultCellHeight;
    }
}
/**
 *  处理点击单元格的事件
 */
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    //如果代理没有实现点击事件的话直接返回
    if (![self.delegate respondsToSelector:@selector(waterflowView:didSelectCellAtIndex:)]) return;
    //取出点击的屏幕所在的点
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    __block NSNumber *selectedIndex = nil;
    //在屏幕显示的cell中遍历
    [self.disPlayCells enumerateKeysAndObjectsUsingBlock:^(id key, DDWaterFlowViewCell *cell, BOOL *stop) {
        if (CGRectContainsPoint(cell.frame, point)) {
            
            selectedIndex = key;
            *stop = YES;
        }
        
    }];
    
    if (selectedIndex) {
        [self.delegate waterflowView:self didSelectCellAtIndex:selectedIndex.unsignedIntegerValue];
    }

}

@end
