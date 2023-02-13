#!/usr/bin/env python3

#    Small hackish script to convert an U-Boot memdump to a binary image
#
#    Copyright (C) 2015  Simon Baatz
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License along
#    with this program; if not, write to the Free Software Foundation, Inc.,
#    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

import sys
import io

BYTES_IN_LINE = 0x10 # Number of bytes to expect in each line

c_addr = None
hex_to_ch = {}

ascii_stdin = io.TextIOWrapper(sys.stdin.buffer, encoding='ascii', errors='strict')

for line in ascii_stdin:
    line = line[:-1] # Strip the linefeed (we can't strip all white
                     # space here, think of a line of 0x20s)
    data, ascii_data = line.split("    ", maxsplit = 1)
    straddr, strdata = data.split(maxsplit = 1)
    addr = int.from_bytes(bytes.fromhex(straddr[:-1]), byteorder = 'big')
    if c_addr != addr - BYTES_IN_LINE:
        if c_addr:
            sys.exit("Unexpected c_addr in line: '%s'" % line)
    c_addr = addr
    data = bytes.fromhex(strdata)
    if len(data) != BYTES_IN_LINE:
        sys.exit("Unexpected number of bytes in line: '%s'" % line)
    # Verify that the mapping from hex data to ASCII is consistent (sanity check for transmission errors)
    for b, c in zip(data, ascii_data):
        try:
            if hex_to_ch[b] != c:
                sys.exit("Inconsistency between hex data and ASCII data in line (or the lines before): '%s'" % line)
        except KeyError:
            hex_to_ch[b] = c
    sys.stdout.buffer.write(data)
