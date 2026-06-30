const std = @import("std");
const color = @import("structures.zig").color;
const vector = @import("structures.zig").vector;
const raytracer_config = @import("structures.zig").raytracer_config;
const ray = @import("structures.zig").ray;
const point = @import("structures.zig").point;

fn calculate_pixel_center(pixel_zero_location: *const vector, height: i32, width: i32, pixel_delta_u: *const vector, pixel_delta_v: *const vector) point {
    const height_f: f64 = @floatFromInt(height);
    const width_f: f64 = @floatFromInt(width);
    const scaled_pixel_delta_u = pixel_delta_u.scale_operation(width_f);
    const scaled_pixel_delta_v = pixel_delta_v.scale_operation(height_f);

    const pixel_center = pixel_zero_location.addition_operation(&scaled_pixel_delta_u).addition_operation(&scaled_pixel_delta_v);
    return point{ .elements = .{
        pixel_center.x(),
        pixel_center.y(),
        pixel_center.z(),
    } };
}
fn calculate_ray_direction(pixel_center: *const point, camera_center: *const point) vector {
    const ray_direction = pixel_center.substraction_operation(camera_center);
    return vector{ .elements = .{
        ray_direction.x(),
        ray_direction.y(),
        ray_direction.z(),
    } };
}

pub fn main(init: std.process.Init) !void {
    var stdout_writer = std.Io.File.stdout().writer(init.io, &.{});
    const stdout = &stdout_writer.interface;

    try stdout.print("{s}\n{d} {d}\n{d}\n", .{ raytracer_config.rgb_color_mode, raytracer_config.image_width, raytracer_config.image_height, raytracer_config.max_color_value });

    for (0..raytracer_config.image_height) |height| {
        std.debug.print("\rScanlines remaining:{} ", .{raytracer_config.image_height - height});
        for (0..raytracer_config.image_width) |width| {
            const pixel_center = calculate_pixel_center(&raytracer_config.pixel_zero_location, @intCast(height), @intCast(width), &raytracer_config.pixel_delta_u, &raytracer_config.pixel_delta_v);
            const ray_direction = calculate_ray_direction(&pixel_center, &raytracer_config.camera_center);
            // const ray_direction = pixel_center - raytracer_config.camera_center;
            const global_ray = ray{
                .direction = ray_direction,
                .origin = raytracer_config.camera_center,
            };

            const pixel_color = global_ray.calculate_ray_color();
            try pixel_color.output_to_stdout(stdout);
        }
    }
    std.debug.print("\rDone                            \n", .{});
}
