const std = @import("std");
const test_allocator = std.heap.page_allocator;

const Range = struct { a: usize, b: usize };

pub fn parser(s: []const u8, allocator: std.mem.Allocator) !std.ArrayList(Range) {
    var ranges = std.ArrayList(Range){};

    var parts = std.mem.splitScalar(u8, s, ',');
    while (parts.next()) |part| {
        var range_parts = std.mem.splitScalar(u8, part, '-');
        var nums: [2]usize = undefined;

        var i: usize = 0;
        while (range_parts.next()) |num_str| {
            const parsed = std.fmt.parseInt(usize, num_str, 10) catch continue;
            nums[i] = parsed;
            i += 1;
        }

        try ranges.append(allocator, .{ .a = nums[0], .b = nums[1] });
    }

    return ranges;
}

pub fn part1(data: *const std.ArrayList(Range)) !usize {
    var ret: usize = 0;
    for (data.*.items) |pair| {
        const a = pair.a;
        const b = pair.b + 1;
        for (a..b) |x| {
            var buf: [32]u8 = undefined;
            const s = std.fmt.bufPrint(&buf, "{}", .{x}) catch continue;

            const l = s.len;
            if (l % 2 == 0) {
                if (std.mem.eql(u8, s[0 .. l / 2], s[l / 2 .. l])) {
                    ret += x;
                }
            }
        }
    }
    return ret;
}

pub fn part2(data: *const std.ArrayList(Range)) !usize {
    var ret: usize = 0;
    for (data.*.items) |pair| {
        const a = pair.a;
        const b = pair.b + 1;
        for (a..b) |x| {
            // Pre-allocate buffer with max size to avoid repeated allocations
            var buf: [32]u8 = undefined;
            const s = std.fmt.bufPrint(&buf, "{}", .{x}) catch continue;

            const l = s.len;
            // Only check divisors of the length
            for (1..l / 2 + 1) |m| {
                if (l % m != 0) continue;

                const sub = s[0..m];

                // Direct comparison instead of building temporary string
                var matches = true;
                var i: usize = m;
                while (i < l) : (i += m) {
                    if (!std.mem.eql(u8, s[i .. i + m], sub)) {
                        matches = false;
                        break;
                    }
                }

                if (matches) {
                    ret += x;
                    break;
                }
            }
        }
    }
    return ret;
}

test "day 02 part 1" {
    const input = @embedFile("inputs/day02.txt");
    var data = try parser(input, test_allocator);
    defer data.deinit(test_allocator);
    const ret = try part1(&data);
    std.debug.print("Day 02 Part1: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 21139440284), try part1(&data));
}

test "day 02 part 2" {
    const input = @embedFile("inputs/day02.txt");
    var data = try parser(input, test_allocator);
    defer data.deinit(test_allocator);
    const ret = try part2(&data);
    std.debug.print("Day 02 Part2: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 38731915928), try part2(&data));
}
