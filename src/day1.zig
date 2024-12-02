const std = @import("std");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const argv = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, argv);

    if (argv.len < 2) {
        std.debug.panic("pass day1 txt", .{});
    }

    var file = try std.fs.cwd().openFile(argv[1], .{});
    defer file.close();

    var left = std.ArrayList(i64).init(allocator);
    defer left.deinit();
    var right = std.ArrayList(i64).init(allocator);
    defer right.deinit();

    var buf_reader = std.io.bufferedReader(file.reader());
    var reader = buf_reader.reader();

    while (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024)) |line| {
        defer allocator.free(line);

        var it = std.mem.splitSequence(u8, line, "   ");

        try left.append(try std.fmt.parseInt(i64, it.first(), 10));
        try right.append(try std.fmt.parseInt(i64, it.next().?, 10));
    }

    std.mem.sort(i64, left.items, {}, std.sort.asc(i64));

    std.mem.sort(i64, right.items, {}, std.sort.asc(i64));

    var id_count = std.AutoHashMap(i64, u64).init(allocator);
    defer id_count.deinit();

    for (right.items) |id| {
        try id_count.put(id, (id_count.get(id) orelse 0) + 1);
    }

    var part1: u64 = 0;

    for (0..right.items.len) |i| {
        part1 += @abs(left.items[i] - right.items[i]);
    }

    std.debug.print("part 1: {any}\n", .{part1});

    var part2: u64 = 0;

    for (left.items) |id| {
        part2 += @as(u64, @intCast(id)) * (id_count.get(id) orelse 0);
    }

    std.debug.print("part 2: {any}\n", .{part2});
}
