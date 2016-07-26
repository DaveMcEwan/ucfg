#!/usr/bin/env python
'''
Take HTML input from either specified file(s), or STDIN and replace all of the
  images with embedded base64, and embed all the linked JS and CSS.
This allows the HTML file to be distributed as a standalone file.
The resulting HTML is printed to STDOUT.
Relative paths are from the CWD, not from the any input files.
'''

import sys

def embed_raster(filename, img_format):
    '''Take image path and return HTML encode string.
Source filename should be a relative or absolute path/URL.
Image format should be a string like 'png', or 'jpg'.
    '''
    if int(sys.version[0]) < 3:
        from urllib import quote
    else:
        from urllib.parse import quote
    import base64
    img = open(filename, "rb").read()
    img_b64 = base64.b64encode(img)
    encoded = quote(img_b64)
    return 'data:image/%s;base64,%s' % (img_format, encoded)


def embed_svg(filename):
    '''Take image path and return SVG string.
Source filename should be a relative or absolute path/URL.
    '''
    return open(filename, "r").read()


def embed_css(filename):
    '''Take stylesheet path and return CSS string.
Source filename should be a relative or absolute path/URL.
    '''
    return '<style type="text/css">%s</style>' % open(filename, "r").read()


def embed_js(filename):
    '''Take script path and return JS string.
Source filename should be a relative or absolute path/URL.
    '''
    return '<script type="text/javascript">%s</script>' % open(filename, "r").read()


def html_unlink(s=''):
    '''Take an HTML string and return it with linked features embedded.
PNG and JPG files are embedded as data URIs.
SVG files are embedded directly.
CSS links are embedded directly in <style> tags.
External JS scripts are embedded directly in <script> tags.
    '''
    import re

    # Find all link tags and the href attributes.
    # Assumes <link ... /> tags which have no children.
    # Ignores other attributes and relies on .css file extension.
    link_re = re.compile(r'(<link\s+[^>]*href=[\'"]?([^\'" ]+)[^>]*>)')
    i = 0
    while i < len(s):
        link_match = link_re.search(s, i)
        if link_match == None: break
        i = link_match.end(0)
        href_val = link_match.group(2)
        extension = href_val[-4:].lower()
        if extension == '.css':
            link_start = link_match.start(0)
            link_end = link_match.end(0)
            s_pre = s[:link_start]
            s_post = s[link_end:]
            new_link = embed_css(href_val)
            i = link_start + len(new_link) # Skip regex over new data.
            s = ''.join([s_pre, new_link, s_post])


    # Find all script tags with src attributes.
    # Assumes <script ... /> tags which have no children, as per HTML standard.
    # Ignores other attributes and relies on .js file extension.
    script_re = re.compile(r'(<script\s+[^>]*src=[\'"]?([^\'" ]+)[^>]*>)')
    i = 0
    while i < len(s):
        script_match = script_re.search(s, i)
        if script_match == None: break
        i = script_match.end(0)
        src_val = script_match.group(2)
        extension = src_val[-3:].lower()
        if extension == '.js':
            script_start = script_match.start(0)
            script_end = script_match.end(0)
            s_pre = s[:script_start]
            s_post = s[script_end:]
            new_script = embed_js(src_val)
            i = script_start + len(new_script) # Skip regex over new data.
            s = ''.join([s_pre, new_script, s_post])


    # Find all img tags and the src attributes.
    # Assumes <img ... /> tags which have no children.
    img_re = re.compile(r'(<img\s+[^>]*src=[\'"]?([^\'" ]+)[^>]*>)')
    i = 0
    while i < len(s):
        img_match = img_re.search(s, i)
        if img_match == None: break
        i = img_match.end(0)
        src_val = img_match.group(2)
        extension = src_val[-4:].lower()

        # Embed SVGs.
        if extension == '.svg':
            img_start = img_match.start(0)
            img_end = img_match.end(0)
            s_pre = s[:img_start]
            s_post = s[img_end:]
            new_img = embed_svg(src_val)
            i = img_start + len(new_img) # Skip regex over new data.
            s = ''.join([s_pre, new_img, s_post])

        # Embed PNGs and JPGs.
        # Anything else is ignored.
        elif extension in ['.png', '.jpg']:
            src_start = img_match.start(2)
            src_end = img_match.end(2)
            s_pre = s[:src_start]
            s_post = s[src_end:]
            new_src = embed_raster(src_val, extension[1:])
            i += len(new_src) - len(src_val) # Skip regex over new data.
            s = ''.join([s_pre, new_src, s_post])
    return s


if __name__ == '__main__':

    # Build command line interface.
    import argparse
    parser = argparse.ArgumentParser()

    parser.add_argument('input',
                        nargs='*',
                        default='STDIN',
                        help='HTML input')
    args = vars(parser.parse_args())

    # Read input from STDIN or files into a single string.
    import fileinput
    if args['input'] == 'STDIN':
        input_src = fileinput.input()
    else:
        input_src = fileinput.input(args['input'])
    input_str = ''.join(input_src)

    # Process the input and put it on STDOUT.
    print(html_unlink(input_str))

