//
//  Enviroment.h
//  HPCSMist
//
//  Created by Mike Hagedorn on 3/12/12.
//  © Copyright 2013 Hewlett-Packard Development Company, L.P.

//  Permission is hereby granted, free of charge, to any person obtaining
//  a copy of this software and associated documentation files (the
//  "Software"), to deal in the Software without restriction, including
//  without limitation the rights to use, copy, modify, merge, publish,
//  distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to
//  the following conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//


//see http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html


static inline BOOL IsEmpty(id thing)
{
    if (thing == nil){
        return YES;
    }else if ([thing respondsToSelector:@selector(length)]){
        return [(NSData *) thing length] == 0;
    }else if ([thing respondsToSelector:@selector(length)]){
        return [(NSArray *) thing count] == 0;
    }
    return NO;
}


static NSString *prettyBytes(uint64_t numBytes)
{
  uint64_t const scale = 1024;
  char const *abbrevs[] = {"EB", "PB", "TB", "GB", "MB", "KB", "Bytes"};
  size_t numAbbrevs = sizeof(abbrevs) / sizeof(abbrevs[0]);
  uint64_t maximum = powl(scale, numAbbrevs - 1);
  for (size_t i = 0; i < numAbbrevs - 1; ++i)
  {
    if (numBytes > maximum)
    {
      return [NSString stringWithFormat:@"%.1f %s", numBytes / (double)maximum, abbrevs[i]];
    }

    maximum /= scale;
  }

  return [NSString stringWithFormat:@"%u Bytes", (unsigned)numBytes];
}
