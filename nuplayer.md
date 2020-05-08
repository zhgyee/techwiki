# Introduction #

Add your content here.


# Details #

# FLAG\_DYNAMIC\_DURATION #
  * schedulePollDuration
    * mSource->getDuration(&durationUs)
    * driver->notifyDuration(durationUs);
    * msg->post(1000000ll);  // poll again in a second.

# discontinuty #
  1. 在livesession中发现音视频字幕改变，向上发出消息
```
LiveSession::onChangeConfiguration2
 notify->setInt32("what", kWhatStreamsChanged);
```
  1. http live source接收到消息，并转化为decoder shutdown消息，转发到上一层nuplayer中
```
NuPlayer::HTTPLiveSource::onSessionNotify()
 notify->setInt32("what", kWhatQueueDecoderShutdown);
```
  1. nuplayer处理消息,关闭解码器
```
NuPlayer::onMessageReceived()
 queueDecoderShutdown(audio, video, reply);

    mDeferredActions.push_back(
            new ShutdownDecoderAction(audio, video));

    mDeferredActions.push_back(
            new SimpleAction(&NuPlayer::performScanSources));

    mDeferredActions.push_back(new PostMessageAction(reply));
```
  1. performScanSources发起扫描source的消息kWhatScanSources，重新打开解码器和window
```
            if (mNativeWindow != NULL) {
                instantiateDecoder(false, &mVideoDecoder);
            }

            if (mAudioSink != NULL) {
                instantiateDecoder(true, &mAudioDecoder);
            }
```

prepare流程
  1. HTTPLiveSource先创建session，再调用session的connectAsync
```
    sp<AMessage> notify = new AMessage(kWhatSessionNotify, id());

    mLiveSession = new LiveSession(
            notify,
            (mFlags & kFlagIncognito) ? LiveSession::kFlagIncognito : 0,
            mUIDValid,
            mUID);
    mLiveSession->connectAsync(
            mURL.c_str(), mExtraHeaders.isEmpty() ? NULL : &mExtraHeaders);
```
  1. 在LiveSession中处理kWhatConnect消息
```
 	      case kWhatConnect:
        {
            onConnect(msg);
            break;
        }
```
> 在onConnect中获取播放列表解析器M3UParser
```
		mPlaylist = fetchPlaylist(url.c_str(), NULL /* curPlaylistHash */, &dummy);
		    changeConfiguration(
	          0ll /* timeUs */, initialBandwidthIndex, true /* pickTrack */);
```
  1. changeConfiguration系列函数开始建立实际的流
> > 视频、音频和字幕数据统一从livesession中读出，在livesession构造之初，就分别创建三路packet source
```
  	mPacketSources.add(
            STREAMTYPE_AUDIO, new AnotherPacketSource(NULL /* meta */));

    mPacketSources.add(
            STREAMTYPE_VIDEO, new AnotherPacketSource(NULL /* meta */));

    mPacketSources.add(
            STREAMTYPE_SUBTITLES, new AnotherPacketSource(NULL /* meta */));
```
> > AnotherPacketSource的初始化在之前的changeConfiguration中获取audio/video/sub的URL
```
    AString audioURI;
    if (mPlaylist->getAudioURI(item.mPlaylistIndex, &audioURI)) {
        streamMask |= STREAMTYPE_AUDIO;
    }

    AString videoURI;
    if (mPlaylist->getVideoURI(item.mPlaylistIndex, &videoURI)) {
        streamMask |= STREAMTYPE_VIDEO;
    }

    AString subtitleURI;
    if (mPlaylist->getSubtitleURI(item.mPlaylistIndex, &subtitleURI)) {
        streamMask |= STREAMTYPE_SUBTITLES;
    }
    ...
    sp<AMessage> msg = new AMessage(kWhatChangeConfiguration2, id());
    msg->setInt32("streamMask", streamMask);
    msg->setInt64("timeUs", timeUs);
    if (streamMask & STREAMTYPE_AUDIO) {
        msg->setString("audioURI", audioURI.c_str());
    }
    if (streamMask & STREAMTYPE_VIDEO) {
        msg->setString("videoURI", videoURI.c_str());
    }
    if (streamMask & STREAMTYPE_SUBTITLES) {
        msg->setString("subtitleURI", subtitleURI.c_str());
    }
```
  1. onChangeConfiguration2中标记改变的stream,进入onChangeConfiguration3，最终调用fetcher::startSync函数
```
    sp<PlaylistFetcher> fetcher = addFetcher(uri.c_str());
    mFetcherInfos.valueAt(i).mFetcher->startAsync(
          audioSource, videoSource, subtitleSource);
```

> 在addFetcher中将url和fetcherinfo关联起来
```
    FetcherInfo info;
    info.mFetcher = new PlaylistFetcher(notify, this, uri);
    info.mDurationUs = -1ll;
    info.mIsPrepared = false;
    looper()->registerHandler(info.mFetcher);

    mFetcherInfos.add(uri, info);
```
  1. PlaylistFetcher处理kWhatStart消息
