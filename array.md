# Introduction #

Add your content here.


# Details #

# ffmpeg动态数组实现 #
不需要记录分配大小，直接计算获取。if ((nb & (nb - 1)) == 0) {
...
tab = av_realloc(tab, nb_alloc * sizeof(intptr_t));
...
}
}}```