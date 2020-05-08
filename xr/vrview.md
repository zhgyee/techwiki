# intro
vrview is a javascript video player for VR.

# vrview api seqs
## scene init
```
//main.js
var scene = SceneInfo.loadFromGetParams();
var worldRenderer = new WorldRenderer(scene);
function onLoad() {
  // Load the scene.
  worldRenderer.setScene(scene);

  requestAnimationFrame(loop);
}
//world-renderer.js
WorldRenderer.prototype.setScene = function(scene) {
      this.player = new AdaptivePlayer(params);
      this.player.on('load', function(videoElement, videoType) {
        self.sphereRenderer.set360Video(videoElement, videoType, params).then(function() {
          self.didLoad_({videoElement: videoElement});
        }).catch(self.didLoadFail_.bind(self));
      });
      this.player.load(scene.video);

      this.videoProxy = new VideoProxy(this.player.video);
}
//adaptive-player.js
function AdaptivePlayer(params) {
  this.video = document.createElement('video');

}
AdaptivePlayer.prototype.load = function(url) {
      this.type = Types.VIDEO;
      this.loadVideo_(url).then(function() {
        self.emit('load', self.video, self.type);
      }).catch(this.onError_.bind(this));
}
AdaptivePlayer.prototype.loadVideo_ = function(url) {
  var self = this, video = self.video;
  return new Promise(function(resolve, reject) {
    video.src = url;
    video.addEventListener('canplaythrough', resolve);
    video.addEventListener('loadedmetadata', function() {
      self.emit('timeupdate', {
        currentTime: video.currentTime,
        duration: video.duration
      });
    });
    video.addEventListener('error', reject);
    video.load();//最终调用h5 video element
  });
};
//video load ready, callback to world-renderer

      this.player.on('load', function(videoElement, videoType) {
        self.sphereRenderer.set360Video(videoElement, videoType, params).then(function() {
          self.didLoad_({videoElement: videoElement});
        }).catch(self.didLoadFail_.bind(self));
      });
WorldRenderer.prototype.didLoad_ = function(opt_event) {
  var event = opt_event || {};
  this.emit('load', event);
  if (this.sceneResolve) {
    this.sceneResolve();
  }
};
//main.js 回调通知main.js
worldRenderer.on('load', onRenderLoad);
function onRenderLoad(event) {
//准备就绪，如果是pc平台，则自动播放，如果是移动平台，点击后播放
}
```

## worldRender init
```
WorldRenderer.prototype.init_ = function(hideFullscreenButton) {
  var camera = new THREE.PerspectiveCamera(75, aspect, 0.1, 100);
  // Antialiasing disabled to improve performance.
  var renderer = new THREE.WebGLRenderer({antialias: false});
  renderer.setClearColor(0x000000, 0);
  renderer.setSize(window.innerWidth, window.innerHeight);
  renderer.setPixelRatio(window.devicePixelRatio);
  var controls = new THREE.VRControls(camera);
  var effect = new THREE.VREffect(renderer);    
```
## play seq
```
//index.js
playButton.addEventListener('click', onTogglePlay);
function onTogglePlay() {
  if (vrView.isPaused) {
    vrView.play();
    playButton.classList.remove('paused');
  } 
}
//player.js
Player.prototype.play = function() {
  this.sender.send({type: Message.PLAY});
};
// send message play to iframe
this.sender = new IFrameMessageSender(iframe);

//main.js
var receiver = new IFrameMessageReceiver();
receiver.on(Message.PLAY, onPlayRequest);
function onPlayRequest() {
  worldRenderer.videoProxy.play();
}
//video-proxy.js
VideoProxy.prototype.play = function() {
  if (Util.isIOS9OrLess()) {
  //
  } else {
    this.videoElement.play().then(function(e) {
      console.log('Playing video.', e);
    });
  }
};
```

## loop
```
//world-render.js
function loop(time) {
  // Use the VRDisplay RAF if it is present.
  if (worldRenderer.vrDisplay) {
    worldRenderer.vrDisplay.requestAnimationFrame(loop);
  } else {
    requestAnimationFrame(loop);
  }

  stats.begin();
  // Update the video if needed.
  if (worldRenderer.videoProxy) {
    worldRenderer.videoProxy.update(time);
  }
  worldRenderer.render(time);
  worldRenderer.submitFrame();
  stats.end();
}
WorldRenderer.prototype.render = function(time) {
  this.controls.update();
  TWEEN.update(time);
  this.effect.render(this.scene, this.camera);
  this.hotspotRenderer.update(this.camera);
};
WorldRenderer.prototype.submitFrame = function() {
  if (this.isVRMode()) {
    this.vrDisplay.submitFrame();
  }
};
```