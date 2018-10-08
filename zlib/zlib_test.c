/* Very simple smoke test for zlib.
 *
 * Copyright © 2018 Donald King
 * Licensed under the terms of the LICENSE file in this repository.
 */

#include <stdio.h>
#include <stdlib.h>
#include <zlib.h>

int main(int argc, char** argv) {
  const char* version = zlibVersion();
  fprintf(stdout, "zlib version: %s\n", version);
  return 0;
}
