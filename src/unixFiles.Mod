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

  fileList* = POINTER TO ARRAY OF fileInfo;

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

PROCEDURE getAttr*(VAR fl: fileInfo; VAR st: Status);
VAR
  j: LONGINT;
BEGIN
    j := isDir(st.mode);
    IF j # 0 THEN fl.attr := fl.attr + {dir} END;
    j := isChar(st.mode);
    IF j # 0 THEN fl.attr := fl.attr + {char} END;
    j := isBlock(st.mode);
    IF j # 0 THEN fl.attr := fl.attr + {block} END;
    j := isReg(st.mode);
    IF j # 0 THEN fl.attr := fl.attr + {file} END;
    j := isFIFO(st.mode);
    IF j # 0 THEN fl.attr := fl.attr + {fifo} END;
    j := isLnk(st.mode);
    IF j # 0 THEN fl.attr := fl.attr + {symlink} END;
    j := isSock(st.mode);
    IF j # 0 THEN fl.attr := fl.attr + {socket} END;
END getAttr;

PROCEDURE Exists*(VAR fl : fileInfo): BOOLEAN;
VAR
  i, j : LONGINT;
  st: Status;
BEGIN
  fl.attr := {};
  i := stat(fl.name, st);
  IF i < 0 THEN RETURN FALSE  END;
  IF i = 0 THEN (* file exists*) 
    getAttr(fl, st);
    RETURN TRUE
  END;
END Exists;

PROCEDURE getFileList*(VAR path: ARRAY OF CHAR): fileList;
VAR
  d0: pdir;
  d1: pdirent;
  s: str;
  i, j : INTEGER;
  f: fileInfo;
  fl: fileList;
  k: LONGINT;
  st: Status;
BEGIN
  fl := NIL;
  (* first lets get quantity of files *)
  d0 := opendir(path);
  IF d0 # NIL THEN
    i := 0;
    REPEAT
      d1 := readdir(d0);
      IF d1 # NIL THEN
        INC(i);
      END
    UNTIL d1 = NIL;
  END;
  (* now allocate array and loop once more *)
  (* this will work properly in case suddenly more files won't appear in a directory *)
  (* otherwise it'll return only first i number of files *)
  (* TODO better way is to return a stringlist *)
  NEW(fl, i);

  d0 := opendir(path);
  IF d0 # NIL THEN
    j := 0;
    REPEAT
      d1 := readdir(d0);
      IF d1 # NIL THEN
        getDirentName(d1, s);
        COPY(s, f.name);
        f.attr := {};
        k := stat(f.name, st);
        IF k = 0 THEN
          getAttr(f, st); 
          fl[j] := f;
          INC(j);
        END;
      END
    UNTIL (j >= i) OR (d1 = NIL);
  END;
  RETURN fl;
END getFileList;


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
