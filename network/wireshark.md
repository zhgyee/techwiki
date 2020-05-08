# 分析rtp包
telephony->rtp->stream analysis
# 分析tcp包
## 分析tcp传输速度
statics->I/O graph
选择Y轴以bps为单位
## 分析tcp window size变化
statics->tcp stream graph->window scaling
## 分析tcp streaming 时间特性
statics->tcp stream graph->time sequence
如果时间序列出现断裂带，则说明相应的tcp package的时间间隔比较大，可能出现长时间重传或block
点击图表相应地方会跳转到相关package上。
## 分析tcp交互流程
statics->Flow graph,版本最好为1.6.7，新版本出现crash问题
```
|787.064  |         ACK - Len: 1388               |Seq = 267062 Ack = 1567
|         |(50618)  <------------------  (80)     |
|787.076  |         ACK - Len: 1388               |Seq = 268450 Ack = 1567
|         |(50618)  <------------------  (80)     |
|787.081  |         FIN, PSH, ACK - Len: 1388     |Seq = 269838 Ack = 1567
|         |(50618)  <------------------  (80)     |
|787.081  |         ACK       |                   |Seq = 1567 Ack = 271227
|         |(50618)  ------------------>  (80)     |
|787.086  |         FIN, ACK  |                   |Seq = 1567 Ack = 271227
|         |(50618)  ------------------>  (80)     |
|787.220  |         ACK       |                   |Seq = 271227 Ack = 1568
|         |(50618)  <------------------  (80)     |

```
[ref](http://blog.csdn.net/a19881029/article/details/38091243)
