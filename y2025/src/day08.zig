const std = @import("std");
const test_allocator = std.heap.page_allocator;
const ArrayList = std.ArrayList;

const XYZ = struct {
    x: usize,
    y: usize,
    z: usize,
};

const Circuit = std.AutoHashMap(XYZ, bool);

const ParserResult = ArrayList(XYZ);

const Dist = struct {
    dist: usize,
    p1: XYZ,
    p2: XYZ,
};

fn abs_diff(a: usize, b: usize) usize {
    if (a > b) {
        return a - b;
    } else {
        return b - a;
    }
}

pub fn parser(input: []const u8, allocator: std.mem.Allocator) !ParserResult {
    var ret = ParserResult{};

    var it = std.mem.tokenizeAny(u8, input, "\n");
    while (it.next()) |line| {
        const clean_line = std.mem.trim(u8, line, " \r\n\t");

        var xyz: [3]usize = undefined;
        var point = std.mem.tokenizeAny(u8, clean_line, ",");
        var idx: usize = 0;
        while (point.next()) |num_str| {
            const num = try std.fmt.parseInt(usize, num_str, 10);
            xyz[idx] = num;
            idx += 1;
        }
        try ret.append(allocator, XYZ{
            .x = xyz[0],
            .y = xyz[1],
            .z = xyz[2],
        });
    }

    return ret;
}

pub fn part1(data: *ParserResult) !usize {
    var dist = try test_allocator.alloc(Dist, data.*.items.len * data.*.items.len / 2);
    defer test_allocator.free(dist);

    var dist_len: usize = 0;
    for (data.*.items, 0..) |p1, idx| {
        for (data.*.items[(idx + 1)..]) |p2| {
            dist[dist_len] = Dist{
                .dist = abs_diff(p1.x, p2.x) * abs_diff(p1.x, p2.x) + abs_diff(p1.y, p2.y) * abs_diff(p1.y, p2.y) + abs_diff(p1.z, p2.z) * abs_diff(p1.z, p2.z),
                .p1 = p1,
                .p2 = p2,
            };
            dist_len += 1;
        }
    }

    std.mem.sort(Dist, dist[0..dist_len], {}, struct {
        fn lessThan(_: void, a: Dist, b: Dist) bool {
            return a.dist < b.dist;
        }
    }.lessThan);

    var circuits = try test_allocator.alloc(Circuit, data.*.items.len);
    defer test_allocator.free(circuits);
    for (circuits) |*c| {
        c.* = Circuit.init(test_allocator);
    }
    defer for (circuits) |*c| {
        c.deinit();
    };
    for (data.*.items, 0..) |p, idx| {
        try circuits[idx].put(p, true);
    }

    for (dist[0..1000]) |d| {
        const p1 = d.p1;
        const p2 = d.p2;
        const ip1 = find(circuits, p1);
        const ip2 = find(circuits, p2);
        if (ip1 != ip2) {
            try circuits[ip1].ensureTotalCapacity(circuits[ip1].count() + circuits[ip2].count());
            var it = circuits[ip2].iterator();
            while (it.next()) |entry| {
                circuits[ip1].putAssumeCapacityNoClobber(entry.key_ptr.*, true);
            }
            circuits[ip2].clearRetainingCapacity();
        }
    }

    var largest: [3]usize = .{ 0, 0, 0 };
    for (circuits) |c| {
        const count = c.count();
        if (count > largest[0]) {
            largest[2] = largest[1];
            largest[1] = largest[0];
            largest[0] = count;
        } else if (count > largest[1]) {
            largest[2] = largest[1];
            largest[1] = count;
        } else if (count > largest[2]) {
            largest[2] = count;
        }
    }

    return largest[0] * largest[1] * largest[2];
}

test "day 08 part 1" {
    const input = @embedFile("inputs/day08.txt");
    var data = try parser(input, test_allocator);

    const ret = try part1(&data);
    std.debug.print("Day 08 Part1: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 24360), ret);
}

fn find(circuits: []Circuit, p: XYZ) usize {
    for (circuits, 0..) |c, idx| {
        if (c.contains(p)) {
            return idx;
        }
    }
    return 0;
}

pub fn part2(data: *ParserResult) !usize {
    var ret: usize = 0;

    var dist = try test_allocator.alloc(Dist, data.*.items.len * data.*.items.len / 2);
    defer test_allocator.free(dist);

    var dist_len: usize = 0;
    for (data.*.items, 0..) |p1, idx| {
        for (data.*.items[(idx + 1)..]) |p2| {
            dist[dist_len] = Dist{
                .dist = abs_diff(p1.x, p2.x) * abs_diff(p1.x, p2.x) + abs_diff(p1.y, p2.y) * abs_diff(p1.y, p2.y) + abs_diff(p1.z, p2.z) * abs_diff(p1.z, p2.z),
                .p1 = p1,
                .p2 = p2,
            };
            dist_len += 1;
        }
    }

    std.mem.sort(Dist, dist[0..dist_len], {}, struct {
        fn lessThan(_: void, a: Dist, b: Dist) bool {
            return a.dist < b.dist;
        }
    }.lessThan);

    var circuits = try test_allocator.alloc(Circuit, data.*.items.len);
    defer test_allocator.free(circuits);
    for (circuits) |*c| {
        c.* = Circuit.init(test_allocator);
    }
    defer for (circuits) |*c| {
        c.deinit();
    };
    for (data.*.items, 0..) |p, idx| {
        try circuits[idx].put(p, true);
    }

    for (dist[0..dist_len]) |d| {
        const p1 = d.p1;
        const p2 = d.p2;
        const ip1 = find(circuits, p1);
        const ip2 = find(circuits, p2);
        if (ip1 != ip2) {
            try circuits[ip1].ensureTotalCapacity(circuits[ip1].count() + circuits[ip2].count());
            var it = circuits[ip2].iterator();
            while (it.next()) |entry| {
                circuits[ip1].putAssumeCapacityNoClobber(entry.key_ptr.*, true);
            }
            circuits[ip2].clearRetainingCapacity();
        }
        ret = p1.x * p2.x;
        if (circuits[ip1].count() == data.*.items.len) {
            break;
        }
    }

    return ret;
}

test "day 08 part 2" {
    const input = @embedFile("inputs/day08.txt");
    var data = try parser(input, test_allocator);
    // defer test_allocator.free(data);

    const ret = try part2(&data);
    std.debug.print("Day 08 Part2: {d}\n", .{ret});
    try std.testing.expectEqual(@as(usize, 2185817796), ret);
}
