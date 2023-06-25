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

fn swap_int32(a: *i32, b: *i32) void {
    const t = a.*;
    a.* = b.*;
    b.* = t;
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

            const u: f32 = @floatFromInt(f32, x) / cols;
            const v: f32 = @floatFromInt(f32, y) / rows;
            const t: f32 = (u + v) / 2;
            const r = lerp(radius / 4, radius, t);

            m.fill_circle(&pixels, WIDTH, HEIGHT, @intCast(i32, (x * c_w) + c_w / 2), @intCast(i32, (y * c_h) + c_h / 2), @intFromFloat(u32, r), color);
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

            m.fill_rect(&pixels, WIDTH, HEIGHT, @intCast(i32, x * c_w), @intCast(i32, y * c_h), c_w, c_h, color);
        }
    }

    try m.save_to_ppm_file(alloc, &pixels, WIDTH, HEIGHT, "checker.ppm");
}
