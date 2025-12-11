const std = @import("std");
const test_allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;
const StringHashMap = std.StringHashMap;

const ParserResult = StringHashMap(ArrayList([]const u8));

pub fn parser(input: []const u8, allocator: std.mem.Allocator) !ParserResult {
    var ret = ParserResult.init(allocator);

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        const clean_line = std.mem.trim(u8, line, "[ \r\n\t");
        var parts = std.mem.splitSequence(u8, clean_line, ": ");
        var node_from: []const u8 = undefined;
        var nodes_to = ArrayList([]const u8){};
        var idx: usize = 0;
        while (parts.next()) |p| {
            if (idx == 0) {
                node_from = p;
                idx += 1;
            } else {
                var nodes = std.mem.splitScalar(u8, p, ' ');
                while (nodes.next()) |n| {
                    try nodes_to.append(allocator, n);
                }
            }
        }
        try ret.put(node_from, nodes_to);
    }

    return ret;
}

test "day 11 parser" {
    const input =
        \\svr: aaa bbb
        \\aaa: fft
        \\fft: ccc
        \\bbb: tty
        \\tty: ccc
        \\ccc: ddd eee
        \\ddd: hub
        \\hub: fff
        \\eee: dac
        \\dac: fff
        \\fff: ggg hhh
        \\ggg: out
        \\hhh: out
    ;
    var data = try parser(input, test_allocator);
    defer data.deinit();

    try std.testing.expectEqualStrings("ccc", (data.get("fft") orelse ArrayList([]const u8){}).items[0]);
    try std.testing.expectEqualStrings("hhh", (data.get("fff") orelse ArrayList([]const u8){}).items[1]);
}

// const Stack = struct {
//     steps: usize,
//     lights: usize,
// };

// fn lessThan(context: void, a: Stack, b: Stack) Order {
//     _ = context;
//     return std.math.order(a.steps, b.steps);
// }

// fn solve1(row: Row) !usize {
//     var stack = std.PriorityQueue(Stack, void, lessThan).init(test_allocator, {});
//     defer stack.deinit();

//     var seen = std.AutoHashMap(u64, void).init(test_allocator);
//     defer seen.deinit();

//     try stack.add(Stack{ .steps = 0, .lights = 0 });
//     try seen.put(0, {});

//     while (stack.removeOrNull()) |node| {
//         if (node.lights == row.lights) {
//             return node.steps;
//         }

//         for (row.buttons) |button| {
//             const next_lights = node.lights ^ button;
//             if (seen.get(next_lights) == null) {
//                 try seen.put(next_lights, {});
//                 try stack.add(Stack{ .steps = node.steps + 1, .lights = next_lights });
//             }
//         }
//     }
//     return 0;
// }
const Memo = std.StringHashMap(usize);

fn count_paths(graph: *ParserResult, memo: *Memo, start: []const u8, end: []const u8) !usize {
    if (std.mem.eql(u8, start, end)) {
        return 1;
    }

    const key = try std.fmt.allocPrint(test_allocator, "{s}{s}", .{ start, end });

    if (memo.get(key)) |cached| {
        return cached;
    }

    var ret: usize = 0;
    if (graph.get(start)) |nodes| {
        for (nodes.items) |n| {
            ret += try count_paths(graph, memo, n, end);
        }
    }

    try memo.put(key, ret);

    return ret;
}

pub fn part1(data: *ParserResult) !usize {
    var memo = Memo.init(test_allocator);
    defer memo.deinit();
    return try count_paths(data, &memo, "you", "out");
}

test "day 11 part 1" {
    const input = @embedFile("inputs/day11.txt");
    var data = try parser(input, test_allocator);

    const ret = try part1(&data);
    std.debug.print("Day 11 Part1: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 640), ret);
}

pub fn part2(graph: *ParserResult) !usize {
    var memo = Memo.init(test_allocator);
    defer memo.deinit();

    const p1 = try count_paths(graph, &memo, "svr", "dac");
    const p1b = try count_paths(graph, &memo, "svr", "fft");
    const p2 = try count_paths(graph, &memo, "dac", "fft");
    const p2b = try count_paths(graph, &memo, "fft", "dac");
    const p3 = try count_paths(graph, &memo, "fft", "out");
    const p3b = try count_paths(graph, &memo, "dac", "out");

    return p1 * p2 * p3 + p1b * p2b * p3b;
}

test "day 11 part 2" {
    const input = @embedFile("inputs/day11.txt");
    var data = try parser(input, test_allocator);

    const ret = try part2(&data);
    std.debug.print("Day 11 Part2: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 367579641755680), ret);
}
