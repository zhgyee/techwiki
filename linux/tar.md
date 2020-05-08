# Introduction #

Add your content here.


# Details #
```
encrypt:

tar -cj directory | openssl des3 -salt > encrypted.tarfile

decrypt:

cat encrypted.tarfile | openssl des3 -d -salt |tar -xvj

```