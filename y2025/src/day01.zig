const std = @import("std");
const test_allocator = std.testing.allocator;

fn part1(input: []const u8) !usize {
    var ret: usize = 0;
    var pos: usize = 50;

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        const clean_line = std.mem.trim(u8, line, " \r\n\t");
        if (clean_line.len == 0) continue;

        const n = try std.fmt.parseInt(usize, clean_line[1..], 10);
        if (clean_line[0] == 'L') {
            pos = pos + 10000 - n;
        } else {
            pos = pos + n;
        }

        pos %= 100;
        if (pos == 0) {
            ret += 1;
        }
    }
    return ret;
}

fn part2(input: []const u8) !usize {
    var ret: usize = 0;
    var pos: i32 = 50;
    var delta: i32 = 1;

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        const clean_line = std.mem.trim(u8, line, " \r\n\t");
        if (clean_line.len == 0) continue;
        var n = try std.fmt.parseInt(i32, clean_line[1..], 10);
        if (clean_line[0] == 'L') {
            delta = -1;
        } else {
            delta = 1;
        }

        while (n != 0) {
            n -= 1;
            pos = pos + delta;
            pos = @rem(pos, 100);
            if (pos == 0) {
                ret += 1;
            }
        }
    }
    return ret;
}

test "day 01 part 1" {
    const input = @embedFile("inputs/day01.txt");
    const ret = try part1(input);
    std.debug.print("part1: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 1026), try part1(input));
}

test "day 01 part 2" {
    const input = @embedFile("inputs/day01.txt");
    const ret = try part2(input);
    std.debug.print("part2: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 5923), try part2(input));
}
