#!/usr/bin/env python3
#
# Copyright 2018, The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
"""Unpacks the boot image.
Extracts the kernel, ramdisk, second bootloader, dtb and recovery dtbo images.
"""
from argparse import ArgumentParser, FileType, RawDescriptionHelpFormatter
from struct import unpack
import json
import os
BOOT_IMAGE_HEADER_V3_PAGESIZE = 4096
VENDOR_RAMDISK_NAME_SIZE = 32
VENDOR_RAMDISK_TABLE_ENTRY_BOARD_ID_SIZE = 16
MKBOOTIMG_ARGS_FILE = 'mkbootimg_args.json'
def create_out_dir(dir_path):
    """creates a directory 'dir_path' if it does not exist"""
    if not os.path.exists(dir_path):
        os.makedirs(dir_path)
def extract_image(offset, size, bootimage, extracted_image_name):
    """extracts an image from the bootimage"""
    bootimage.seek(offset)
    with open(extracted_image_name, 'wb') as file_out:
        file_out.write(bootimage.read(size))
def get_number_of_pages(image_size, page_size):
    """calculates the number of pages required for the image"""
    return (image_size + page_size - 1) // page_size
def cstr(s):
    """Remove first NULL character and any character beyond."""
    return s.split('\0', 1)[0]
def format_os_version(os_version):
    a = os_version >> 14
    b = os_version >> 7 & ((1<<7) - 1)
    c = os_version & ((1<<7) - 1)
    return '{}.{}.{}'.format(a, b, c)
def format_os_patch_level(os_patch_level):
    y = os_patch_level >> 4
    y += 2000
    m = os_patch_level & ((1<<4) - 1)
    return '{:04d}-{:02d}'.format(y, m)
def print_os_version_patch_level(value):
    os_version = value >> 11
    os_patch_level = value & ((1<<11) - 1)
    print('os version: %s' % format_os_version(os_version))
    print('os patch level: %s' % format_os_patch_level(os_patch_level))
def decode_os_version_patch_level(os_version_patch_level):
    """Returns a tuple of (os_version, os_patch_level)."""
    os_version = os_version_patch_level >> 11
    os_patch_level = os_version_patch_level & ((1<<11) - 1)
    return (format_os_version(os_version),
            format_os_patch_level(os_patch_level))
def get_boot_image_v2_and_below_args(header_version, page_size,
                                     kernel_load_address, ramdisk_load_address,
                                     second_load_address, tags_load_address,
                                     dtb_load_address, cmdline, extra_cmdline,
                                     os_version_patch_level, product_name):
    """Returns a dict of mkbootimg.py arguments for v0, v1 and v2 boot.img."""
    mkbootimg_args = {}
    mkbootimg_args['header_version'] = str(header_version)
    # The type of pagesize is uint32_t, using '0xFFFFFFFF' as the output format.
    mkbootimg_args['pagesize'] = '{:#010x}'.format(page_size)
    # Kernel load address is base + kernel_offset in mkbootimg.py.
    # However, we don't know the value of 'base' when unpack a boot.img
    # in this script. So always set 'base' to be zero and 'kernel_offset' to
    # be the kernel load address. Same for 'ramdisk_offset', 'second_offset',
    # 'tags_offset' and 'dtb_offset'.
    # The following types are uint32_t, using '0xFFFFFFFF' as the output format.
    mkbootimg_args['base'] = '{:#010x}'.format(0)
    mkbootimg_args['kernel_offset'] = '{:#010x}'.format(kernel_load_address)
    mkbootimg_args['ramdisk_offset'] = '{:#010x}'.format(ramdisk_load_address)
    mkbootimg_args['second_offset'] = '{:#010x}'.format(second_load_address)
    mkbootimg_args['tags_offset'] = '{:#010x}'.format(tags_load_address)
    # dtb is added in boot image v2, and is absent in v1 or v0.
    if header_version == 2:
        # The type of dtb_offset is uint64_t, using '0xFFFFFFFFEEEEEEEE' as
        # the output format.
        mkbootimg_args['dtb_offset'] = '{:#018x}'.format(dtb_load_address)
    mkbootimg_args['os_version'], mkbootimg_args['os_patch_level'] = (
        decode_os_version_patch_level(os_version_patch_level))
    mkbootimg_args['cmdline'] = cmdline + extra_cmdline
    mkbootimg_args['board'] = product_name
    return mkbootimg_args
def get_boot_image_v3_args(header_version, os_version_patch_level, cmdline):
    """Returns a dict of arguments to be used in mkbootimg.py later."""
    mkbootimg_args = {}
    mkbootimg_args['header_version'] = str(header_version)
    mkbootimg_args['os_version'], mkbootimg_args['os_patch_level'] = (
        decode_os_version_patch_level(os_version_patch_level))
    mkbootimg_args['cmdline'] = cmdline
    return mkbootimg_args
def unpack_boot_image(args):
    """extracts kernel, ramdisk, second bootloader and recovery dtbo"""
    boot_magic = unpack('8s', args.boot_img.read(8))[0].decode()
    print('boot_magic: %s' % boot_magic)
    kernel_ramdisk_second_info = unpack('9I', args.boot_img.read(9 * 4))
    # version is always at [8] regardless of version.
    version = kernel_ramdisk_second_info[8]
    if version < 3:
        kernel_size = kernel_ramdisk_second_info[0]
        kernel_load_address = kernel_ramdisk_second_info[1]
        ramdisk_size = kernel_ramdisk_second_info[2]
        ramdisk_load_address = kernel_ramdisk_second_info[3]
        second_size = kernel_ramdisk_second_info[4]
        second_load_address = kernel_ramdisk_second_info[5]
        tags_load_address = kernel_ramdisk_second_info[6]
        page_size = kernel_ramdisk_second_info[7]
        os_version_patch_level = unpack('I', args.boot_img.read(1 * 4))[0]
    else:
        kernel_size = kernel_ramdisk_second_info[0]
        ramdisk_size = kernel_ramdisk_second_info[1]
        os_version_patch_level = kernel_ramdisk_second_info[2]
        second_size = 0
        page_size = BOOT_IMAGE_HEADER_V3_PAGESIZE
    if version < 3:
        print('kernel_size: %s' % kernel_size)
        print('kernel load address: %#x' % kernel_load_address)
        print('ramdisk size: %s' % ramdisk_size)
        print('ramdisk load address: %#x' % ramdisk_load_address)
        print('second bootloader size: %s' % second_size)
        print('second bootloader load address: %#x' % second_load_address)
        print('kernel tags load address: %#x' % tags_load_address)
        print('page size: %s' % page_size)
        print_os_version_patch_level(os_version_patch_level)
    else:
        print('kernel_size: %s' % kernel_size)
        print('ramdisk size: %s' % ramdisk_size)
        print_os_version_patch_level(os_version_patch_level)
    print('boot image header version: %s' % version)
    if version < 3:
        product_name = cstr(unpack('16s', args.boot_img.read(16))[0].decode())
        print('product name: %s' % product_name)
        cmdline = cstr(unpack('512s', args.boot_img.read(512))[0].decode())
        print('command line args: %s' % cmdline)
    else:
        cmdline = cstr(unpack('1536s', args.boot_img.read(1536))[0].decode())
        print('command line args: %s' % cmdline)
    if version < 3:
        args.boot_img.read(32)  # ignore SHA
    if version < 3:
        try:
            extra_cmdline = cstr(unpack('1024s',
                                    args.boot_img.read(1024))[0].decode())
            print('additional command line args: %s' % extra_cmdline)
        except:
            print('cant decode')
            extra_cmdline = ''
    if 0 < version < 3:
        recovery_dtbo_size = unpack('I', args.boot_img.read(1 * 4))[0]
        print('recovery dtbo size: %s' % recovery_dtbo_size)
        recovery_dtbo_offset = unpack('Q', args.boot_img.read(8))[0]
        print('recovery dtbo offset: %#x' % recovery_dtbo_offset)
        boot_header_size = unpack('I', args.boot_img.read(4))[0]
        print('boot header size: %s' % boot_header_size)
    else:
        recovery_dtbo_size = 0
    if 1 < version < 3:
        dtb_size = unpack('I', args.boot_img.read(4))[0]
        print('dtb size: %s' % dtb_size)
        dtb_load_address = unpack('Q', args.boot_img.read(8))[0]
        print('dtb address: %#x' % dtb_load_address)
    else:
        dtb_size = 0
        dtb_load_address = 0
    # Saves the arguments to be reused in mkbootimg.py later.
    if version < 3:
        mkbootimg_args = get_boot_image_v2_and_below_args(
            version, page_size, kernel_load_address, ramdisk_load_address,
            second_load_address, tags_load_address, dtb_load_address, cmdline,
            extra_cmdline, os_version_patch_level, product_name)
    else:
        mkbootimg_args = get_boot_image_v3_args(
            version, os_version_patch_level, cmdline)
    with open(os.path.join(args.out, MKBOOTIMG_ARGS_FILE), 'w') as f:
        json.dump(mkbootimg_args, f, sort_keys=True, indent=4)
    if version >= 4:
        boot_signature_size = unpack('I', args.boot_img.read(4))[0]
        print('boot.img signature size: %s' % boot_signature_size)
    else:
        boot_signature_size = 0
    # The first page contains the boot header
    num_header_pages = 1
    num_kernel_pages = get_number_of_pages(kernel_size, page_size)
    kernel_offset = page_size * num_header_pages  # header occupies a page
    image_info_list = [(kernel_offset, kernel_size, 'kernel')]
    num_ramdisk_pages = get_number_of_pages(ramdisk_size, page_size)
    ramdisk_offset = page_size * (num_header_pages + num_kernel_pages
                                 ) # header + kernel
    image_info_list.append((ramdisk_offset, ramdisk_size, 'ramdisk'))
    if second_size > 0:
        second_offset = page_size * (
            num_header_pages + num_kernel_pages + num_ramdisk_pages
            )  # header + kernel + ramdisk
        image_info_list.append((second_offset, second_size, 'second'))
    if recovery_dtbo_size > 0:
        image_info_list.append((recovery_dtbo_offset, recovery_dtbo_size,
                                'recovery_dtbo'))
    if dtb_size > 0:
        num_second_pages = get_number_of_pages(second_size, page_size)
        num_recovery_dtbo_pages = get_number_of_pages(
            recovery_dtbo_size, page_size)
        dtb_offset = page_size * (
            num_header_pages + num_kernel_pages + num_ramdisk_pages +
            num_second_pages + num_recovery_dtbo_pages)
        image_info_list.append((dtb_offset, dtb_size, 'dtb'))
    if boot_signature_size > 0:
        # boot signature only exists in boot.img version >= v4.
        # There are only kernel and ramdisk pages before the signature.
        boot_signature_offset = page_size * (
            num_header_pages + num_kernel_pages + num_ramdisk_pages)
        image_info_list.append((boot_signature_offset, boot_signature_size,
                                'boot_signature'))
    for image_info in image_info_list:
        extract_image(image_info[0], image_info[1], args.boot_img,
                      os.path.join(args.out, image_info[2]))
class VendorBootImageInfoFormatter:
    """Formats the vendor_boot image info."""
    def format_pretty_text(self):
        lines = []
        lines.append(f'boot magic: {self.boot_magic}')
        lines.append(f'vendor boot image header version: {self.header_version}')
        lines.append(f'page size: {self.page_size:#010x}')
        lines.append(f'kernel load address: {self.kernel_load_address:#010x}')
        lines.append(f'ramdisk load address: {self.ramdisk_load_address:#010x}')
        if self.header_version > 3:
            lines.append(
                f'vendor ramdisk total size: {self.vendor_ramdisk_size}')
        else:
            lines.append(f'vendor ramdisk size: {self.vendor_ramdisk_size}')
        lines.append(f'vendor command line args: {self.cmdline}')
        lines.append(
            f'kernel tags load address: {self.tags_load_address:#010x}')
        lines.append(f'product name: {self.product_name}')
        lines.append(f'vendor boot image header size: {self.header_size}')
        lines.append(f'dtb size: {self.dtb_size}')
        lines.append(f'dtb address: {self.dtb_load_address:#018x}')
        if self.header_version > 3:
            lines.append(
                f'vendor ramdisk table size: {self.vendor_ramdisk_table_size}')
            lines.append('vendor ramdisk table: [')
            indent = lambda level: ' ' * 4 * level
            for entry in self.vendor_ramdisk_table:
                (output_ramdisk_name, ramdisk_size, ramdisk_offset,
                 ramdisk_type, ramdisk_name, board_id) = entry
                lines.append(indent(1) + f'{output_ramdisk_name}: ''{')
                lines.append(indent(2) + f'size: {ramdisk_size}')
                lines.append(indent(2) + f'offset: {ramdisk_offset}')
                lines.append(indent(2) + f'type: {ramdisk_type:#x}')
                lines.append(indent(2) + f'name: {ramdisk_name}')
                lines.append(indent(2) + 'board_id: [')
                stride = 4
                for row_idx in range(0, len(board_id), stride):
                    row = board_id[row_idx:row_idx + stride]
                    lines.append(
                        indent(3) + ' '.join(f'{e:#010x},' for e in row))
                lines.append(indent(2) + ']')
                lines.append(indent(1) + '}')
            lines.append(']')
            lines.append(
                f'vendor bootconfig size: {self.vendor_bootconfig_size}')
        return '\n'.join(lines)
    def format_json_dict(self):
        """Returns a dict of arguments to be used in mkbootimg.py later."""
        args_dict = {}
        args_dict['header_version'] = str(self.header_version)
        # Format uint32_t as '0xFFFFFFFF', uint64_t as '0xFFFFFFFFEEEEEEEE'.
        args_dict['pagesize'] = f'{self.page_size:#010x}'
        # Kernel load address is base + kernel_offset in mkbootimg.py.
        # However, we don't know the value of 'base' when unpacking a
        # vendor_boot.img in this script. So always set 'base' to be zero and
        # 'kernel_offset' to be the kernel load address. Same for
        # 'ramdisk_offset', 'tags_offset' and 'dtb_offset'.
        args_dict['base'] = f'{0:#010x}'
        args_dict['kernel_offset'] = f'{self.kernel_load_address:#010x}'
        args_dict['ramdisk_offset'] = f'{self.ramdisk_load_address:#010x}'
        args_dict['tags_offset'] = f'{self.tags_load_address:#010x}'
        # The type of dtb_offset is uint64_t.
        args_dict['dtb_offset'] = f'{self.dtb_load_address:#018x}'
        args_dict['vendor_cmdline'] = self.cmdline
        args_dict['board'] = self.product_name
        # TODO(bowgotsai): support for multiple vendor ramdisk (vendor boot v4).
        return args_dict
def unpack_vendor_boot_image(args):
    info = VendorBootImageInfoFormatter()
    info.boot_magic = unpack('8s', args.boot_img.read(8))[0].decode()
    info.header_version = unpack('I', args.boot_img.read(4))[0]
    info.page_size = unpack('I', args.boot_img.read(4))[0]
    info.kernel_load_address = unpack('I', args.boot_img.read(4))[0]
    info.ramdisk_load_address = unpack('I', args.boot_img.read(4))[0]
    info.vendor_ramdisk_size = unpack('I', args.boot_img.read(4))[0]
    info.cmdline = cstr(unpack('2048s', args.boot_img.read(2048))[0].decode())
    info.tags_load_address = unpack('I', args.boot_img.read(4))[0]
    info.product_name = cstr(unpack('16s', args.boot_img.read(16))[0].decode())
    info.header_size = unpack('I', args.boot_img.read(4))[0]
    info.dtb_size = unpack('I', args.boot_img.read(4))[0]
    info.dtb_load_address = unpack('Q', args.boot_img.read(8))[0]
    # Convenient shorthand.
    page_size = info.page_size
    # The first pages contain the boot header
    num_boot_header_pages = get_number_of_pages(info.header_size, page_size)
    num_boot_ramdisk_pages = get_number_of_pages(
        info.vendor_ramdisk_size, page_size)
    num_boot_dtb_pages = get_number_of_pages(info.dtb_size, page_size)
    ramdisk_offset_base = page_size * num_boot_header_pages
    image_info_list = []
    if info.header_version > 3:
        info.vendor_ramdisk_table_size = unpack('I', args.boot_img.read(4))[0]
        vendor_ramdisk_table_entry_num = unpack('I', args.boot_img.read(4))[0]
        vendor_ramdisk_table_entry_size = unpack('I', args.boot_img.read(4))[0]
        info.vendor_bootconfig_size = unpack('I', args.boot_img.read(4))[0]
        num_vendor_ramdisk_table_pages = get_number_of_pages(
            info.vendor_ramdisk_table_size, page_size)
        vendor_ramdisk_table_offset = page_size * (
            num_boot_header_pages + num_boot_ramdisk_pages + num_boot_dtb_pages)
        vendor_ramdisk_table = []
        for idx in range(vendor_ramdisk_table_entry_num):
            entry_offset = vendor_ramdisk_table_offset + (
                vendor_ramdisk_table_entry_size * idx)
            args.boot_img.seek(entry_offset)
            ramdisk_size = unpack('I', args.boot_img.read(4))[0]
            ramdisk_offset = unpack('I', args.boot_img.read(4))[0]
            ramdisk_type = unpack('I', args.boot_img.read(4))[0]
            ramdisk_name = cstr(unpack(
                f'{VENDOR_RAMDISK_NAME_SIZE}s',
                args.boot_img.read(VENDOR_RAMDISK_NAME_SIZE))[0].decode())
            board_id = unpack(
                f'{VENDOR_RAMDISK_TABLE_ENTRY_BOARD_ID_SIZE}I',
                args.boot_img.read(
                    4 * VENDOR_RAMDISK_TABLE_ENTRY_BOARD_ID_SIZE))
            output_ramdisk_name = f'vendor_ramdisk{idx:02}'
            image_info_list.append((ramdisk_offset_base + ramdisk_offset,
                                    ramdisk_size, output_ramdisk_name))
            vendor_ramdisk_table.append(
                (output_ramdisk_name, ramdisk_size, ramdisk_offset,
                 ramdisk_type, ramdisk_name, board_id))
        info.vendor_ramdisk_table = vendor_ramdisk_table
        bootconfig_offset = page_size * (num_boot_header_pages
            + num_boot_ramdisk_pages + num_boot_dtb_pages
            + num_vendor_ramdisk_table_pages)
        image_info_list.append((bootconfig_offset, info.vendor_bootconfig_size,
            'bootconfig'))
    else:
        image_info_list.append(
            (ramdisk_offset_base, info.vendor_ramdisk_size, 'vendor_ramdisk'))
    dtb_offset = page_size * (num_boot_header_pages + num_boot_ramdisk_pages
                             ) # header + vendor_ramdisk
    image_info_list.append((dtb_offset, info.dtb_size, 'dtb'))
    for image_info in image_info_list:
        extract_image(image_info[0], image_info[1], args.boot_img,
                      os.path.join(args.out, image_info[2]))
    info.image_dir = args.out
    # Saves the arguments to be reused in mkbootimg.py later.
    mkbootimg_args = info.format_json_dict()
    with open(os.path.join(args.out, MKBOOTIMG_ARGS_FILE), 'w') as f:
        json.dump(mkbootimg_args, f, sort_keys=True, indent=4)
    print(info.format_pretty_text())
def unpack_image(args):
    boot_magic = unpack('8s', args.boot_img.read(8))[0].decode()
    args.boot_img.seek(0)
    if boot_magic == 'ANDROID!':
        unpack_boot_image(args)
    elif boot_magic == 'VNDRBOOT':
        unpack_vendor_boot_image(args)
def parse_cmdline():
    """parse command line arguments"""
    parser = ArgumentParser(
        formatter_class=RawDescriptionHelpFormatter,
        description='Unpacks boot, recovery or vendor_boot image.',
    )
    parser.add_argument('--boot_img', type=FileType('rb'), required=True,
                        help='path to the boot, recovery or vendor_boot image')
    parser.add_argument('--out', default='out',
                        help='output directory of the unpacked images')
    return parser.parse_args()
def main():
    """parse arguments and unpack boot image"""
    args = parse_cmdline()
    create_out_dir(args.out)
    unpack_image(args)
if __name__ == '__main__':
    main()
