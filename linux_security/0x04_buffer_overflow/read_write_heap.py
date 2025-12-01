#!/usr/bin/python3

"""
Read and write to the heap segment of a process given its PID.
"""

import sys


def main():
    if len(sys.argv) != 4:
        usage()

    pid = sys.argv[1]
    search = sys.argv[2].encode("ascii")
    overwrite = sys.argv[3].encode("ascii")

    if len(search) != len(overwrite):
        print("Error: search and replace strings must have the same length")
        sys.exit(1)

    read_write_heap(pid, search, overwrite)
    print("SUCCESS!")


def usage():
    """Print usage message and exit with status code 1."""
    print("Usage: ./read_write_heap.py pid search_string replace_string")
    sys.exit(1)


def get_heap_bounds(pid):
    """
    Get the start and end addresses of the heap segment of a process.
    """
    path = f"/proc/{pid}/maps"
    with open(path, 'r') as range:
        for line in range:
            if "[heap]" in line:
                p_range = line.split(' ')[0]
                start, end = (int(x, 16) for x in p_range.split("-"))
                return start, end
    raise Exception("No heap segment found")


def read_write_heap(pid, search, replace):
    """
    Read the heap of a process, search for a string, and replace it.
    """
    start, end = get_heap_bounds(pid)
    length = end - start
    mem_path = f"/proc/{pid}/mem"
    with open(mem_path, 'r+b', 0) as mem_file:
        mem_file.seek(start)
        heap_data = mem_file.read(length)
        index = heap_data.find(search)
        if index == -1:
            raise Exception("Search string not found in heap")
        mem_file.seek(start + index)
        mem_file.write(replace)


if __name__ == "__main__":
    main()
