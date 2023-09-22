extends TextureRect


var rd := RenderingServer.create_local_rendering_device()

var shader
var pipeline
var uniform_set
var buffer
var buffer2
var buffer3
var output_tex

const s = 1000;
const k_radius = 13;
const k = 2 * k_radius + 1;

func _input(event):
	if event is InputEventMouseButton:
		var playfield = generate_playfield()
		rd.buffer_update(buffer, 0, playfield.size(), playfield)

func generate_kernel():
	var kernel = PackedFloat32Array();
	for i in range(k * k):
		kernel.push_back(1);
	for i in range(k):
		for j in range(k):
			var tmp : float = sqrt((float(i) - float(k_radius)) ** 2 + (float(j) - float(k_radius)) ** 2) / k_radius
			if tmp < 1.0 :
				kernel[i + j * k] = exp(-((tmp-0.5)/0.15)**2 / 2)
			else :
				kernel[i + j * k] = 0
	var kernel_sum = 0;
	for i in kernel.size():
		kernel_sum += kernel[i];
	var kernelimg = Image.create_from_data(k, k, false, Image.FORMAT_RF, kernel.to_byte_array())
	var kerneltexture = ImageTexture.create_from_image(kernelimg)
	$"Kernel_rect".texture = kerneltexture
	for i in kernel.size():
		kernel[i] /= kernel_sum;
	var kernel_bytes :PackedByteArray = PackedInt32Array([k]).to_byte_array()
	kernel_bytes.append_array(kernel.to_byte_array())
	return kernel_bytes

func generate_orbium():
	#"name":"Orbium","R":13,"T":10,"m":0.15,"s":0.015,"b":[1] widt = 20 height = 20
	var orbium = [
		0.  ,0.  ,0.  ,0.  ,0.  ,0.  ,0.1 ,0.14,0.1 ,0.  ,0.  ,0.03,0.03,0.  ,0.  ,0.3 ,0.  ,0.  ,0.  ,0.  ,
		0.  ,0.  ,0.  ,0.  ,0.  ,0.08,0.24,0.3 ,0.3 ,0.18,0.14,0.15,0.16,0.15,0.09,0.2 ,0.  ,0.  ,0.  ,0.  ,
		0.  ,0.  ,0.  ,0.  ,0.  ,0.15,0.34,0.44,0.46,0.38,0.18,0.14,0.11,0.13,0.19,0.18,0.45,0.  ,0.  ,0.  ,
		0.  ,0.  ,0.  ,0.  ,0.06,0.13,0.39,0.5 ,0.5 ,0.37,0.06,0.  ,0.  ,0.  ,0.02,0.16,0.68,0.  ,0.  ,0.  ,
		0.  ,0.  ,0.  ,0.11,0.17,0.17,0.33,0.4 ,0.38,0.28,0.14,0.  ,0.  ,0.  ,0.  ,0.  ,0.18,0.42,0.  ,0.  ,
		0.  ,0.  ,0.09,0.18,0.13,0.06,0.08,0.26,0.32,0.32,0.27,0.  ,0.  ,0.  ,0.  ,0.  ,0.  ,0.82,0.  ,0.  ,
		0.27,0.  ,0.16,0.12,0.  ,0.  ,0.  ,0.25,0.38,0.44,0.45,0.34,0.  ,0.  ,0.  ,0.  ,0.  ,0.22,0.17,0.  ,
		0.  ,0.07,0.2 ,0.02,0.  ,0.  ,0.  ,0.31,0.48,0.57,0.6 ,0.57,0.  ,0.  ,0.  ,0.  ,0.  ,0.  ,0.49,0.  ,
		0.  ,0.59,0.19,0.  ,0.  ,0.  ,0.  ,0.2 ,0.57,0.69,0.76,0.76,0.49,0.  ,0.  ,0.  ,0.  ,0.  ,0.36,0.  ,
		0.  ,0.58,0.19,0.  ,0.  ,0.  ,0.  ,0.  ,0.67,0.83,0.9 ,0.92,0.87,0.12,0.  ,0.  ,0.  ,0.  ,0.22,0.07,
		0.  ,0.  ,0.46,0.  ,0.  ,0.  ,0.  ,0.  ,0.7 ,0.93,1.  ,1.  ,1.  ,0.61,0.  ,0.  ,0.  ,0.  ,0.18,0.11,
		0.  ,0.  ,0.82,0.  ,0.  ,0.  ,0.  ,0.  ,0.47,1.  ,1.  ,0.98,1.  ,0.96,0.27,0.  ,0.  ,0.  ,0.19,0.1 ,
		0.  ,0.  ,0.46,0.  ,0.  ,0.  ,0.  ,0.  ,0.25,1.  ,1.  ,0.84,0.92,0.97,0.54,0.14,0.04,0.1 ,0.21,0.05,
		0.  ,0.  ,0.  ,0.4 ,0.  ,0.  ,0.  ,0.  ,0.09,0.8 ,1.  ,0.82,0.8 ,0.85,0.63,0.31,0.18,0.19,0.2 ,0.01,
		0.  ,0.  ,0.  ,0.36,0.1 ,0.  ,0.  ,0.  ,0.05,0.54,0.86,0.79,0.74,0.72,0.6 ,0.39,0.28,0.24,0.13,0.  ,
		0.  ,0.  ,0.  ,0.01,0.3 ,0.07,0.  ,0.  ,0.08,0.36,0.64,0.7 ,0.64,0.6 ,0.51,0.39,0.29,0.19,0.04,0.  ,
		0.  ,0.  ,0.  ,0.  ,0.1 ,0.24,0.14,0.1 ,0.15,0.29,0.45,0.53,0.52,0.46,0.4 ,0.31,0.21,0.08,0.  ,0.  ,
		0.  ,0.  ,0.  ,0.  ,0.  ,0.08,0.21,0.21,0.22,0.29,0.36,0.39,0.37,0.33,0.26,0.18,0.09,0.  ,0.  ,0.  ,
		0.  ,0.  ,0.  ,0.  ,0.  ,0.  ,0.03,0.13,0.19,0.22,0.24,0.24,0.23,0.18,0.13,0.05,0.  ,0.  ,0.  ,0.  ,
		0.  ,0.  ,0.  ,0.  ,0.  ,0.  ,0.  ,0.  ,0.02,0.06,0.08,0.09,0.07,0.05,0.01,0.  ,0.  ,0.  ,0.  ,0.
	];
	var arr :PackedFloat32Array = PackedFloat32Array()
	for i in range(s * s):
		arr.push_back(0)
	for i in range(20):
		for j in range(20):
			arr[i + j * s] = orbium[i + j * 20];
	var input_bytes :PackedByteArray = PackedInt32Array([s]).to_byte_array()
	input_bytes.append_array(arr.to_byte_array())
	return input_bytes

func generate_playfield():
	var arr :PackedFloat32Array = PackedFloat32Array()
	for i in range(s * s):
		arr.push_back(randf())
	var input_bytes :PackedByteArray = PackedInt32Array([s]).to_byte_array()
	input_bytes.append_array(arr.to_byte_array())
	return input_bytes

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	#load and compile compute shader
	var shader_file := load("res://compute_example.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(shader)
	
	var kernel_bytes = generate_kernel()
	buffer3 = rd.storage_buffer_create(kernel_bytes.size(), kernel_bytes)
	
	#input and output buffer each have same size
	#var playfield = generate_playfield()
	var playfield = generate_orbium()
	buffer = rd.storage_buffer_create(playfield.size(), playfield)
	buffer2 = rd.storage_buffer_create(playfield.size(), playfield)
	
	#generate outputtexture so gpu can convert states to an image
	var fmt := RDTextureFormat.new()
	fmt.width = s
	fmt.height = s
	fmt.format = RenderingDevice.DATA_FORMAT_R32G32B32A32_SFLOAT
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT \
					| RenderingDevice.TEXTURE_USAGE_STORAGE_BIT \
					| RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	var view := RDTextureView.new()
	var output_image := Image.create(s, s, false, Image.FORMAT_RGBAF)
	var image_texture = ImageTexture.create_from_image(output_image)
	texture = image_texture
	output_tex = rd.texture_create(fmt, view, [output_image.get_data()])
	
	# Create uniforms to assign the buffers to the rendering device
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0 
	uniform.add_id(buffer)
	var output_tex_uniform := RDUniform.new()
	output_tex_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	output_tex_uniform.binding = 1
	output_tex_uniform.add_id(output_tex)
	var uniform2 := RDUniform.new()
	uniform2.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform2.binding = 2 
	uniform2.add_id(buffer2)
	var uniform3 := RDUniform.new()
	uniform3.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform3.binding = 3
	uniform3.add_id(buffer3)
	uniform_set = rd.uniform_set_create([uniform, output_tex_uniform, uniform2, uniform3], shader, 0)
	pass

func _process(delta):
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, s / 10, s / 10, 1)
	rd.compute_list_end()
	rd.submit()
	rd.sync()
	var output_bytes := rd.buffer_get_data(buffer2)
	rd.buffer_update(buffer, 0, output_bytes.size(), output_bytes)
	var byte_data : PackedByteArray = rd.texture_get_data(output_tex, 0)
	var image := Image.create_from_data(s, s, false, Image.FORMAT_RGBAF, byte_data)
	texture.update(image)
