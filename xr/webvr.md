# chrome support
在chrome://flags中打开vr支持
# webvr API emulator
https://github.com/spite/WebVR-Extension

在chrome extension中安装该扩展后，在inspector中找到webvr标签，可以控制pos和rotation

# ComplementaryFilter
filter_1 = K * (filter_0 + gyro * dT) + (1 - K) * accel.
```
//implenment with quat
gyroQ = filterQ0 * gyroDeltaQ;
acclQ = filterQ0 * gravityDeltaQ;
filterQ1 = gyroQ.slerp(acclQ, 1-k)

// create gyro totate quat from axis and angle
gyroDeltaQ = quat.setFromAxisAngle(gyro.normal(), gyro.length() * dt);

// Calculate the delta between the current estimated gravity and the real
// gravity vector from accelerometer.
var invFilterQ = new MathUtil.Quaternion();
invFilterQ.copy(this.filterQ);
invFilterQ.inverse();

this.estimatedGravity.set(0, 0, -1);
this.estimatedGravity.applyQuaternion(invFilterQ);
this.estimatedGravity.normalize();

this.measuredGravity.copy(this.currentAccelMeasurement.sample);
this.measuredGravity.normalize();
// Compare estimated gravity with measured gravity, get the delta quaternion
// between the two.
var deltaQ = new MathUtil.Quaternion();
deltaQ.setFromUnitVectors(this.estimatedGravity, this.measuredGravity);
deltaQ.inverse();
gravityDeltaQ = deltaQ;
```

# PosePredictor
```
  // Get the predicted angle based on the time delta and latency.
  var deltaT = timestampS - this.previousTimestampS;
  var predictAngle = angularSpeed * this.predictionTimeS;

  this.deltaQ.setFromAxisAngle(axis, predictAngle);
  this.outQ.copy(this.previousQ);
  this.outQ.multiply(this.deltaQ);

  this.previousQ.copy(currentQ);
  this.previousTimestampS = timestampS;
```
# distortion

# [vrview](vrview.md)

# reference
[webvr.info](https://webvr.info/samples/)
[google vrview](https://github.com/googlevr/vrview)
[chrome webvr sample](https://github.com/GoogleChrome/samples/tree/gh-pages/web-vr/hello-world)
