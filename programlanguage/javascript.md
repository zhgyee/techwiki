# Node.js

# npm

```
npm install //本地安装模块到node_modules目录
sudo npm install -g derequire //安装到globe module
sudo npm install npm -g //升级npm
npm run //列出支持的脚本

npm run build //招待build脚本
```
# package.json
* 定义npm脚本
* 定义dependency
* devDependencies

# browserify
```
sudo npm install -g browserify
```

# Node.js EventEmitter
## 继承 EventEmitter
大多数时候我们不会直接使用 EventEmitter，而是在对象中继承它。包括 fs、net、 http 在内的，只要是支持事件响应的核心模块都是 EventEmitter 的子类。
为什么要这样做呢？原因有两点：
首先，具有某个实体功能的对象实现事件符合语义， 事件的监听和发射应该是一个对象的方法。
其次 JavaScript 的对象机制是基于原型的，支持 部分多重继承，继承 EventEmitter 不会打乱对象原有的继承关系。
```
//worldRender通过load事件回调main.js中onRendererLoad方法
//WorldRenderer.js
WorldRenderer.prototype = new EventEmitter();
WorldRenderer.prototype.didLoad_ = function(opt_event) {
  var event = opt_event || {};
  this.emit('load', event);
  if (this.sceneResolve) {
    this.sceneResolve();
  }
};
//main.js
var worldRenderer = new WorldRenderer(scene);
worldRenderer.on('load', onRenderLoad);

```

# Promise
所谓Promise，字面上可以理解为“承诺”，就是说A调用B，B返回一个“承诺”给A，然后A就可以在写计划的时候这么写：当B返回结果给我的时候，A执行方案S1，反之如果B因为什么原因没有给到A想要的结果，那么A执行应急方案S2，这样一来，所有的潜在风险都在A的可控范围之内了。

Promise规范如下：

* 一个promise可能有三种状态：等待（pending）、已完成（fulfilled）、已拒绝（rejected）
* 一个promise的状态只可能从“等待”转到“完成”态或者“拒绝”态，不能逆向转换，同时“完成”态和“拒绝”态不能相互转换
* promise必须实现then方法（可以说，then就是promise的核心），而且then必须返回一个promise，同一个promise的then可以调用多次，并且回调的执行顺序跟它们被定义时的顺序一致
* then方法接受两个参数，第一个参数是成功时的回调，在promise由“等待”态转换到“完成”态时调用，另一个是失败时的回调，在promise由“等待”态转换到“拒绝”态时调用。同时，then可以接受另一个promise传入，也接受一个“类then”的对象或方法，即thenable对象。

这段代码很简单，就是等待5秒以后执行一个回调，弹出一个消息
```
function wait(duration){
    return new Promise(function(resolve, reject) {
        setTimeout(resolve,duration);
    })
}
wait(5000).then(function(){alert('hello')}).then(function(){console.log('world')})
```