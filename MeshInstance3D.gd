extends TextureRect

var arr :PackedInt32Array = PackedInt32Array()
var rd := RenderingServer.create_local_rendering_device()

var shader
var pipeline
var uniform_set
var buffer
var buffer2
var buffer3
var output_tex

const s = 1000;

func _input(event):
	if event is InputEventMouseButton:
		arr.clear()
		for i in range(s * s):
			arr.push_back(1 if randi() % 10 < 2 else 0)
		var input_bytes :PackedByteArray = PackedInt32Array([s]).to_byte_array()
		input_bytes.append_array(arr.to_byte_array())
		rd.buffer_update(buffer, 0, input_bytes.size(), input_bytes)

# Called when the node enters the scene tree for the first time.
func _ready():
	var shader_file := load("res://compute_example.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(shader)
	randomize()
	for i in range(s * s):
		arr.push_back(randi() % 2)
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
	var output_tex_uniform := RDUniform.new()
	output_tex_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	output_tex_uniform.binding = 1
	output_tex_uniform.add_id(output_tex)

	var input_bytes :PackedByteArray = PackedInt32Array([s]).to_byte_array()
	input_bytes.append_array(arr.to_byte_array())
	buffer = rd.storage_buffer_create(input_bytes.size(), input_bytes)
	buffer2 = rd.storage_buffer_create(input_bytes.size(), input_bytes)

	var kernel_bytes :PackedByteArray = PackedInt32Array([3]).to_byte_array()
	kernel_bytes.append_array( PackedInt32Array(
		[
		 1,1,1,
		 1,0,1,
		 1,1,1]).to_byte_array())
	buffer3 = rd.storage_buffer_create(kernel_bytes.size(), kernel_bytes)
	# Create a uniform to assign the buffer to the rendering device
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	uniform.binding = 0 
	uniform.add_id(buffer)
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
	arr = output_bytes.to_int32_array()
	var byte_data : PackedByteArray = rd.texture_get_data(output_tex, 0)
	var image := Image.create_from_data(s, s, false, Image.FORMAT_RGBAF, byte_data)
	texture.update(image)
