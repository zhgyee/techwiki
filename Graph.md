# 图优化
图优化是视觉slam中的主流优化方法，所谓的图优化是把常规的优化问题以图的形式来表述。

图(graph)由顶点(Vertex)和边(Edge)组成,在常见的slam问题中，机器人的位姿是一个顶点(Vertex)，
不同时刻位姿之间的关系构成边(Edge)，通过不断累积而成的顶点和边构成图(graph)结构，
图优化的目标就是通过调整顶点的位姿最大可能的满足边(Edge)之间的约束。
其中通过传感器累计信息构建图的过程在slam中称为前端，调整位姿满足约束的优化过程成为后端。

[参考](https://blog.csdn.net/datase/article/details/78473804)

[gaoxiang](https://www.cnblogs.com/gaoxiang12/p/5244828.html)