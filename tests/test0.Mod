MODULE test0;
IMPORT unixFiles, Out, SYSTEM;

PROCEDURE -Aincludestrings  '#include <string.h>';
PROCEDURE -Aincludedirent   '#include <dirent.h>';

(*
PROCEDURE test01;
VAR
  mode : LONGINT;
     i : LONGINT;
    st : unixFiles.Status;
    fn : ARRAY 256 OF CHAR;
BEGIN
  COPY("/etc/passwd", fn);
  i := unixFiles.stat(fn, st);
  Out.String("st.mode is "); Out.Int(st.mode, 0); Out.Ln;
  unixFiles.getStatusMode(st, mode);
  Out.String("st.mode is also "); Out.Int(mode, 0); Out.Ln;
  Out.Ln;
END test01;
*)
PROCEDURE test02;
VAR
  d0: unixFiles.pdir;
  d1: unixFiles.pdirent;
  s: unixFiles.str;
BEGIN
  (*NEW(d0);*)
  (*NEW(d1);*)
  Out.String("test02"); Out.Ln;
  d0 := unixFiles.openDir(".");
  IF d0 # NIL THEN
    REPEAT
      d1 := unixFiles.readDir(d0);
      IF d1 # NIL THEN
        unixFiles.getDirentName(d1, s);
        Out.String(s); Out.Ln
      END
    UNTIL d1 = NIL;
  END;

(*
  d0 := unixFiles.opendir("/home/tmp");
  IF d0 = 0 THEN
    Out.String("d0 is NIL"); Out.Ln
  ELSE
    Out.String("d0 is not NIL"); Out.Ln;
    REPEAT 
      NEW(d1);
      d1 := unixFiles.readdir(d0);
    IF d1 # NIL THEN
        Out.String("d1 is not NIL"); Out.Ln;
        unixFiles.getDirentName(d1, s);
        Out.String(s); Out.Ln
      ELSE
        Out.String("d1 is NIL"); Out.Ln
      END
    UNTIL d1 = NIL;
  END;
*)  
END test02;

BEGIN
  (*test01;*)
  test02
END test0.
