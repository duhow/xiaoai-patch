#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Source: https://github.com/csftech/Xiaomi-OpenWrt-firmware-toolkit
# Author: @csftech (Sheng-Fu Chang)
# MIT Licensed

import argparse
import binascii
import ctypes
import hashlib
import logging
import os
import time

class ImageHeader(ctypes.Structure):
    _fields_ = [('magic', ctypes.c_uint),
                ('signature_offset', ctypes.c_uint),
                ('crc32_checksum', ctypes.c_uint),
                ('file_type', ctypes.c_ushort),
                ('model', ctypes.c_ushort),
                ('segment_offsets', ctypes.c_uint * 8)]

class SegmentHeader(ctypes.Structure):
    _fields_ = [('magic', ctypes.c_uint),
                ('flash_address', ctypes.c_uint),
                ('length', ctypes.c_uint),
                ('partition', ctypes.c_uint),
                ('segment_name', ctypes.c_char * 32)]

class Firmware():
    def __init__(self, path):
        self.path = path
        self.image_header = ImageHeader()
        self.fd = open(self.path, 'rb')

    def verify(self):
        logging.info('[Jobs] Verifying firmware image...')
        assert self.fd.readinto(self.image_header) == ctypes.sizeof(self.image_header)

        # magic
        logging.info(f'firmware magic: {hex(self.image_header.magic)}')
        assert self.image_header.magic in [0x31524448, 0x32524448]

        if self.image_header.magic == 0x32524448:
            logging.info("NOTE: firmware seems to be encrypted?")

        # signature
        self.fd.seek(self.image_header.signature_offset)
        signature_length = int.from_bytes(self.fd.read(16), 'little')
        signature = self.fd.read()
        logging.info(f'firmware signature_offset: {hex(self.image_header.signature_offset)}')
        logging.info(f'firmware signature_length: {signature_length}')
        logging.info(f'firmware signature: {signature.hex()}')
        assert len(signature) == signature_length

        # crc32
        self.fd.seek(12)
        logging.info(f'firmware crc32_checksum: {hex(self.image_header.crc32_checksum)}')
        computed_checksum = ~binascii.crc32(self.fd.read()) & 0xffffffff
        logging.info(f'computed crc32_checksum: {hex(computed_checksum)}')
        assert self.image_header.crc32_checksum == computed_checksum

        # md5
        self.fd.seek(0)
        m = hashlib.md5()
        m.update(self.fd.read())
        hash = m.hexdigest()
        logging.info(f'computed md5 hash: {hash}')
        filename_hash = os.path.basename(self.path).split('_')[-2]
        assert hash[(len(filename_hash) * -1):] == filename_hash

        self.fd.seek(0)
        return True

    def extract(self, dest):
        logging.info('[Jobs] Extracting firmware...')
        current_time = time.strftime("%Y%m%d_%H%M%S", time.localtime())
        self.dest_dir = os.path.join(dest, f'{os.path.basename(self.path).replace(".bin", "")}_{current_time}')
        os.mkdir(self.dest_dir)
        logging.info(f'create destination directory: {self.dest_dir}')

        for address in self.image_header.segment_offsets:
            if address:
                self.fd.seek(address)
                segment_header = SegmentHeader()
                assert self.fd.readinto(segment_header) == ctypes.sizeof(segment_header)

                # extract segment
                with open(os.path.join(self.dest_dir, segment_header.segment_name.decode()), 'wb') as s:
                    s.write(self.fd.read(segment_header.length))
                    logging.info(f'extracting segment: {segment_header.segment_name.decode("ascii")}')


def run(path, extract=False, dest=None):
    logging.info(f'[MSG] Input file: {path}')
    firmware = Firmware(path)
    if firmware.verify():
        logging.info('[Jobs] Verification success: it\'s a genuine firmware from Xiaomi.')

        if extract:
            firmware.extract(dest)
            logging.info('[Jobs] Extraction complete.')


if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)s - %(message)s', level=logging.INFO)

    parser = argparse.ArgumentParser()
    parser.add_argument('-d', '--dest', help='Destination directory to store extracted files, default=current working directory', action='store')
    parser.add_argument('-e', '--extract', help='Input your firmware', action='store')
    parser.add_argument('-s', '--show', help='Show firmware info', action='store')
    args = parser.parse_args()

    if args.extract:
        firmware_path = os.path.abspath(args.extract)
        dest_path = os.getcwd()
        if args.dest:
            dest_path = args.dest
        run(firmware_path, extract=True, dest=dest_path)
    elif args.show:
        firmware_path = os.path.abspath(args.show)
        run(firmware_path)
    else:
        parser.print_help()
