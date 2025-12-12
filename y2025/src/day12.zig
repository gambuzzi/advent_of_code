const std = @import("std");
const test_allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;
const Order = std.math.Order;

const Tree = [8]usize;

const ParserResult = struct { presents_area: [6]usize, trees: ArrayList(Tree) };

pub fn parser(input: []const u8, allocator: std.mem.Allocator) !ParserResult {
    var ret = ParserResult{
        .presents_area = [_]usize{0} ** 6,
        .trees = ArrayList(Tree){},
    };

    var state: usize = 0;
    var idx: usize = 0;
    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        const clean_line = std.mem.trim(u8, line, " \r\n\t");
        if (clean_line.len == 0) {
            continue;
        }
        if (state == 0) {
            if (clean_line[1] == ':') {
                idx = clean_line[0] - '0';
            }
            if (std.mem.containsAtLeastScalar(u8, clean_line, 1, 'x')) {
                state = 1;
            } else {
                ret.presents_area[idx] += std.mem.count(u8, clean_line, "#");
            }
        }
        if (state == 1) {
            var tree = [_]usize{0} ** 8;
            var parts = std.mem.splitAny(u8, clean_line, "x: ");
            var i: usize = 0;
            while (parts.next()) |p| {
                if (p.len == 0) {
                    continue;
                }
                tree[i] = try std.fmt.parseInt(usize, p, 10);
                i += 1;
            }
            try ret.trees.append(allocator, tree);
        }
    }

    return ret;
}

test "day 12 parser" {
    const input =
        \\0:
        \\###
        \\##.
        \\##.
        \\
        \\1:
        \\###
        \\##.
        \\.##
        \\
        \\2:
        \\.##
        \\###
        \\##.
        \\
        \\3:
        \\##.
        \\###
        \\##.
        \\
        \\4:
        \\###
        \\#..
        \\###
        \\
        \\5:
        \\###
        \\.#.
        \\###
        \\
        \\4x4: 0 0 0 0 2 0
        \\12x5: 1 0 1 0 2 2
        \\12x5: 1 0 1 0 3 2
    ;
    const data = try parser(input, test_allocator);

    try std.testing.expectEqual(@as(usize, 7), data.presents_area[0]);
    try std.testing.expectEqual(@as(usize, 7), data.presents_area[1]);
    try std.testing.expectEqual(@as(usize, 7), data.presents_area[2]);
    try std.testing.expectEqual(@as(usize, 4), data.trees.items[0][0]);
    try std.testing.expectEqual(@as(usize, 4), data.trees.items[0][1]);
    try std.testing.expectEqual(@as(usize, 12), data.trees.items[1][0]);
    try std.testing.expectEqual(@as(usize, 5), data.trees.items[1][1]);
    try std.testing.expectEqual(@as(usize, 3), data.trees.items[2][6]);
}

fn sum(data: [6]usize, multiplier: *const [6]usize) usize {
    var ret: usize = 0;
    for (data, multiplier) |d, m| {
        ret += d * m;
    }
    return ret;
}

pub fn part1(data: *ParserResult) !usize {
    var ret: usize = 0;

    for (data.trees.items) |tree| {
        const area: usize = tree[0] * tree[1];
        const total_area: usize = sum(data.presents_area, tree[2..]);
        if (total_area <= area) {
            ret += 1;
        }
    }

    return ret;
}

test "day 12 part 1" {
    const input = @embedFile("inputs/day12.txt");
    var data = try parser(input, test_allocator);

    const ret = try part1(&data);
    std.debug.print("Day 12 Part1: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 567), ret);
}
