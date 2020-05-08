# Introduction #

Add your content here.


# Details #

If you ever need to download an entire Web site, perhaps for off-line viewing, wget can do the
job—for example:
```
$ wget \
     --recursive \
     --no-clobber \
     --page-requisites \
     --html-extension \
     --convert-links \
     --restrict-file-names=windows \
     --domains website.org \
     --no-parent \
         www.website.org/tutorials/html/
```
This command downloads the Web site www.website.org/tutorials/html/.

The options are:
```
--recursive: download the entire Web site.

--domains website.org: don't follow links outside website.org.

--no-parent: don't follow links outside the directory tutorials/html/.

--page-requisites: get all the elements that compose the page (images, CSS and so on).

--html-extension: save files with the .html extension.

--convert-links: convert links so that they work locally, off-line.

--restrict-file-names=windows: modify filenames so that they will work in Windows as well.

--no-clobber: don't overwrite any existing files (used in case the download is interrupted and resumed).
```
# multithread download tools
* [axel](axel.md)