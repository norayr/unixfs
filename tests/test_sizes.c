#include <stdio.h>
// for dirent, di_ino, etc
#include <dirent.h>
// for libc_lock_define
//#include <sys/types.h>
//#include <bits/libc-lock.h>

// for DIR, opendir
#include <sys/types.h>

int main()
{
  struct dirent *dir;
  printf ("size of dirent: %ld\n", sizeof(*dir));
  printf ("size of d_ino: %ld\n", sizeof(dir->d_ino));
  printf ("size of d_off: %ld\n", sizeof(dir->d_off));
  printf ("size of d_reclen: %ld\n", sizeof(dir->d_reclen));
  printf ("size of d_type: %ld\n", sizeof(dir->d_type));
  printf ("size of d_name: %ld\n", sizeof(dir->d_name));
  printf ("size of int: %ld\n", sizeof(int));
  DIR * d;
  DIR   d0;
  printf ("size of d: %ld\n", sizeof(d));
  printf ("size of *d: %ld\n", sizeof(d0));
//  printf ("size of libc_lock_define: %ld\n", sizeof( __libc_lock_define));
  return 0;

}
