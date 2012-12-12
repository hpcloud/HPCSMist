//see http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html

static inline BOOL IsEmpty(id thing) {
    return thing == nil
    || ([thing respondsToSelector:@selector(length)]
        && [(NSData *)thing length] == 0)
    || ([thing respondsToSelector:@selector(count)]
        && [(NSArray *)thing count] == 0);
}

static NSString *prettyBytes(uint64_t numBytes) {
  uint64_t const scale = 1024;
  char const *abbrevs[] = {"EB", "PB", "TB", "GB", "MB", "KB", "Bytes"};
  size_t numAbbrevs = sizeof(abbrevs) / sizeof(abbrevs[0]);
  uint64_t maximum = powl(scale, numAbbrevs - 1);
  for (size_t i = 0; i < numAbbrevs - 1; ++i) {
    if (numBytes > maximum) {
      return [NSString stringWithFormat:@"%.1f %s", numBytes / (double) maximum, abbrevs[i]];
    }
    maximum /= scale;
  }
  return [NSString stringWithFormat:@"%u Bytes", (unsigned) numBytes];
} ;