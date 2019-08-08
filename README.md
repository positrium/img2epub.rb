# img2epub.rb

create epub document from jpeg files.

## how to use

```
YOUR_JPG_DIRECTORY_NAME/
├── 1.jpg
├── 2.jpg
├── 3.jpg
├── 4.jpg
└── cover.jpg
```

### usage

```
$ bundle exec img2epub.rb YOUR_JPG_DIRECTORY_NAME

> document name:
    YOUR_JPG_DIRECTORY_NAME.epub

> document title:
    YOUR_JPG_DIRECTORY_NAME

> document direction:
    right to left

> document cover-image:
    1.jpg

> document content:
    2.xhtml(2.jpg)
    3.xhtml(3.jpg)
    4.xhtml(4.jpg)
    cover.xhtml(cover.jpg)

converted.
```

### (TODO) editing YAML

document.yml

```
name: myEpub.epub
title: MY_EPUB
direction: ltr
cover-image: cover.jpg
```

- name: epub file name.
- title: view book title when open epub.
- direction: page turning direction. [ltr|rtl]
- cover-image: cover image on epub reader.

```
$ bundle exec img2epub.rb YOUR_JPG_DIRECTORY_NAME

> document name:
    myEpub.epub

> document title:
    MY_EPUB

> document direction:
    left to right

> document cover-image:
    cover.jpg

> document content:
    1.xhtml(1.jpg)
    2.xhtml(2.jpg)
    3.xhtml(3.jpg)
    4.xhtml(4.jpg)

converted.
```
