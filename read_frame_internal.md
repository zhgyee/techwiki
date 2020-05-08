# Introduction #

av\_read\_frame\_internal 在ffmpeg中实现了将format格式的packet,最终转换成一帧帧的es流packet，并解析填充了packet的pts,dts，等信息，为最终解码提供了重要的数据,av\_read\_frame\_internal,调用av\_read\_packet,每次只读取一个包，然后直到parser完这个包的所有数据，才开始读取下一个包，parser完的数据被保存在parser结构的数据缓冲中，这样即使av\_read\_packet读取的下一包和前一包的流不一样，由于parser也不一样，所以实现了av\_read\_frame\_internal这个函数调用，可以解析出不同流的es流,而av\_read\_frame\_internal函数除非出错否则必须解析出一帧数据才能返回

# 流程 #
  1. 通过[ff\_read\_packet](ff_read_packet.md)读包
  1. 如果需要parse,则通过[parse\_packet](parse_packet.md)解析读到的包
  1. 通过[compute\_pkt\_fields](compute_pkt_fields.md)计算packet信息
  1. 如果当前流设置了AVDISCARD\_ALL，则直接[av\_free\_packet](av_free_packet.md)
  1. 如果需要skip\_to\_keyframe，则判断packet是否是key frame，如果不是，调用[av\_free\_packet](av_free_packet.md)
> > 注： 这个目前只看到在mkv中使用，但这种机制值得借鉴，解决seek后读到关键帧的问题

# 何时读包返回 #
  1. EOF时，要保证all remain data parsed
  1. 不需要解析时，no parsing needed: we just output the packet as is
  1. 正常读到数据，从[parse\_packet](parse_packet.md)直接返回