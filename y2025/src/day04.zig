const std = @import("std");
const test_allocator = std.heap.page_allocator;

pub fn parser(input: []const u8, allocator: std.mem.Allocator) !std.ArrayList([]u8) {
    var ret = std.ArrayList([]u8){};

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        const clean_line = std.mem.trim(u8, line, " \r\n\t");

        if (clean_line.len == 0) continue;

        const line_copy = try allocator.alloc(u8, clean_line.len);
        @memcpy(line_copy, clean_line);
        try ret.append(allocator, line_copy);
    }

    return ret;
}

pub fn adj(data: *const std.ArrayList([]u8), x: usize, y: usize) usize {
    var ret: usize = 0;

    const items = data.*.items;
    const dirs = [_][2]i32{
        .{ -1, -1 }, .{ 0, -1 }, .{ 1, -1 },
        .{ -1, 0 },  .{ 1, 0 },  .{ -1, 1 },
        .{ 0, 1 },   .{ 1, 1 },
    };

    for (dirs) |d| {
        const nx = @as(i32, @intCast(x)) + d[0];
        const ny = @as(i32, @intCast(y)) + d[1];

        if (ny >= 0 and nx >= 0 and
            ny < items.len and
            nx < items[@as(usize, @intCast(ny))].len)
        {
            const uy = @as(usize, @intCast(ny));
            const ux = @as(usize, @intCast(nx));
            if (items[uy][ux] == '@')
                ret += 1;
        }
    }

    return ret;
}

pub fn part1(data: *const std.ArrayList([]u8)) !usize {
    var ret: usize = 0;
    for (data.*.items, 0..) |row, y| {
        for (row, 0..) |cell, x| {
            if (cell == '@' and adj(data, x, y) < 4)
                ret += 1;
        }
    }
    return ret;
}

const Point = struct {
    x: usize,
    y: usize,
};

const RemoveList = struct {
    points: [137 * 137]Point,
    len: usize,
};

pub fn removable(data: *const std.ArrayList([]u8)) ?RemoveList {
    var ret: usize = 0;
    var list: [137 * 137]Point = undefined;
    for (data.*.items, 0..) |row, y| {
        for (row, 0..) |cell, x| {
            if (cell == '@' and adj(data, x, y) < 4) {
                list[ret] = Point{ .x = x, .y = y };
                ret += 1;
            }
        }
    }
    if (ret == 0) {
        return null;
    }
    return RemoveList{
        .points = list,
        .len = ret,
    };
}

pub fn part2(data: *const std.ArrayList([]u8)) !usize {
    var ret: usize = 0;
    var items = data.*.items;

    while (removable(data)) |rem| {
        for (rem.points[0..rem.len]) |p| {
            items[p.y][p.x] = '.';
        }
        ret += rem.len;
    }
    return ret;
}

test "day 02 part 1" {
    const input = @embedFile("inputs/day04.txt");
    var data = try parser(input, test_allocator);
    defer data.deinit(test_allocator);
    const ret = try part1(&data);
    std.debug.print("Day 04 Part1: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 1411), ret);
}

test "day 02 part 2" {
    const input = @embedFile("inputs/day04.txt");
    var data = try parser(input, test_allocator);
    defer data.deinit(test_allocator);
    const ret = try part2(&data);
    std.debug.print("Day 04 Part2: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 8557), ret);
}
