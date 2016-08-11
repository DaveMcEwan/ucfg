#!/usr/bin/env python

import sys
from datetime import datetime
import curses
import time

datetime_fmt = '%Y-%m-%d %H:%M:%S'
timedelta_fmt = '%d weeks, %d days, %d hours, %dm%ds'
now_fmt = '      Now: %s'

start_dt_str  = '2014-09-15 09:00:00' # TODO: configurable
finish_dt_str = '2016-08-22 17:00:00' # TODO: configurable
start_dt  = datetime.strptime(start_dt_str, datetime_fmt)
finish_dt = datetime.strptime(finish_dt_str, datetime_fmt)
start_str  = 'Since: %s' % start_dt_str
finish_str = 'Until: %s' % finish_dt_str

# Get example strings to work out which is longest.
now_dt = datetime.now()
psd_td = now_dt - start_dt
rmn_td = finish_dt - now_dt

ex_now = now_fmt % now_dt.strftime(datetime_fmt)

ex_td = timedelta_fmt % (
                         999,
                         6,
                         23,
                         59,
                         59,
                        )
max_ex = max([len(s) for s in [
                               ex_td,
                               start_str,
                               ex_now,
                               finish_str,
                              ]])

def main(scr): # {{{

    curses.init_pair(1, curses.COLOR_CYAN,  curses.COLOR_BLACK)
    curses.init_pair(2, curses.COLOR_GREEN, curses.COLOR_BLACK)
    curses.init_pair(3, curses.COLOR_BLUE,  curses.COLOR_BLACK)

    # Hide the cursor.
    curses.curs_set(0)

    # Get size of screen to calculate center box coords.
    (scr_lines, scr_chars) = scr.getmaxyx()
    win_lines = 7
    win_chars = max_ex
    win_y = (scr_lines-win_lines-2)/2
    win_x = (scr_chars-win_chars-2)/2

    # Create sub-window for less refresh.
    win = curses.newwin(win_lines+2, win_chars+2, win_y, win_x)

    # Update the box exery second with time.
    while 1:

        now_dt = datetime.now()
        now_str = now_fmt % now_dt.strftime(datetime_fmt)

        psd_td = now_dt - start_dt
        rmn_td = finish_dt - now_dt

        psd_str = timedelta_fmt % (
                                   int(psd_td.days / 7),
                                   int(psd_td.days % 7),
                                   int(psd_td.seconds / 3600),
                                   int((psd_td.seconds % 3600) / 60),
                                   int((psd_td.seconds % 3600) % 60),
                                  )
        rmn_str = timedelta_fmt % (
                                   int(rmn_td.days / 7),
                                   int(rmn_td.days % 7),
                                   int(rmn_td.seconds / 3600),
                                   int((rmn_td.seconds % 3600) / 60),
                                   int((rmn_td.seconds % 3600) % 60),
                                  )

        win.clear()
        win.box()
        win.addstr(1, 1, psd_str, curses.color_pair(1))
        win.addstr(2, 1, start_str, curses.color_pair(1))
        win.addstr(4, 1, now_str, curses.color_pair(2))
        win.addstr(6, 1, finish_str, curses.color_pair(3))
        win.addstr(7, 1, rmn_str, curses.color_pair(3))
        win.refresh()
        time.sleep(1)

# }}} main

try:
    curses.wrapper(main)
except KeyboardInterrupt:
    print("KeyboardInterrupt. Exiting.")
    sys.exit()

