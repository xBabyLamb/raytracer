const std = @import("std");

pub const vector = struct {
    elements: [3]f64 = .{ 0, 0, 0 },

    pub fn x(self: *const vector) f64 {
        return self.elements[0];
    }
    pub fn y(self: *const vector) f64 {
        return self.elements[1];
    }
    pub fn z(self: *const vector) f64 {
        return self.elements[2];
    }

    pub fn inverse_operation(self: *const vector) vector {
        return vector{ .elements = .{
            -self.x(),
            -self.y(),
            -self.z(),
        } };
    }
    pub fn addition_operation(self: *const vector, addends: *const vector) vector {
        return vector{ .elements = .{
            self.x() + addends.x(),
            self.y() + addends.y(),
            self.z() + addends.z(),
        } };
    }
    pub fn substraction_operation(self: *const vector, subtrahend: *const vector) vector {
        return vector{ .elements = .{
            self.x() - subtrahend.x(),
            self.y() - subtrahend.y(),
            self.z() - subtrahend.z(),
        } };
    }
    pub fn multiplication_operation(self: *const vector, multiplier: *const vector) vector {
        return vector{ .elements = .{
            self.x() * multiplier.x(),
            self.y() * multiplier.y(),
            self.z() * multiplier.z(),
        } };
    }
    pub fn division_operation(self: *const vector, divisor: *const vector) vector {
        return vector{ .elements = .{
            self.x() / divisor.x(),
            self.y() / divisor.y(),
            self.z() / divisor.z(),
        } };
    }
    pub fn scale_operation(self: *const vector, scale: f64) vector {
        return vector{ .elements = .{
            self.x() * scale,
            self.y() * scale,
            self.z() * scale,
        } };
    }
    pub fn dot_product_operation(self: *const vector, operand: *const vector) f64 {
        return (self.x() * operand.x() +
            self.y() * operand.y() +
            self.z() * operand.z());
    }
    pub fn cross_product_operation(self: *const vector, operand: *const vector) vector {
        return vector{ .elements = .{
            self.y() * operand.z() - self.z() * operand.y(),
            self.z() * operand.x() - self.x() * operand.z(),
            self.x() * operand.y() - self.y() * operand.x(),
        } };
    }
    pub fn calculate_magnitude(self: *const vector) f64 {
        return @sqrt(self.calculate_squared_sum());
    }
    pub fn calculate_squared_sum(self: *const vector) f64 {
        return (self.x() * self.x() +
            self.y() * self.y() +
            self.z() * self.z());
    }
    pub fn calculate_unit_vector(self: *const vector) vector {
        return self.scale_operation(1.0 / self.calculate_magnitude());
    }

    pub fn print(self: *const vector) void {
        std.debug.print("The current vec3:{any}\n", .{self.elements});
    }
};

pub const point = struct {
    elements: [3]f64 = .{ 0, 0, 0 },
    pub fn x(self: *const point) f64 {
        return self.elements[0];
    }
    pub fn y(self: *const point) f64 {
        return self.elements[1];
    }
    pub fn z(self: *const point) f64 {
        return self.elements[2];
    }

    //TODO:add helper functions

    pub fn print(self: *const point) void {
        std.debug.print("The current point:{any}\n", .{self.elements});
    }
};

pub const raytracer_config = struct {
    pub const rgb_color_mode = "P3"; // ASCII
    pub const max_color_value = 255;
    pub const conversion_multiplication = 255.99;

    pub const image_width: i32 = 400;
    pub const image_height: i32 = @max(@as(f64, @floatFromInt(image_width)) / aspect_ratio, 1);

    pub const aspect_ratio: f64 = 16.0 / 9.0;

    pub const viewport_height: f64 = 2.0;
    pub const viewport_width: f64 = viewport_height * (@as(f64, @floatFromInt(image_width)) / image_height);

    pub const focal_length = 1.0;
    pub const camera_center: point = .{ .elements = .{ 0, 0, 0 } };

    // Calculate the vectors across the horizontal and down the vertical viewport edges.
    pub const viewport_u: vector = .{ .elements = .{ viewport_width, 0, 0 } };
    pub const viewport_v: vector = .{ .elements = .{ 0, -viewport_height, 0 } };

    // Calculate the horizontal and vertical delta vectors from pixel to pixel.
    pub const pixel_delta_u = viewport_u.scale_operation(1.0 / @as(f64, @floatFromInt(image_width)));
    pub const pixel_delta_v = viewport_v.scale_operation(1.0 / @as(f64, @floatFromInt(image_height)));

    // Calculate the location of the upper left pixel.
    pub const viewport_upper_left = calculate_viewport_upper_left(&camera_center, &vector{ .elements = .{ 0, 0, focal_length } }, &viewport_u, &viewport_v);
    pub const pixel_zero_location = calculate_pixel_zero_location(&viewport_upper_left, 0.5, &pixel_delta_u, &pixel_delta_v);
};

pub const color = struct {
    elements: [3]f64 = .{ 0, 0, 0 },

    pub fn x(self: *const color) f64 {
        return self.elements[0];
    }
    pub fn y(self: *const color) f64 {
        return self.elements[1];
    }
    pub fn z(self: *const color) f64 {
        return self.elements[2];
    }

    //TODO:add helper functions
    pub fn output_to_stdout(self: *const color, stdout: *std.Io.Writer) !void {
        const r = self.x();
        const g = self.y();
        const b = self.z();

        const ir: i32 = @intFromFloat(raytracer_config.conversion_multiplication * r);
        const ig: i32 = @intFromFloat(raytracer_config.conversion_multiplication * g);
        const ib: i32 = @intFromFloat(raytracer_config.conversion_multiplication * b);

        try stdout.print("{} {} {}\n", .{ ir, ig, ib });
    }

    pub fn print(self: *const color) void {
        std.debug.print("The current point:{any}\n", .{self.elements});
    }
};

pub const ray = struct {
    origin: point = undefined,
    direction: vector = undefined,
    // color: color = .{ .elements = .{ 0, 0, 0 } },

    pub fn point_at(self: *const ray, time: f64) point {
        const scaled_direction = self.direction.scale_operation(time);

        return point{ .elements = .{
            self.origin.x() + scaled_direction.x(),
            self.origin.y() + scaled_direction.y(),
            self.origin.z() + scaled_direction.z(),
        } };
    }
    pub fn calculate_ray_color(self: *const ray) color {
        const unit_direction = self.direction.calculate_unit_vector();
        const a = 0.5 * (unit_direction.y() + 1.0);

        const white = color{ .elements = .{ 1.0, 1.0, 1.0 } };
        const blue = color{ .elements = .{ 0.5, 0.7, 1.0 } };

        return color{ .elements = .{
            ((1.0 - a) * white.x()) + (a * blue.x()),
            ((1.0 - a) * white.y()) + (a * blue.y()),
            ((1.0 - a) * white.z()) + (a * blue.z()),
        } };
    }
};

//FIXME:add better to way handle this two operations
fn calculate_viewport_upper_left(camera_center: *const point, focal_vector: *const vector, viewport_u: *const vector, viewport_v: *const vector) vector {
    return vector{ .elements = .{
        camera_center.x() - focal_vector.x() - (viewport_u.x() / 2) - (viewport_v.x() / 2),
        camera_center.y() - focal_vector.y() - (viewport_u.y() / 2) - (viewport_v.y() / 2),
        camera_center.z() - focal_vector.z() - (viewport_u.z() / 2) - (viewport_v.z() / 2),
    } };
}

// pub const pixel_zero_location = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v);
fn calculate_pixel_zero_location(viewport_upper_left: *const vector, mult: f64, pixel_delta_u: *const vector, pixel_delta_v: *const vector) vector {
    return vector{ .elements = .{
        viewport_upper_left.x() + mult * (pixel_delta_u.x() + pixel_delta_v.x()),
        viewport_upper_left.y() + mult * (pixel_delta_u.y() + pixel_delta_v.y()),
        viewport_upper_left.z() + mult * (pixel_delta_u.z() + pixel_delta_v.z()),
    } };
}
