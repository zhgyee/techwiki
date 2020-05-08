# Introduction #

Add your content here.


# Details #

##  同步事件 ## 
通过调用者查询来获得事件，如libbluray和SDL的事件机制：
```
blurayHandleEvents(p_demux);
nread = bd_read(p_sys->bluray, p_block->p_buffer,
                        NB_TS_PACKETS * BD_TS_PACKET_SIZE);
```
```
static void blurayHandleEvents( demux_t *p_demux )
{
    BD_EVENT e;

    while (bd_get_event(p_demux->p_sys->bluray, &e))
    {
        blurayHandleEvent(p_demux, &e);
    }
}
```
##  异步事件 ## 
当消息源产生消息时，消息源主动通知接收者，一般消息源和接收者在不同的线程中


Add your content here.  Format your content with:
  * Text in **bold** or _italic_
  * Headings, paragraphs, and lists
  * Automatic links to other wiki pages