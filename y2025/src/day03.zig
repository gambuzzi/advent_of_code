const std = @import("std");
const test_allocator = std.heap.page_allocator;

pub fn parser(input: []const u8, allocator: std.mem.Allocator) !std.ArrayList([]const u8) {
    var ret = std.ArrayList([]const u8){};

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        const clean_line = std.mem.trim(u8, line, " \r\n\t");
        if (clean_line.len == 0) continue;

        try ret.append(allocator, clean_line);
    }

    return ret;
}

pub fn part1(data: *const std.ArrayList([]const u8)) !usize {
    var ret: usize = 0;
    for (data.*.items) |line| {
        const l = line.len;
        var m: usize = 0;

        for (0..l - 1) |i| {
            for (i + 1..l) |j| {
                const a = std.fmt.parseInt(usize, line[i .. i + 1], 10) catch continue;
                const b = std.fmt.parseInt(usize, line[j .. j + 1], 10) catch continue;
                const n = a * 10 + b;
                if (n > m) {
                    m = n;
                }
            }
        }

        ret += m;
    }
    return ret;
}

const MaxResult = struct {
    val: u8,
    idx: usize,
};

fn _max(s: []const u8) MaxResult {
    var ret: u8 = 0;
    var idx: usize = 0;
    for (0..s.len) |i| {
        if (s[i] > ret) {
            ret = s[i];
            idx = i;
        }
    }
    return MaxResult{ .val = ret, .idx = idx };
}

pub fn part2(data: *const std.ArrayList([]const u8)) !usize {
    var ret: usize = 0;
    var buf: [12]u8 = undefined;

    for (data.*.items) |line| {
        const l = line.len;
        var start: usize = 0;

        for (0..12) |i| {
            const end = l - 11 + i;
            const max = _max(line[start..end]);

            buf[i] = max.val;
            start += max.idx + 1;
        }
        ret += try std.fmt.parseInt(usize, &buf, 10);
    }
    return ret;
}

test "day 02 part 1" {
    const input = @embedFile("inputs/day03.txt");
    var data = try parser(input, test_allocator);
    defer data.deinit(test_allocator);
    const ret = try part1(&data);
    std.debug.print("Day 03 Part1: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 17166), try part1(&data));
}

test "day 02 part 2" {
    const input = @embedFile("inputs/day03.txt");
    var data = try parser(input, test_allocator);
    defer data.deinit(test_allocator);
    const ret = try part2(&data);
    std.debug.print("Day 03 Part2: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 169077317650774), try part2(&data));
}
