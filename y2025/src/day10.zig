const std = @import("std");
const test_allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;
const Order = std.math.Order;

const Row = struct {
    lights: usize,
    buttons: [100]usize,
    jolts: [10]usize,
};

const ParserResult = ArrayList(Row);

pub fn parser(input: []const u8, allocator: std.mem.Allocator) !ParserResult {
    var ret = ParserResult{};

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        var state: u8 = 0;
        var row = Row{
            .lights = 0,
            .buttons = [_]usize{0} ** 100,
            .jolts = [_]usize{0} ** 10,
        };
        const clean_line = std.mem.trim(u8, line, "[ \r\n\t");
        var mask: usize = 1;
        var btn_idx: usize = 0;
        var jolt_idx: usize = 0;
        var jolt_acc: usize = 0;
        for (clean_line) |c| {
            switch (state) {
                0 => {
                    if (c == '#') {
                        row.lights |= mask;
                    }
                    mask <<= 1;
                    if (c == ']') {
                        state = 1;
                    }
                },
                1 => {
                    if (c == ')') {
                        btn_idx += 1;
                    }
                    if (c >= '0' and c <= '9') {
                        row.buttons[btn_idx] |= (@as(usize, 1) << @as(u6, @intCast(c - '0')));
                    }
                    if (c == '{') {
                        state = 2;
                    }
                },
                2 => {
                    if (c >= '0' and c <= '9') {
                        jolt_acc *= 10;
                        jolt_acc += @as(usize, c - '0');
                    }
                    if (c == ',' or c == '}') {
                        row.jolts[jolt_idx] = jolt_acc;
                        jolt_idx += 1;
                        jolt_acc = 0;
                    }
                },
                else => {},
            }
        }
        try ret.append(allocator, row);
    }

    return ret;
}

test "day 10 parser" {
    const input =
        \\[.##.] (3) (1,3) (2) (2,3) (0,2) (0,1) {3,5,4,7}
        \\[...#.] (0,2,3,4) (2,3) (0,4) (0,1,2) (1,2,3,4) {7,5,12,7,2}
        \\[.###.#] (0,1,2,3,4) (0,3,4) (0,1,2,4,5) (1,2) {10,11,11,5,10,5}
    ;
    const data = try parser(input, test_allocator);
    // defer test_allocator.free(data);

    try std.testing.expectEqual(@as(usize, 6), data.items[0].lights);
    try std.testing.expectEqual(@as(usize, 8), data.items[0].buttons[0]);
    try std.testing.expectEqual(@as(usize, 5), data.items[0].jolts[1]);
    try std.testing.expectEqual(@as(usize, 12), data.items[1].jolts[2]);
    try std.testing.expectEqual(@as(usize, 11), data.items[2].jolts[2]);
}

const Stack = struct {
    steps: usize,
    lights: usize,
};

fn lessThan(context: void, a: Stack, b: Stack) Order {
    _ = context;
    return std.math.order(a.steps, b.steps);
}

fn solve1(row: Row) !usize {
    var stack = std.PriorityQueue(Stack, void, lessThan).init(test_allocator, {});
    defer stack.deinit();

    var seen = std.AutoHashMap(u64, void).init(test_allocator);
    defer seen.deinit();

    try stack.add(Stack{ .steps = 0, .lights = 0 });
    try seen.put(0, {});

    while (stack.removeOrNull()) |node| {
        if (node.lights == row.lights) {
            return node.steps;
        }

        for (row.buttons) |button| {
            const next_lights = node.lights ^ button;
            if (seen.get(next_lights) == null) {
                try seen.put(next_lights, {});
                try stack.add(Stack{ .steps = node.steps + 1, .lights = next_lights });
            }
        }
    }
    return 0;
}

pub fn part1(data: *ParserResult) !usize {
    var ret: usize = 0;

    for (data.items) |row| {
        ret += try solve1(row);
    }

    return ret;
}

test "day 10 part 1" {
    const input = @embedFile("inputs/day10.txt");
    var data = try parser(input, test_allocator);

    const ret = try part1(&data);
    std.debug.print("Day 10 Part1: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 517), ret);
}
