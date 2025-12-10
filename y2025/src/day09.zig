const std = @import("std");
const test_allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;

const XY = struct {
    x: usize,
    y: usize,
};

const ParserResult = ArrayList(XY);

pub fn parser(input: []const u8, allocator: std.mem.Allocator) !ParserResult {
    var ret = ParserResult{};

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        const clean_line = std.mem.trim(u8, line, " \r\n\t");

        var xy: [2]usize = undefined;
        var point = std.mem.tokenizeAny(u8, clean_line, ",");
        var idx: usize = 0;
        while (point.next()) |num_str| {
            const num = try std.fmt.parseInt(usize, num_str, 10);
            xy[idx] = num;
            idx += 1;
        }
        try ret.append(allocator, XY{
            .x = xy[0],
            .y = xy[1],
        });
    }

    return ret;
}

fn abs_diff(a: usize, b: usize) usize {
    if (a > b) {
        return a - b;
    } else {
        return b - a;
    }
}

pub fn part1(data: *ParserResult) !usize {
    // ret = 0
    // for i, p1 in enumerate(points):
    //     for p2 in points[i+1:]:
    //         area = (abs(p1[0]-p2[0])+1)*(1+abs(p1[1]-p2[1]))
    //         ret = max(ret, area)
    // return ret

    var ret: usize = 0;
    for (data.*.items, 0..) |p1, idx| {
        for (data.*.items[(idx + 1)..]) |p2| {
            const area = (abs_diff(p1.x, p2.x) + 1) * (1 + abs_diff(p1.y, p2.y));
            if (area > ret) {
                ret = area;
            }
        }
    }
    return ret;
}

test "day 09 part 1" {
    const input = @embedFile("inputs/day09.txt");
    var data = try parser(input, test_allocator);

    const ret = try part1(&data);
    std.debug.print("Day 09 Part1: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 4749672288), ret);
}

const Row = struct {
    x0: usize,
    x1: usize,
    y: usize,
};

fn is_valid(rows: []Row, p1: XY, p2: XY) bool {
    // x1 = min(p1[0], p2[0])
    // y1 = min(p1[1], p2[1])
    // x2 = max(p1[0], p2[0])
    // y2 = max(p1[1], p2[1])
    // for y in range(y1,y2+1):
    //     if x1<rows[y][0] or x2>rows[y][1]:
    //         return False
    // return True

    const x1 = if (p1.x < p2.x) p1.x else p2.x;
    const y1 = if (p1.y < p2.y) p1.y else p2.y;
    const x2 = if (p1.x > p2.x) p1.x else p2.x;
    const y2 = if (p1.y > p2.y) p1.y else p2.y;

    for (y1..y2 + 1) |y| {
        const row = &rows[y];
        if (x1 < row.x0 or x2 > row.x1) {
            return false;
        }
    }
    return true;
}

pub fn part2(points: *ParserResult) !usize {
    // y = max(xy[1] for xy in points) + 1
    var max_y: usize = 0;
    for (points.*.items) |p| {
        if (p.y > max_y) {
            max_y = p.y;
        }
    }
    max_y += 1;

    var rows = try test_allocator.alloc(Row, max_y);
    defer test_allocator.free(rows);

    for (rows, 0..) |*row, idx| {
        row.* = Row{
            .x0 = std.math.maxInt(usize),
            .x1 = 0,
            .y = idx,
        };
    }

    // for p1,p2 in pairwise(points + [points[0]]):
    for (points.*.items, 0..) |p1, idx| {
        const p2 = points.*.items[(idx + 1) % points.*.items.len];
        if (p1.x == p2.x and p2.y > p1.y) {
            for (p1.y..p2.y + 1) |y| {
                var row = &rows[y];
                row.y = y;
                if (row.x1 < p1.x) {
                    row.x1 = p1.x;
                }
            }
        }
        if (p1.x == p2.x and p2.y < p1.y) {
            for (p2.y..p1.y + 1) |y| {
                var row = &rows[y];
                row.y = y;
                if (row.x0 > p1.x) {
                    row.x0 = p1.x;
                }
            }
        }
    }

    var ret: usize = 0;
    for (points.*.items, 0..) |p1, idx| {
        for (points.*.items[(idx + 1)..]) |p2| {
            const area = (abs_diff(p1.x, p2.x) + 1) * (1 + abs_diff(p1.y, p2.y));
            if (area > ret) {
                if (is_valid(rows, p1, p2)) {
                    ret = area;
                }
            }
        }
    }

    return ret;
}

test "day 09 part 2" {
    const input = @embedFile("inputs/day09.txt");
    var data = try parser(input, test_allocator);

    const ret = try part2(&data);
    std.debug.print("Day 09 Part2: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 1479665889), ret);
}
