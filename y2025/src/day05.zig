const std = @import("std");
const test_allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;
const Range = struct {
    start: usize,
    end: usize,
};
const ParserResult = struct {
    ranges: ArrayList(Range),
    ingredients: ArrayList(usize),
};

pub fn parser(input: []const u8, allocator: std.mem.Allocator) !ParserResult {
    var ranges = std.ArrayList(Range){};
    var ingredients = std.ArrayList(usize){};

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        const clean_line = std.mem.trim(u8, line, " \r\n\t");

        if (std.mem.indexOf(u8, line, "-") == null) {
            const ingredient = std.fmt.parseInt(usize, clean_line, 10) catch continue;
            try ingredients.append(allocator, ingredient);
            continue;
        }

        var parts = std.mem.splitScalar(u8, clean_line, '-');
        var nums: [2]usize = undefined;

        var i: usize = 0;
        while (parts.next()) |num_str| {
            const parsed = std.fmt.parseInt(usize, num_str, 10) catch continue;
            nums[i] = parsed;
            i += 1;
        }

        try ranges.append(allocator, Range{
            .start = nums[0],
            .end = nums[1],
        });
    }

    return ParserResult{
        .ranges = ranges,
        .ingredients = ingredients,
    };
}

pub fn part1(data: *ParserResult) !usize {
    var ret: usize = 0;
    for (data.*.ingredients.items) |i| {
        for (data.*.ranges.items) |r| {
            if (i >= r.start and i <= r.end) {
                ret += 1;
                break;
            }
        }
    }
    return ret;
}

pub fn part2(data: *ParserResult) !usize {
    var ret: usize = 0;
    const ranges = data.*.ranges;
    var end: usize = 0;
    std.mem.sort(Range, ranges.items, {}, struct {
        fn lessThan(_: void, a: Range, b: Range) bool {
            return a.start < b.start or (a.start == b.start and a.end < b.end);
        }
    }.lessThan);
    for (ranges.items) |r| {
        if (r.start > end) {
            ret += (r.end - r.start + 1);
            end = r.end;
        } else if (r.end > end) {
            ret += (r.end - end);
            end = r.end;
        }
    }

    return ret;
}

test "day 05 parser" {
    const input =
        \\1-3
        \\5-7
        \\10-13
        \\
        \\7
        \\14
        \\10
        \\11
    ;
    var data = try parser(input, test_allocator);
    defer data.ranges.deinit(test_allocator);
    defer data.ingredients.deinit(test_allocator);

    try std.testing.expectEqual(@as(usize, 1), data.ranges.items[0].start);
    try std.testing.expectEqual(@as(usize, 3), data.ranges.items[0].end);
    try std.testing.expectEqual(@as(usize, 3), data.ranges.items.len);
    try std.testing.expectEqual(@as(usize, 4), data.ingredients.items.len);
}

test "day 05 part 1" {
    const input = @embedFile("inputs/day05.txt");
    var data = try parser(input, test_allocator);
    defer data.ranges.deinit(test_allocator);
    defer data.ingredients.deinit(test_allocator);
    const ret = try part1(&data);
    std.debug.print("Day 05 Part1: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 733), ret);
}

test "day 05 part 2" {
    const input = @embedFile("inputs/day05.txt");
    var data = try parser(input, test_allocator);
    defer data.ranges.deinit(test_allocator);
    defer data.ingredients.deinit(test_allocator);
    const ret = try part2(&data);
    std.debug.print("Day 05 Part2: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 345821388687084), ret);
}
