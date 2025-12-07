const std = @import("std");
const test_allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;

const XY = struct {
    x: usize,
    y: usize,
};

const Splitters = std.AutoHashMap(XY, bool);

const ParserResult = struct {
    start: XY,
    splitters: Splitters,
    height: usize,
};

pub fn parser(input: []const u8, allocator: std.mem.Allocator) !ParserResult {
    var start = XY{ .x = 0, .y = 0 };
    var splitters = Splitters.init(allocator);

    var y: usize = 0;
    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        const clean_line = std.mem.trim(u8, line, " \r\n\t");
        for (clean_line, 0..) |c, x| {
            if (c == 'S') {
                start = XY{ .x = x, .y = y };
            } else if (c == '^') {
                try splitters.put(XY{ .x = x, .y = y }, true);
            }
        }
        y += 1;
    }

    return ParserResult{
        .start = start,
        .splitters = splitters,
        .height = y,
    };
}

pub fn part1(data: *ParserResult) !usize {
    var ret: usize = 0;
    var y = data.*.start.y;

    var beams = std.AutoHashMap(usize, bool).init(test_allocator);
    defer beams.deinit();

    try beams.put(data.*.start.x, true);

    while (y < data.*.height) {
        var it = beams.iterator();
        while (it.next()) |entry| {
            const x: usize = entry.key_ptr.*;
            const v: bool = entry.value_ptr.*;
            if (v) {
                const needle = XY{ .x = x, .y = y };
                if (data.*.splitters.contains(needle)) {
                    ret += 1;
                    try beams.put(x, false);
                    try beams.put(x - 1, true);
                    try beams.put(x + 1, true);
                }
            }
        }
        y += 1;
    }

    return ret;
}

test "day 07 part 1" {
    const input = @embedFile("inputs/day07.txt");
    var data = try parser(input, test_allocator);
    defer data.splitters.deinit();

    const ret = try part1(&data);
    std.debug.print("Day 07 Part1: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 1587), ret);
}

pub fn part2(data: *ParserResult) !usize {
    var y = data.*.start.y;

    var beams = std.AutoHashMap(usize, usize).init(test_allocator);
    var new_beams = std.AutoHashMap(usize, usize).init(test_allocator);
    defer beams.deinit();
    defer new_beams.deinit();

    try beams.put(data.*.start.x, 1);

    while (y < data.*.height) {
        new_beams.clearRetainingCapacity();

        var it = beams.iterator();
        while (it.next()) |entry| {
            const x: usize = entry.key_ptr.*;
            const mult: usize = entry.value_ptr.*;

            const needle = XY{ .x = x, .y = y };
            if (data.*.splitters.contains(needle)) {
                try new_beams.put(x - 1, (new_beams.get(x - 1) orelse 0) + mult);
                try new_beams.put(x + 1, (new_beams.get(x + 1) orelse 0) + mult);
            } else {
                try new_beams.put(x, (new_beams.get(x) orelse 0) + mult);
            }
        }
        beams.clearRetainingCapacity();
        var it2 = new_beams.iterator();
        while (it2.next()) |entry| {
            const key = entry.key_ptr.*;
            const val = entry.value_ptr.*;
            try beams.put(key, val);
        }
        y += 1;
    }

    var ret: usize = 0;
    var it = beams.iterator();
    while (it.next()) |entry| {
        const mult: usize = entry.value_ptr.*;
        ret += mult;
    }

    return ret;
}

test "day 07 part 2" {
    const input = @embedFile("inputs/day07.txt");
    var data = try parser(input, test_allocator);
    defer data.splitters.deinit();

    const ret = try part2(&data);
    std.debug.print("Day 07 Part2: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 5748679033029), ret);
}
