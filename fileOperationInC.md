# Introduction #

Add your content here.


# Details #

# Remove file under dir #

```
#include <stdio.h>
#include <dirent.h>

int main()
{
    // These are data types defined in the "dirent" header
    struct dirent *next_file;
    DIR *theFolder;

    char filepath[256];

    theFolder = opendir("path/of/folder");

    while ( next_file = readdir(theFolder) )
    {
        // build the full path for each file in the folder
        sprintf(filepath, "%s/%s", "path/of/folder", next_file->d_name);
        remove(filepath);
    }
    return 0;
}
```