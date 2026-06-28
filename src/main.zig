const std = @import("std");
const color = @import("structures.zig").color;
const vector = @import("structures.zig").vector;
const raytracer_config = @import("structures.zig").raytracer_config;
const ray = @import("structures.zig").ray;
const point = @import("structures.zig").point;

//FIXME:add better way to handle this 2 operations
fn calculate_pixel_center(pixel_zero_location: *const vector, height: i32, width: i32, pixel_delta_u: *const vector, pixel_delta_v: *const vector) point {
    return point{ .elements = .{
        pixel_zero_location.x() + (width * pixel_delta_u.x()) + (height * pixel_delta_v.x()),
        pixel_zero_location.y() + (width * pixel_delta_u.y()) + (height * pixel_delta_v.y()),
        pixel_zero_location.z() + (width * pixel_delta_u.z()) + (height * pixel_delta_v.z()),
    } };
}
fn calculate_ray_direction(pixel_center: *const point, camera_center: *const point) vector {
    return vector{ .elements = .{
        pixel_center.x() - camera_center.x(),
        pixel_center.y() - camera_center.y(),
        pixel_center.z() - camera_center.z(),
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
    std.debug.print("VAlue is {}\n", .{raytracer_config.image_height});
}
