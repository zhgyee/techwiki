# tcp ftrace

The existing net/netif_rx and net/netif_receive_skb trace events
provide little information about the skb, nor do they indicate how it
entered the stack.

Add trace events at entry of each of the exported functions, including
most fields that are likely to be interesting for debugging driver
datapath behaviour.  Split netif_rx() and netif_receive_skb() so that
internal calls are not traced.


# ref
[linuxconjapan-ftrace-2014](http://events.linuxfoundation.org/sites/events/files/slides/linuxconjapan-ftrace-2014.pdf)

[kernel doc](https://www.kernel.org/doc/Documentation/trace/events.txt)

[Android Debugging and Performance]()