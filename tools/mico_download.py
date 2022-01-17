#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Brute-force the download url of specific version of the MICO firmware
Dependency: Python 3.7, aiohttp, uvloop
https://docs.python.org/3/library/asyncio.html
https://aiohttp.readthedocs.io/en/stable/index.html
"""

import aiohttp
import asyncio
import string

# CHANGEME
rom = 'lx06'
version = '1.74.10'
updateType = 'all'

def base_16(num: int):
    """Base-16 Conversion
    :param num: the integer to be converted
    :param b: base
    :return: base-16 notation str
    """
    characters = string.digits + 'abcdef'
    if num < 16:
        return characters[num]
    else:
        return base_16(num // 16) + characters[num % 16]


async def download_async(session: aiohttp.ClientSession, package_name: str, url: str):
    """ Async Download Function, catches most network errors and ignores them.
    `async def` makes an asynchronous function and returns a coroutine.
     The coroutine can be run in a task, `await`ed in another coroutine, or in `asyncio.run` as "main function".
    :param session: aiohttp.ClientSession
    :param package_name: str
    :param url: str
    :return: None
    """
    try:
        # `async with` is almost the Python `with` statement,
        #  but run the resource acquisition asynchronously
        async with session.head(url) as rsp:
            if rsp.status == 200:
                print(f'Download: Found {package_name} 200')
                exit(0)
            elif rsp.status == 404:
                print(f'Download: {package_name} not found')
            else:
                print(f'Download: {package_name} failed for reason: {rsp.status}')
    except aiohttp.ClientError:
        pass
    except asyncio.TimeoutError:
        pass


# URI constants
base_url = 'http://bigota.miwifi.com/xiaoqiang/rom' # (deprecated)
# base_url = 'https://cdn.cnbj1.fds.api.mi-img.com/xiaoqiang/rom'

async def main(ntasks: int):
    tasks = []

    async with aiohttp.ClientSession() as session:
        for i in range(int('00000', 16), int('fffff', 16), ntasks):
            for j in range(i, i + ntasks):
                pid = ''.join(base_16(j).rjust(5, '0'))
                package_name = f'mico_{updateType}_{pid}_{version}.bin'
                download_url = f'{base_url}/{rom}/{package_name}'
                task = asyncio.create_task(download_async(session, package_name, download_url))
                tasks.append(task)

            await asyncio.gather(*tasks)
            tasks.clear()

if __name__ == '__main__':
    # Maximum tasks to be run at once
    connection_pool_count = 20
    # `asyncio.run` require Python 3.7
    asyncio.run(main(connection_pool_count))
