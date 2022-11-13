MODULE unixFiles;
IMPORT SYSTEM, Out;

CONST
  dir* = 0; char* = 1; block* = 2; file* = 3; fifo* = 4;
  symlink* = 5; socket* = 6;

TYPE
  str* = ARRAY 512 OF CHAR;
  pstr* = POINTER [1] TO ARRAY OF CHAR;

  fileInfo* = RECORD;
     name* : ARRAY 256 OF CHAR;
     attr- : SET
     END;

  Status* = RECORD (* struct stat *)
    dev* : HUGEINT; (* dev_t 8 *)
    ino* : HUGEINT; (* ino 8 *)
    nlink* : HUGEINT;
    mode* : LONGINT;
    uid*, gid*: LONGINT;
    pad0* : LONGINT;
    rdev* : HUGEINT;
    size* : HUGEINT;
    blksize* : HUGEINT;
    blocks* : HUGEINT;
    atime* : HUGEINT;
    atimences* : HUGEINT;
    mtime* : HUGEINT;
    mtimensec* : HUGEINT;
    ctime* : HUGEINT;
    ctimensec* : HUGEINT;
    unused0*, unused1*, unused2*: HUGEINT;
    END;

    pdir* = SYSTEM.PTR;
    pdirent* = SYSTEM.PTR;
 
(*
  pdirent* = POINTER [1] TO dirent;
  dirent* = RECORD
     ino : HUGEINT;
     off : HUGEINT;
  reclen : SYSTEM.BYTE;
    type : SYSTEM.BYTE;
    name : ARRAY 256 OF CHAR;
  END;
*)

PROCEDURE -Aincludestrings  '#include <string.h>';
PROCEDURE -Aincludesysstat  '#include <sys/stat.h>';
PROCEDURE -Aincludesystypes '#include <sys/types.h>';
PROCEDURE -Aincludedirent   '#include <dirent.h>';

PROCEDURE -opendir(path: ARRAY OF CHAR): pdir
"opendir(path)";

PROCEDURE openDir*(path: ARRAY OF CHAR): pdir;
BEGIN
  RETURN opendir(path)
END openDir;

PROCEDURE -readdir(d: pdir): pdirent
"readdir(d)";

PROCEDURE readDir*(d: pdir): pdirent;
BEGIN
  RETURN readdir(d)
END readDir;

(*PROCEDURE getDirentName*(VAR d: pdirent; VAR s: str);
BEGIN
  Out.String("entered getDirentName"); Out.Ln;
  COPY(d.name, s);
  Out.String("exiting getDirentName"); Out.Ln;
END getDirentName;
*)

PROCEDURE -getDirentName*(d: pdirent; s: str)
"strcpy(s, ((struct dirent* )d)->d_name)";

PROCEDURE -mkdir(VAR path: ARRAY OF CHAR): INTEGER
  "(int)mkdir(path, 0755)";

PROCEDURE mkDir*(VAR path: ARRAY OF CHAR): BOOLEAN;
VAR res: INTEGER;
BEGIN
   res := mkdir(path);
   IF res = 0 THEN RETURN TRUE ELSE RETURN FALSE END
END mkDir;

PROCEDURE -stat*(VAR path : ARRAY OF CHAR; st: Status): LONGINT
"stat((const char* )path, (struct stat* )&st)";

PROCEDURE -isDir(mode: LONGINT): INTEGER
"S_ISDIR(mode)";

PROCEDURE -isChar(mode: LONGINT): INTEGER
"S_ISCHR(mode)";

PROCEDURE -isBlock(mode: LONGINT): INTEGER
"S_ISBLK(mode)";

PROCEDURE -isReg(mode: LONGINT): INTEGER
"S_ISREG(mode)";

PROCEDURE -isFIFO(mode: LONGINT): INTEGER
"S_ISFIFO(mode)";

PROCEDURE -isLnk(mode: LONGINT): INTEGER
"S_ISLNK(mode)";

PROCEDURE -isSock(mode: LONGINT): INTEGER
"S_ISSOCK(mode)";

PROCEDURE -getStatusMode*(VAR st: Status; VAR m : LONGINT)
"memcpy(m, st.mode, 4)";

PROCEDURE Exists*(VAR fl : fileInfo): BOOLEAN;
VAR
  i : LONGINT;
  st: Status;
BEGIN
  fl.attr := {};
  i := stat(fl.name, st);
  IF i < 0 THEN RETURN FALSE  END;
  IF i = 0 THEN (* file exists*) 
    i := isDir(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {dir} END;
    i := isChar(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {char} END;
    i := isBlock(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {block} END;
    i := isReg(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {file} END;
    i := isFIFO(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {fifo} END;
    i := isLnk(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {symlink} END;
    i := isSock(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {socket} END;
    RETURN TRUE
  END;
END Exists;

PROCEDURE ExistsByName*(VAR fileName : ARRAY OF CHAR): BOOLEAN;
VAR
  i : LONGINT;
  st: Status;
  fl: fileInfo;
BEGIN
  fl.attr := {};
  COPY(fileName, fl.name);
  i := stat(fl.name, st);
  IF i < 0 THEN RETURN FALSE  END;
  IF i = 0 THEN (* file exists*) 
    i := isDir(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {dir} END;
    i := isChar(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {char} END;
    i := isBlock(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {block} END;
    i := isReg(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {file} END;
    i := isFIFO(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {fifo} END;
    i := isLnk(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {symlink} END;
    i := isSock(st.mode);
    IF i # 0 THEN fl.attr := fl.attr + {socket} END;
    RETURN TRUE
  END;
END ExistsByName;

END unixFiles.
