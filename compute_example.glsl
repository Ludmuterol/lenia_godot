#[compute]

#version 450

layout(local_size_x = 10, local_size_y = 10, local_size_z = 1) in;

layout(set = 0, binding = 0, std430) restrict buffer MyDataBuffer {
	int size;
	float data[];
} my_data_buffer;

layout(set = 0, binding = 1, rgba32f) uniform image2D OUTPUT_TEXTURE;


layout(set = 0, binding = 2, std430) restrict buffer MyDataBuffer2 {
	int size;
	float data[];
} out_data_buffer;

layout(set = 0, binding = 3, std430) restrict buffer MyDataBuffer3 {
	int size;
	float data[];
} kernel_buffer;

float growth(float U) {
	float m = 0.15;
	float s = 0.015;
	return (exp(-pow((U-m)/s, 2.0) / 2.0) * 2.0 - 1.0);
}

const float frequency = 1.0/10.0;

void main() {
	uint pos = gl_GlobalInvocationID.x + gl_GlobalInvocationID.y * my_data_buffer.size;
	float sum = 0;
	for (int i = 0; i < kernel_buffer.size; i++) {
		int tmp_kernel_pos_x = int(gl_GlobalInvocationID.x) + i - kernel_buffer.size / 2;
		tmp_kernel_pos_x = tmp_kernel_pos_x - my_data_buffer.size * int(tmp_kernel_pos_x >= my_data_buffer.size) + my_data_buffer.size * int(tmp_kernel_pos_x < 0);
		for (int j = 0; j < kernel_buffer.size; j++) {
			int tmp_kernel_pos_y = int(gl_GlobalInvocationID.y) + j - kernel_buffer.size / 2;
			tmp_kernel_pos_y = tmp_kernel_pos_y - my_data_buffer.size * int(tmp_kernel_pos_y >= my_data_buffer.size) + my_data_buffer.size * int(tmp_kernel_pos_y < 0);
			int tmp_kernel_pos = tmp_kernel_pos_x + tmp_kernel_pos_y * my_data_buffer.size;
			sum += my_data_buffer.data[tmp_kernel_pos] * kernel_buffer.data[i + kernel_buffer.size * j];
		}
	}
	out_data_buffer.data[pos] = clamp(my_data_buffer.data[pos] + frequency * growth(sum), 0.0, 1.0);
	vec4 pixel = vec4(1.0, 1.0, 1.0, 1.0);
	pixel.xyz = vec3(out_data_buffer.data[pos]);
	imageStore(OUTPUT_TEXTURE, ivec2(gl_GlobalInvocationID.xy), pixel);
}
