# Introduction #

Add your content here.


# 流程 #

  1. 调用[av\_parser\_parse2](av_parser_parse2.md)解析包，直到out\_pkt有数据
  1. out\_pkt有数据后，设置
    1. pts
    1. dts
    1. pos
    1. key flag等信息
  1. 将解析后的包通过[add\_to\_pktbuf](add_to_pktbuf.md)增加到parse\_queue中

# EOF后，如何读取parse中的数据 #
通过调用[parse\_packet](parse_packet.md)来刷新队列：
```
 parse_packet(s, NULL, st->index);
```