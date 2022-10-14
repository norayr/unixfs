#include <stdio.h>
#include <dirent.h>

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
  return 0;

}
