# 分块压缩
```
7z -v100m a my_zip.7z my_folder/
```
Use the -v option (v is for volume) -v100m will split the archive into chunks of 100MB.

7z -v option supports b k m g (bytes, kilobytes, megabytes, gigabytes)

# 解压
```
7z e asdf.iso.0
7z x a.iso.001 -tudf.split -o output_dir
```
