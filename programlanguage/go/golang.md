# 语法
* 大写表示为对外可见的方法或符号，类似于public
* main()为入口
* init()为包初始化函数

## struct
```
StructType    = "struct" "{" { FieldDecl ";" } "}" .
FieldDecl     = (IdentifierList Type | EmbeddedField) [ Tag ] .
EmbeddedField = [ "*" ] TypeName .
Tag           = string_lit .
```

### enbeded fields
A field declared with a type but no explicit field name is called an embedded field. 
An embedded field must be specified as a type name T or as a pointer to a non-interface type name *T, 
and T itself may not be a pointer type. The unqualified type name acts as the field name.
```
// A struct with four embedded fields of types T1, *T2, P.T3 and *P.T4
struct {
	T1        // field name is T1
	*T2       // field name is T2
	P.T3      // field name is T3
	*P.T4     // field name is T4
	x, y int  // field names are x and y
}
```
Selectors 
```
type T0 struct {
	x int
}

func (*T0) M0()

type T1 struct {
	y int
}

func (T1) M1()

type T2 struct {
	z int
	T1
	*T0
}

func (*T2) M2()

type Q *T2

var t T2     // with t.T0 != nil
var p *T2    // with p != nil and (*p).T0 != nil
var q Q = p
```
```
t.z          // t.z
t.y          // t.T1.y
t.x          // (*t.T0).x

p.z          // (*p).z
p.y          // (*p).T1.y
p.x          // (*(*p).T0).x

q.x          // (*(*q).T0).x        (*q).x is a valid field selector

p.M0()       // ((*p).T0).M0()      M0 expects *T0 receiver
p.M1()       // ((*p).T1).M1()      M1 expects T1 receiver
p.M2()       // p.M2()              M2 expects *T2 receiver
t.M2()       // (&t).M2()           M2 expects *T2 receiver, see section on Calls
```
## Goroutines
```
go f(x, y, z) //Goroutines
```
## Channels
```
ch := make(chan int)
ch <- v    // Send v to channel ch.
v := <-ch  // Receive from ch, and
           // assign value to v.
x, y := <-c, <-c // receive from c 
```
# 环境搭建
```
$ export GOPATH=~/go # optional, adjust as necessary
export PATH=$PATH:$GOPATH/bin
$ go get github.com/grisha/gowebapp
//dep is a dependency management tool for Go. 如果没有安装dep，运行下面命令进行安装
curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh
//或安装源码
go get -u github.com/golang/dep/cmd/dep
//安装依赖
dep ensure
//编译成二进制
go build
//或脚本运行
go run main.go
```
# 依赖管理
```
dep version
dep init
dep ensure -add github.com/gorilla/mux
```
# 构建
* Go命令行工具直接舍弃的工程文件的概念，只通过目录结构和包的名字来推倒工程结构和构建顺序。
* **xx_test.go表示是对xx.go的单元测试文件**，这是Go工程的命名规则。同时，工程下的目录src表示是源码目录，bin表示安装后的可执行程序目录，pkg表示包目录，这也是Go工程的命名规则。
* 完成代码后，就要进行编译了。首先需要设置环境变量**GOPATH**的值，将**calcuator的目录赋给GOPATH**,保存后重新载入即可。假设calcuator的目录是"~/gobuild",那么在linux下可以执行以下命令：
```
export GOPATH=~/gobuild/calcuator
source ~/.bashrc
```
设置完环境变量后，就可以开始构建工程了，进入calcuator的目录，执行命令：
```
cd bin
go build calc
```
* 而同样，进行单元测试，在bin目录下执行命令：`go test simplemath`即可。

详细参考http://www.cnblogs.com/yetuweiba/p/4353264.html

# 参考
* [The Go Programming Language Specification](https://golang.org/ref/spec)
* [a tour of go](https://tour.golang.org/)
* [go web](https://astaxie.gitbooks.io/)
* [go语言资料整理](https://zhuanlan.zhihu.com/p/25493806)
