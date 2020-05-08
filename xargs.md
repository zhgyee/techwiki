# Introduction #

-0
-I

# Details #

##  links ## 
http://sidvind.com/wiki/Xargs_by_example
##  examples ## 

### {} as the argument list marker ## #
find . -name "**.bak" -print0 | xargs -0 -I {} mv {} ~/old.files
find . -name "**.bak" -print0 | xargs -0 -I file mv file ~/old.files
