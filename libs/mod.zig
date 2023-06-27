const std = @import("std");
const fmt = std.fmt;

pub fn do_something() void {
    std.debug.print("Succesfully Running a program YAY!\n", .{});
}

pub fn fill(pixels: [*]u32, w: u32, h: u32, color: u32) void {
    for (0..w * h) |p| {
        pixels[p] = color;
    }
}

pub fn save_to_ppm_file(allocator: std.mem.Allocator, pixels: [*]u32, w: u32, h: u32, name: []const u8) !void {
    std.debug.print("Finished computing\n", .{});
    // throw error if fails
    const file = try std.fs.cwd().createFile(name, .{ .read = true });
    // push closing to end of function
    defer file.close();
    const writer = file.writer();

    var bw: usize = 0;

    const header = try fmt.allocPrint(allocator, "P6\n{} {} 255\n", .{ w, h });
    defer allocator.free(header);
    bw += try writer.write(header);

    for (0..w * h) |p| {
        //0xAABBGGRR
        const pixel = pixels[p];
        const bytes = [3]u8{
            @as(u8, @truncate((pixel >> 0) & 0xFF)),
            @as(u8, @truncate((pixel >> 8) & 0xFF)),
            @as(u8, @truncate((pixel >> 16) & 0xFF)),
        };
        bw += try writer.write(&bytes);
    }

    std.debug.print("Bytes writen: {}\n", .{bw});
}

pub fn fill_rect(pixels: [*]u32, p_w: u32, p_h: u32, x0: i32, y0: i32, w: u32, h: u32, color: u32) void {
    for (0..h) |dy| {
        const y = y0 + @as(i32, @intCast(dy));
        if (0 <= y and y < p_h) {
            for (0..w) |dx| {
                const x = x0 + @as(i32, @intCast(dx));
                if (0 <= x and x < p_w) {
                    pixels[@as(u32, @intCast(y)) * p_w + @as(u32, @intCast(x))] = color;
                }
            }
        }
    }
}

pub fn fill_circle(pixels: [*]u32, p_w: u32, p_h: u32, cx: i32, cy: i32, r: u32, color: u32) void {
    const x1 = cx - @as(i32, @intCast(r));
    const x2 = cx + @as(i32, @intCast(r));
    const y1 = cy - @as(i32, @intCast(r));
    const y2 = cy + @as(i32, @intCast(r));

    var y = y1;
    while (y <= y2) : (y += 1) {
        if (0 <= y and y < p_h) {
            var x = x1;
            while (x <= x2) : (x += 1) {
                if (0 <= x and x < p_w) {
                    const dx = x - cx;
                    const dy = y - cy;
                    if (dx * dx + dy * dy <= r * r) {
                        pixels[@as(u32, @intCast(y)) * p_w + @as(u32, @intCast(x))] = color;
                    }
                }
            }
        }
    }
}

pub fn draw_line_og(pixels: [*]u32, p_w: u32, p_h: u32, x1: i32, y1: i32, x2: i32, y2: i32, color: u32) void {
    // Pretty weird line drawing algo
    // considering switching to :
    // https://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm

    const dx = x2 - x1;
    const dy = y2 - y1;
    if (dx != 0) {
        // non-vertical case
        const c = y1 - @divTrunc(dy * x1, dx);

        const xl = if (x1 < x2) x1 else x2;
        const xh = if (x1 < x2) x2 else x1;

        var x = xl;
        while (x < xh) : (x += 1) {
            if (0 <= x and x < p_w) {
                const sy1 = @divTrunc((dy * x), dx) + c;
                const sy2 = @divTrunc((dy * (x + 1)), dx) + c;

                const yl = if (sy1 < sy2) sy1 else sy2;
                const yh = if (sy1 < sy2) sy2 else sy1;

                var y = yl;
                while (y <= yh) : (y += 1) {
                    if (0 <= y and y < p_h) {
                        pixels[@as(u32, @intCast(y)) * p_w + @as(u32, @intCast(x))] = color;
                    }
                }
            }
        }
    } else {
        // vertical case
        const x = x1;
        if (0 <= x and x < p_w) {
            const yl = if (y1 < y2) y1 else y2;
            const yh = if (y1 < y2) y2 else y1;

            var y = yl;
            while (y <= yh) : (y += 1) {
                if (0 <= y and y < p_h) {
                    pixels[@as(u32, @intCast(y)) * p_w + @as(u32, @intCast(x))] = color;
                }
            }
        }
    }
}

pub fn draw_line(pixels: [*]u32, p_w: u32, p_h: u32, x1: i32, y1: i32, x2: i32, y2: i32, color: u32) !void {
    _ = p_h;

    const dx = try std.math.absInt(x2 - x1);
    const sx: i32 = if (x1 < x2) 1 else -1;

    const dy = -try std.math.absInt(y2 - y1);
    const sy: i32 = if (y1 < y2) 1 else -1;

    var e1 = dx + dy;
    var x = x1;
    var y = y1;

    std.debug.print("\nValues:\ndx: {}\nsx: {}\ndy: {}\nsy: {}\ne1: {}\n", .{ dx, sx, dy, sy, e1 });

    while (true) {
        pixels[@as(u32, @intCast(y)) * p_w + @as(u32, @intCast(x))] = color;
        if (x == x1 and y == y2) break;
        const e2 = 2 * e1;
        if (e2 >= dy) {
            if (x == x2) break;
            e1 += dy;
            x += sx;
        }
        if (e2 <= dx) {
            if (y == y2) break;
            e1 += dx;
            y += sy;
        }
    }
}
