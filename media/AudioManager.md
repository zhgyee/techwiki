# AudioManage useages 
##  headset 
```
    // Set audio mode to communication
    AudioManager audioManager =
        ((AudioManager) context.getSystemService(Context.AUDIO_SERVICE));
    audioManager.setMode(AudioManager.MODE_IN_COMMUNICATION);
    // Listen to headset being plugged in/out.
    IntentFilter receiverFilter = new IntentFilter(Intent.ACTION_HEADSET_PLUG);
    headsetListener = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
          if (intent.getAction().compareTo(Intent.ACTION_HEADSET_PLUG) == 0) {
            headsetPluggedIn = intent.getIntExtra("state", 0) == 1;
            updateAudioOutput();
          }
        }
      };
    context.registerReceiver(headsetListener, receiverFilter);
```
