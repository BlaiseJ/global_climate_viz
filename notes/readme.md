# creating new directories on a cloud computer from r-studio Console

- list.files() will list files in your current directory
- dir.create("data") will create a directory called data/
- list.files(path="data") will read files found within the data/
- file.rename("readme.R", "data/readme.R") will move the file from current directory to data/
- file.copy("readme.R", "data/") will copy the file from current directory to data/ and still keep a copy in the current directory. so, we will need to delete it.
- file.remove("readme.R") will delete the file from current directory
- file.create("data/readme.R") will create new empty file in data/
- list.files(pattern="\\.R") will show all files ending in .R in the current directory
- then you can make a variable out of all these files and copy all at once e.g.

r.files <- list.files(pattern="\\.R")
files.copy(from=r.files, to="data")

- the downside to creating directories linked to github in this manner is that it breaks the history or timeline of directories and git thinks the files were deleted

# creating new directories from the r-studio terminal (command line)
- click on Terminal
- This will not recognize bash commands if you are on a Windows machine
- To configure it > Tools > Terminal > Terminal Options > New Terminals Open With Git Bash
- ls will list files in current directory
- mkdir data code figures will create new directories called data/ code/ and figures/
- ls -F will show detailed content differentiating files from directories
- git mv readme.R code/ will move readme.R file from current directory to code/
- git mv *.R data/ will move all .R files from current directory to data/
- touch data/readme.md will create an empty readme.md file in data/