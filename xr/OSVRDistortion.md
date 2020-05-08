# overfill
放大视口，多绘制一部分，供timewarp扭曲用
```
  double overFill = renderManagerConfig->getRenderOverfillFactor();
  double width = renderInfo.viewport.width;
  double height = renderInfo.viewport.height;
  double overWidth = width * overFill;
  double overHeight = height * overFill;
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrtho(-overWidth / 2, overWidth / 2,
    -overHeight / 2, overHeight / 2,
    -1000, 1000);
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();
```