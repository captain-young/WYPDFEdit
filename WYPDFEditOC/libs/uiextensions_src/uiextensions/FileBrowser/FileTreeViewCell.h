/**
 * Copyright (C) 2003-2017, Foxit Software Inc..
 * All Rights Reserved.
 *
 * http://www.foxitsoftware.com
 *
 * The following code is copyrighted and is the proprietary of Foxit Software Inc.. It is not allowed to
 * distribute any parts of Foxit Mobile PDF SDK to third party or public without permission unless an agreement
 * is signed between Foxit Software Inc. and customers to explicitly grant customers permissions.
 * Review legal.txt for additional license and legal information.
 */

#import <UIKit/UIKit.h>
#import "FileTreeNode.h"

@protocol FileTreeViewCellDelegate;
@interface FileTreeViewCell : UITableViewCell
@property (assign, nonatomic) id <FileTreeViewCellDelegate> delegate;
@property (strong, nonatomic) FileTreeNode *node;
@property (strong, nonatomic) UIButton *buttonExpand;
@property (strong, nonatomic) UILabel *labelTitle;
@property (strong, nonatomic) UIImageView *imageFolder;
@property (strong, nonatomic) UILabel *labelSize;

- (void)buttonExpandClick:(id)sender;
@end

@protocol FileTreeViewCellDelegate <NSObject>
@optional
- (void)fileTreeViewCellExpand:(FileTreeViewCell *)cell node:(FileTreeNode *)node;
@end
