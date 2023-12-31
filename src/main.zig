const std = @import("std");

const m = @import("mod");

const WIDTH: u32 = 600;
const HEIGHT: u32 = 800;
const BACKGROUND_COLOR: u32 = 0xFF202020;

// for checker examples
const cols = (WIDTH / 100) * 2;
const rows = (HEIGHT / 100) * 2;
const c_w = WIDTH / cols;
const c_h = HEIGHT / rows;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();

    try lines_example(alloc);
}

fn lerp(y0: f32, y1: f32, x: f32) f32 {
    // for valuues x: 0..1
    return y0 + (y1 - y0) * x;
}

pub fn fill_triangle(pixels: [*]u32, p_w: u32, p_h: u32, x1: i32, y1: i32, x2: i32, y2: i32, x3: i32, y3: i32, color: u32) void {
    _ = color;
    _ = y3;
    _ = x3;
    _ = y2;
    _ = x2;
    _ = y1;
    _ = x1;
    _ = p_h;
    _ = p_w;
    _ = pixels;
}

fn lines_example(alloc: std.mem.Allocator) !void {
    var pixels: [WIDTH * HEIGHT]u32 = undefined;

    const length = pixels.len;

    std.debug.print("{} Pixels allocated\n", .{length});

    m.fill(&pixels, WIDTH, HEIGHT, BACKGROUND_COLOR);
    m.draw_line(&pixels, WIDTH, HEIGHT, 0, 0, WIDTH, HEIGHT, 0xFF2020FF);
    m.draw_line(&pixels, WIDTH, HEIGHT, 50, HEIGHT / 2, WIDTH / 2, 0, 0xFFFF2020);
    m.draw_line(&pixels, WIDTH, HEIGHT, WIDTH, 0, 0, HEIGHT, 0xFF20FF20);
    m.draw_line(&pixels, WIDTH, HEIGHT, 0, HEIGHT / 2, WIDTH, HEIGHT / 2, 0xFF20FFFF);
    m.draw_line(&pixels, WIDTH, HEIGHT, WIDTH / 2, 0, WIDTH / 2, HEIGHT, 0xFFFFFF20);

    try m.save_to_ppm_file(alloc, &pixels, WIDTH, HEIGHT, "lines.ppm");
}

fn circle_checker(alloc: std.mem.Allocator) !void {
    var pixels: [WIDTH * HEIGHT]u32 = undefined;

    const length = pixels.len;

    std.debug.print("{} Pixels allocated\n", .{length});

    m.fill(&pixels, WIDTH, HEIGHT, BACKGROUND_COLOR);

    for (0..rows) |y| {
        for (0..cols) |x| {
            var color: u32 = 0xFF0000FF;
            var radius: f32 = c_w / 2;
            if (c_h > c_w) {
                radius = c_h / 2;
            }

            const u: f32 = @as(f32, @floatFromInt(x)) / cols;
            const v: f32 = @as(f32, @floatFromInt(y)) / rows;
            const t: f32 = (u + v) / 2;
            const r = lerp(radius / 4, radius, t);

            m.fill_circle(&pixels, WIDTH, HEIGHT, @as(i32, @intCast((x * c_w) + c_w / 2)), @as(i32, @intCast((y * c_h) + c_h / 2)), @as(u32, @intFromFloat(r)), color);
        }
    }

    try m.save_to_ppm_file(alloc, &pixels, WIDTH, HEIGHT, "cirlce_checker.ppm");
}

fn japan(alloc: std.mem.Allocator) !void {
    var pixels: [WIDTH * HEIGHT]u32 = undefined;

    const length = pixels.len;

    std.debug.print("{} Pixels allocated\n", .{length});

    m.fill(&pixels, WIDTH, HEIGHT, 0xFFFFFFFF);
    // All values as per wikipedia description of japan flag specification
    m.fill_circle(&pixels, WIDTH, HEIGHT, WIDTH / 2, HEIGHT / 2, (3 * HEIGHT) / 10, 0xFF2D00BC);

    try m.save_to_ppm_file(alloc, &pixels, WIDTH, HEIGHT, "japan.ppm");
}

fn circle_example(alloc: std.mem.Allocator) !void {
    var pixels: [WIDTH * HEIGHT]u32 = undefined;

    const length = pixels.len;

    std.debug.print("{} Pixels allocated\n", .{length});

    m.fill(&pixels, WIDTH, HEIGHT, BACKGROUND_COLOR);
    m.fill_circle(&pixels, WIDTH, HEIGHT, 50, 40, 30, 0xFF2020FF);

    try m.save_to_ppm_file(alloc, &pixels, WIDTH, HEIGHT, "circle.ppm");
}

fn checker_example(alloc: std.mem.Allocator) !void {
    var pixels: [WIDTH * HEIGHT]u32 = undefined;

    const length = pixels.len;

    std.debug.print("{} Pixels allocated\n", .{length});

    m.fill(&pixels, WIDTH, HEIGHT, BACKGROUND_COLOR);

    for (0..rows) |y| {
        for (0..cols) |x| {
            var color: u32 = BACKGROUND_COLOR;
            if ((x + y) % 2 == 0) {
                color = 0xFF0000FF;
            }

            m.fill_rect(&pixels, WIDTH, HEIGHT, @as(i32, @intCast(x * c_w)), @as(i32, @intCast(y * c_h)), c_w, c_h, color);
        }
    }

    try m.save_to_ppm_file(alloc, &pixels, WIDTH, HEIGHT, "checker.ppm");
}
