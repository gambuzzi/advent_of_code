const std = @import("std");
const test_allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;

const ParserResult = struct {
    numbers: ArrayList(ArrayList(usize)),
    operators: ArrayList([]const u8),
};

pub fn parser(input: []const u8, allocator: std.mem.Allocator) !ParserResult {
    var numbers = ArrayList(ArrayList(usize)){};
    var operators = ArrayList([]const u8){};

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        const clean_line = std.mem.trim(u8, line, " \r\n\t");

        if (std.mem.indexOf(u8, line, "*") == null and std.mem.indexOf(u8, line, "+") == null) {
            var row = ArrayList(usize){};

            var nums = std.mem.splitScalar(u8, clean_line, ' ');
            while (nums.next()) |num| {
                const clean_num = std.mem.trim(u8, num, " ");
                if (clean_num.len == 0) continue;
                const val = try std.fmt.parseInt(usize, clean_num, 10);
                try row.append(allocator, val);
            }

            try numbers.append(allocator, row);
            continue;
        }

        var parts = std.mem.splitScalar(u8, clean_line, ' ');
        while (parts.next()) |op| {
            const clean_op = std.mem.trim(u8, op, " ");
            if (clean_op.len == 0) continue;
            try operators.append(allocator, clean_op);
        }
    }

    return ParserResult{
        .numbers = numbers,
        .operators = operators,
    };
}

test "day 06 parser" {
    const input =
        \\123 328  51 64
        \\ 45 64  387 23
        \\  6 98  215 314
        \\*   +   *   +  
    ;
    var data = try parser(input, test_allocator);
    defer data.numbers.deinit(test_allocator);
    defer data.operators.deinit(test_allocator);

    try std.testing.expectEqual(@as(usize, 3), data.numbers.items.len);
    try std.testing.expectEqual(@as(usize, 4), data.operators.items.len);
    try std.testing.expectEqual(@as(usize, 64), data.numbers.items[1].items[1]);
    try std.testing.expectEqual(@as(usize, 314), data.numbers.items[2].items[3]);
}

const AddMulFn = *const fn (usize, usize) usize;

const addmul: [2]AddMulFn = .{
    struct {
        fn add(a: usize, b: usize) usize {
            return a + b;
        }
    }.add,
    struct {
        fn mul(a: usize, b: usize) usize {
            return a * b;
        }
    }.mul,
};

pub fn part1(data: *ParserResult) !usize {
    var ret: usize = 0;
    var acc: usize = undefined;
    var fx: usize = undefined;
    for (data.*.operators.items, 0..) |op, i| {
        if (std.mem.eql(u8, op, "*")) {
            acc = 1;
            fx = 1;
        } else if (std.mem.eql(u8, op, "+")) {
            acc = 0;
            fx = 0;
        } else {
            return error.InvalidOperator;
        }
        for (data.*.numbers.items) |r| {
            acc = addmul[fx](acc, r.items[i]);
        }
        ret += acc;
    }
    return ret;
}

test "day 06 part 1" {
    const input = @embedFile("inputs/day06.txt");
    var data = try parser(input, test_allocator);
    defer data.numbers.deinit(test_allocator);
    defer data.operators.deinit(test_allocator);

    const ret = try part1(&data);
    std.debug.print("Day 06 Part1: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 6100348226985), ret);
}

pub fn parser2(input: []const u8, allocator: std.mem.Allocator) !ArrayList([]const u8) {
    var ret = ArrayList([]const u8){};

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        const clean_line = std.mem.trim(u8, line, "\r\n\t");
        if (clean_line.len == 0) continue;

        try ret.append(allocator, clean_line);
    }

    return ret;
}

pub fn part2(data: *ArrayList([]const u8)) !usize {
    var ret: usize = 0;
    var acc: [128]usize = undefined;

    var i_acc: usize = 0;
    var fx: usize = undefined;

    for (0..data.items[0].len) |x| {
        var num: usize = 0;
        var compute = true;
        for (0..data.items.len) |y| {
            const c = data.items[y][x];
            if (c == '*') {
                fx = 1;
            } else if (c == '+') {
                fx = 0;
            } else {
                if (c >= '0' and c <= '9') {
                    num *= 10;
                    num += @as(usize, c - '0');
                    compute = false;
                }
            }
        }
        if (compute) {
            var temp = fx;
            for (acc[0..i_acc]) |v| {
                temp = addmul[fx](temp, v);
            }
            ret += temp;
            i_acc = 0;
        } else {
            acc[i_acc] = num;
            i_acc += 1;
        }
    }

    var temp = fx;
    for (acc[0..i_acc]) |v| {
        temp = addmul[fx](temp, v);
    }
    ret += temp;

    return ret;
}

test "day 06 part 2" {
    const input = @embedFile("inputs/day06.txt");
    var data = try parser2(input, test_allocator);
    defer data.deinit(test_allocator);

    const ret = try part2(&data);
    std.debug.print("Day 06 Part2: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 12377473011151), ret);
}
