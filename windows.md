# Introduction #

Add your content here.


# Details #

# 乱图标处理过程 #
```
:IconCacheOperation
attrib %HOMEPATH%\AppData\Local\IconCache.db -H -R
::DEL /F %HOMEPATH%\AppData\Local\IconCache.db
echo.> %HOMEPATH%\AppData\Local\IconCache.db
attrib %HOMEPATH%\AppData\Local\IconCache.db +H +R

taskkill /F /IM explorer.exe
start explorer.exe

:Finish
@echo "配置完成"
PAUSE
```