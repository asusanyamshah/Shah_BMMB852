# Week 1
## Set up your system and demonstrate basic UNIX command line actions

### Code Editor
```Visual Studio Code```

### Version of Samtools in Bioinfo environment Command 
```
bioinfo
samtools --version
```

### Answer 
```1.24```

### Output
```
samtools 1.24
Using htslib 1.24
Copyright (C) 2026 Genome Research Ltd.

Samtools compilation details:
    Features:       build=configure curses=yes 
    CC:             arm64-apple-darwin20.0.0-clang -std=gnu23
    CPPFLAGS:       -D_FORTIFY_SOURCE=2 -isystem /Users/sanyamshah/edu/bioinfo/.pixi/envs/default/include -mmacosx-version-min=11.3 -mmacosx-version-min=11.0
    CFLAGS:         -Wall -ftree-vectorize -fPIC -fstack-protector-strong -O2 -pipe -isystem /Users/sanyamshah/edu/bioinfo/.pixi/envs/default/include -fdebug-prefix-map=/opt/mambaforge/envs/bioconda/conda-bld/samtools_1784061835497/work=/usr/local/src/conda/samtools-1.24 -fdebug-prefix-map=/Users/sanyamshah/edu/bioinfo/.pixi/envs/default=/usr/local/src/conda-prefix
    LDFLAGS:        -Wl,-headerpad_max_install_names -Wl,-dead_strip_dylibs -Wl,-rpath,/Users/sanyamshah/edu/bioinfo/.pixi/envs/default/lib -L/Users/sanyamshah/edu/bioinfo/.pixi/envs/default/lib
    HTSDIR:         
    LIBS:           
    CURSES_LIB:     -ltinfow -lncursesw

HTSlib compilation details:
    Features:       build=configure libcurl=yes S3=yes GCS=yes libdeflate=yes lzma=yes bzip2=yes plugins=yes plugin-path=/Users/sanyamshah/edu/bioinfo/.pixi/envs/default/libexec/htslib htscodecs=1.6.7
    CC:             arm64-apple-darwin20.0.0-clang -std=gnu23
    CPPFLAGS:       -D_FORTIFY_SOURCE=2 -isystem /Users/sanyamshah/edu/bioinfo/.pixi/envs/default/include -mmacosx-version-min=11.3 -mmacosx-version-min=11.0
    CFLAGS:         -Wall -ftree-vectorize -fPIC -fstack-protector-strong -O2 -pipe -isystem /Users/sanyamshah/edu/bioinfo/.pixi/envs/default/include -fdebug-prefix-map=/opt/mambaforge/envs/bioconda/conda-bld/htslib_1783611483345/work=/usr/local/src/conda/htslib-1.24 -fdebug-prefix-map=/Users/sanyamshah/edu/bioinfo/.pixi/envs/default=/usr/local/src/conda-prefix -fvisibility=hidden
    LDFLAGS:        -Wl,-headerpad_max_install_names -Wl,-dead_strip_dylibs -Wl,-rpath,/Users/sanyamshah/edu/bioinfo/.pixi/envs/default/lib -L/Users/sanyamshah/edu/bioinfo/.pixi/envs/default/lib -fvisibility=hidden -rdynamic

HTSlib URL scheme handlers present:
    built-in:	 file, preload, data
    Google Cloud Storage:	 gs+http, gs+https, gs
    libcurl:	 gophers, smtp, wss, rtsp, tftp, mqtts, pop3, imaps, pop3s, ws, ftps, ftp, gopher, imap, http, https, sftp, smtps, scp, dict, mqtt, telnet
    Amazon S3:	 s3+https, s3, s3+http
    crypt4gh-needed:	 crypt4gh
    mem:	 mem
(bioinfo) 
```

<hr>

### Commands needed to create a nested directory structure
```
mkdir -pv week1/dir1/dir2/dir3
```

### Output

```
week1/dir1
week1/dir1/dir2
week1/dir1/dir2/dir3
```

<hr>

### Commands that create files in different directories
```
touch week1/dir1/file1.txt week1/dir1/dir2/file2.txt week1/dir1/dir2/dir3/file3.txt
```
### Output

No output since touch executes the command silently. 

<hr>

### Show how to access these files using relative and absolute paths.

#### Relative Paths
```
cat ./week1/dir1/file1.txt
cat ./week1/dir1/dir2/file2.txt
cat ./week1/dir1/dir2/dir3/file3.txt
```

### Output
No output since the txt files are empty

#### Absolute Paths
```
cat ~/Shah_BMMB852/week1/dir1/file1.txt
cat ~/Shah_BMMB852/week1/dir1/dir2/file2.txt
cat ~/Shah_BMMB852/week1/dir1/dir2/dir3/file3.txt
```
### Output
No output since the txt files are empty
