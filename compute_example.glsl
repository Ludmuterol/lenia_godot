#[compute]

#version 450

layout(local_size_x = 10, local_size_y = 10, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer MyDataBuffer {
	int data[];
} my_data_buffer;

layout(set = 0, binding = 2, std430) restrict buffer MyDataBuffer2 {
	int data[];
} out_data_buffer;

layout(set = 0, binding = 1, rgba32f) uniform image2D OUTPUT_TEXTURE;

const int s = 1000;

void main() {
	uint pos = gl_GlobalInvocationID.x + gl_GlobalInvocationID.y * s;
	int sum = 0;
	if (gl_GlobalInvocationID.x > 0) {
		sum += my_data_buffer.data[pos - 1];
	}
	if (gl_GlobalInvocationID.x < s) {
		sum += my_data_buffer.data[pos + 1];
	}
	if (gl_GlobalInvocationID.x > 0 && gl_GlobalInvocationID.y < s) {
		sum += my_data_buffer.data[pos + s -1];
	}
	if (gl_GlobalInvocationID.y < s) {
		sum += my_data_buffer.data[pos + s];
	}
	if (gl_GlobalInvocationID.x < s && gl_GlobalInvocationID.y < s) {
		sum += my_data_buffer.data[pos + s + 1];
	}
	if (gl_GlobalInvocationID.x > 0 && gl_GlobalInvocationID.y > 0) {
		sum += my_data_buffer.data[pos - s - 1];
	}
	if (gl_GlobalInvocationID.y > 0) {
		sum += my_data_buffer.data[pos - s];
	}
	if (gl_GlobalInvocationID.x < s && gl_GlobalInvocationID.y > 0) {
		sum += my_data_buffer.data[pos - s + 1];
	}
	if ((my_data_buffer.data[pos] == 0 && sum == 3)||(my_data_buffer.data[pos] == 1 && (sum == 3 || sum == 4))) {
		out_data_buffer.data[pos] = 1;
	} else {
		out_data_buffer.data[pos] = 0;
	}
	vec4 pixel = vec4(1.0, 1.0, 1.0, 1.0);
	pixel.xyz = vec3(float(out_data_buffer.data[pos]));
	imageStore(OUTPUT_TEXTURE, ivec2(gl_GlobalInvocationID.xy), pixel);
}
