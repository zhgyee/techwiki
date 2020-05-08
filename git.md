# push
git push origin 901:refs/for/vs901

git push的一般形式为 git push <远程主机名> <本地分支名>  <远程分支名> ，例如 git push origin master：refs/for/master ，
即是将本地的master分支推送到远程主机origin上的对应master分支， origin 是远程主机名，
第一个master是本地分支名，第二个master是远程分支名。

1.1 git push origin master

	如果远程分支被省略，如上则表示将本地分支推送到与之存在追踪关系的远程分支（通常两者同名），如果该远程分支不存在，则会被新建

1.2 git push origin ：refs/for/master 

　　如果省略本地分支名，则表示删除指定的远程分支，因为这等同于推送一个空的本地分支到远程分支，等同于 git push origin --delete master

1.3 git push origin

　　 如果当前分支与远程分支存在追踪关系，则本地分支和远程分支都可以省略，将当前分支推送到origin主机的对应分支 

1.4 git push

　　如果当前分支只有一个远程分支，那么主机名都可以省略，形如 git push，可以使用git branch -r ，查看远程的分支名
　　
1.6 关于 refs/for

　　// refs/for 的意义在于我们提交代码到服务器之后是需要经过code review 之后才能进行merge的，而refs/heads 不需要　　

# 忽略文件mode改变 #
```
git config core.fileMode false

core.fileMode
       If false, the executable bit differences between the index and the
       working copy are ignored; useful on broken filesystems like FAT.
       See git-update-index(1). True by default.
The -c flag can be used to set this option for one-off commands:

git -c core.fileMode=false diff
And the --global flag will make it be the default behavior for the logged in user.

git config --global core.fileMode false
```

# gitconfig
在~/.gitconfig下加入下面快捷命令
```
[alias]
    br = branch
    aa = add --all
    bv = branch -vv
    ba = branch -ra
    bd = branch -d
    ca = commit --amend
    cb = checkout -b
    cm = commit -a --amend -C HEAD
    ci = commit
    co = checkout
    di = diff
    ll = log --pretty=format:"%C(yellow)%h%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --numstat
    ld = log --pretty=format:"%C(yellow)%h\\ %C(green)%ad%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=short --graph
    ls = log --pretty=format:"%C(green)%h\\ %C(yellow)[%ad]%Cred%d\\ %Creset%s%Cblue\\ [%cn]" --decorate --date=relative
    mm = merge --no-ff
    st = status --short --branch
    tg = tag -a 
    pu = push --tags
    un = reset --hard HEAD  
    uh = reset --hard HEAD^
```
# 生成补丁
```
git diff --binary > mypatch.patch
git format-patch
```
# apply patch
cd到patch相应的目录，执行下面命令打上补丁，如果有冲突则解决冲突。
如果am打不入，则在当前目录下新建git仓，并提交原始代码，再使用git apply --reject打入
```
git am -3 *.patch
git am --continue
```
# checkout remote branch
```
git checkout -f --track remotes/origin/amoled
```
# git local key changed
if ssh-key changes, using the flowing command to amend
```
ssh-keygen -t rsa -C zhangyi@xx.cn
ssh-add
```

# 去除Windows换行符
Windows的默认换行操作是回车键+换行符，Linux的默认换行操作是换行符。因此，Windows上修改的代码在提交时会多出一个^M字符。
Git提供了core.autocrlf来控制格式的自动转换。在Windows上checkout时可以自动将Linux格式切换为Windows格式，在checkin时，将格式切换回Linux格式。 
```
# git config –global core.autocrlf true
```

# 跟踪远程分支#

从远程分支 checkout 出来的本地分支，称为 跟踪分支 (tracking branch)。跟踪分支是一种和某个远程分支有直接联系的本地分支。在跟踪分支里输入 git push，Git 会自行推断应该向哪个服务器的哪个分支推送数据。同样，在这些分支里运行 git pull 会获取所有远程索引，并把它们的数据都合并到本地分支中来。

在克隆仓库时，Git 通常会自动创建一个名为 master 的分支来跟踪 origin/master。这正是 git push 和 git pull 一开始就能正常工作的原因。当然，你可以随心所欲地设定为其它跟踪分支，比如 origin 上除了 master 之外的其它分支。刚才我们已经看到了这样的一个例子：git checkout -b [分支名] [远程名]/[分支名]。如果你有 1.6.2 以上版本的 Git，还可以用 --track 选项简化：
```
$ git checkout --track origin/serverfix
Branch serverfix set up to track remote branch serverfix from origin.
Switched to a new branch 'serverfix'
```
要为本地分支设定不同于远程分支的名字，只需在第一个版本的命令里换个名字：
```
$ git checkout -b sf origin/serverfix
Branch sf set up to track remote branch serverfix from origin.
Switched to a new branch 'sf'
```
现在你的本地分支 sf 会自动将推送和抓取数据的位置定位到 origin/serverfix 了。
[ref](https://git-scm.com/book/zh/v1/Git-%E5%88%86%E6%94%AF-%E8%BF%9C%E7%A8%8B%E5%88%86%E6%94%AF)

# 查看提交信息 #
用id再看git show XXXX就可以看到那次提交的信息了

# 代理设置 #
```
 git config --global http.proxy 'http://xx:xx@xx.xx.com:8080'
```

# 版本操作苻 #
```
        tag^表示父版本、tag^^表示父版本的父版本, tag~4表示4代前的祖先
        master@{yesterday} 昨天的master版本
        master@{"1 week ago"} 一个星期前的版本
```

# 修改未commit的库操作 #
> git rm -r --cached .
> git commit --amend 修改最近一个commit

# 查看日志 #
> git log [v1..v2] [path](path.md)   一般查看
> git log -S'search'       查找修改内容，注意是源代码中的内容
> git log --pretty=oneline  这个好看一些

# Sign-off #
```
    developer>git format-patch master --stdout > my.patch
    signoff>git apply --stat my.patch
    signoff>git apply --check my.patch
    signoff>git am --signoff < my.patch
```

# merge #
直接解决冲突
```
git checkout --ours -- path/to/file.txt
git checkout --theirs -- path/to/file.txt
```
```
$ git merge --squash another
$ git commit -m "message here"
```
--squash选项的含义是：本地文件内容与不使用该选项的合并结果相同，但是不提交、不移动HEAD，因此需要一条额外的commit命令。其效果相当于将another分支上的多个commit合并成一个，放在当前分支上，原来的commit历史则没有拿过来。

merge时只使用本地的来解决冲突
```
grep -lr '<<<<<<<' . | xargs git checkout --ours
grep -lr '<<<<<<<' . | xargs git checkout --theirs
```
# ssh key
error:Agent admitted failure to sign using the key.
ssh-add 添加一下本地私钥
把私钥 chmod 600
# push
```
git push ssh://xxx@0.0.0.0:29418/platform/frameworks/webview HEAD:refs/for/xxx5.1_trunk
```
branch name `xxx5.1_trunk` get from `git branch -r`

##  切换到需要提交的分支
```
git checkout -b local_branch --track korg/remote_branch
git pull
```
