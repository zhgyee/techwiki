# Introduction #

Add your content here.


# Details #
  1. 建立分支 repo start workspace --all

  1. 查看分支 repo branch

  1. repo status 查看那些project有更改

  1. 进入对应的project， git status 查看所有更新文件列表

  1. git add 将要提交的代码添加到缓冲

  1. git diff --check

  1. git commit -as  将代码提交到本地配置库输入这个后会让你输入提交Log



# 提交代码 #
  1. 建立分支 repo start workspace --all
  1. 查看分支 repo branch
  1. repo status 查看那些project有更改
  1. 进入对应的project， git status 查看所有更新文件列表
  1. git add 将要提交的代码添加到缓冲
  1. git diff --check
  1. git commit -as  将代码提交到本地配置库输入这个后会让你输入提交Log

# 生成patch时需要 #
  1. git log 查看提交的Log 找出你提交的唯一ID
  1. git format-patch ID 根据你的ID制作patch
  1. 将pathc提交审核

# reviewer名单 可以再写log时写上 #
  1. git commit --amend  将审核人的信息 添加到log中

# 每次提交都需要 #
  1. repo upload 提交到中心库.