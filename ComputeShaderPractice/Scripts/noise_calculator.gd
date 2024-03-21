extends Node

#The size of the "world" we are calculating
const WORLD_SIZE: int = 100000000

#The number of shader groups we will be executing (determined in the shader code itself)
const SHADER_GROUPS: int = 32

#Shader location
const SHADER_LOCATION: String = "res://Assets/Shaders/noise_generator.glsl"

#Constant uniform data
const STRETCH_CONSTANT4: float = -0.138197
const SQUISH_CONSTANT4: float = 0.309017
const LACUNARITY: float = 2.2
const PERSISTENCE: float = 0.6
#These values would be set by the user in an application scenario
var constants_data: PackedFloat32Array = PackedFloat32Array([STRETCH_CONSTANT4, SQUISH_CONSTANT4, LACUNARITY, PERSISTENCE])
const NORM_CONSTANT4: int = 30
const OCTAVES: int = 3
const PERIOD: int = 25
#These values would also be set by the user in an application setting
var int_constants_data: PackedInt32Array = PackedInt32Array([NORM_CONSTANT4, OCTAVES, PERIOD])
var gradients_data: PackedInt32Array = PackedInt32Array([
	3, 1, 1, 1, 1, 3, 1, 1, 1, 1, 3, 1, 1, 1, 1, 3, 
	-3, 1, 1, 1, -1, 3, 1, 1, -1, 1, 3, 1, -1, 1, 1, 3, 
	3, -1, 1, 1, 1, -3, 1, 1, 1, -1, 3, 1, 1, -1, 1, 3, 
	-3, -1, 1, 1, -1, -3, 1, 1, -1, -1, 3, 1, -1, -1, 1, 3, 
	3, 1, -1, 1, 1, 3, -1, 1, 1, 1, 3, -1, 1, 1, -1, 3, 
	-3, 1, -1, 1, -1, 3, -1, 1, -1, 1, 3, -1, -1, 1, -1, 3, 
	3, -1, -1, 1, 1, -3, -1, 1, 1, -1, 3, -1, 1, -1, -1, 3, 
	-3, -1, -1, 1, -1, -3, -1, 1, -1, -1, 3, -1, -1, -1, 1, 3, 
	3, 1, 1, -1, 1, 3, 1, -1, 1, 1, 3, 1, -1, 1, -1, 3, 
	-3, 1, 1, -1, -1, 3, 1, -1, -1, 1, 3, 1, -1, -1, -1, 3, 
	3, -1, 1, -1, 1, -3, 1, -1, 1, -1, 3, 1, -1, -1, -1, 3, 
	-3, -1, 1, -1, -1, -3, 1, -1, -1, -1, 3, 1, -1, -1, -1, 3, 
	3, 1, -1, -1, 1, 3, -1, -1, 1, 1, 3, -1, -1, 1, -1, 3, 
	-3, 1, -1, -1, -1, 3, -1, -1, -1, 1, 3, -1, -1, -1, -1, 3, 
	3, -1, -1, -1, 1, -3, -1, -1, 1, -1, 3, -1, -1, -1, -1, 3, 
	-3, -1, -1, -1, -1, -3, -1, -1, -1, -1, 3, -1, -1, -1, -1, 3
])

#Shader variables
var rd: RenderingDevice
var shader: RID

#Uniform variables
var input_uniform: RDUniform
var input_buffer: RID
var output_uniform: RDUniform
var output_buffer: RID
var constants_uniform: RDUniform
var constants_buffer: RID
var int_constants_uniform: RDUniform
var int_constants_buffer: RID
var gradients_uniform: RDUniform
var gradients_buffer: RID
var perm_uniform: RDUniform
var perm_buffer: RID
var uniform_set: RID

#Timing variables
var start_time: int
var end_time: int

#Array to hold the results
var result: PackedFloat32Array

#Dictionary to store the results
var dict: Dictionary = {}

func _ready() -> void:
	#Start by creating and preparing the compute shader
	prepare_shader()
	#Then we create the compute pipeline
	create_compute_pipeline()
	#Execute the shader
	execute_shader()
	#Retrieve and print results
	get_results()
	#Store the values in a dictionary
	store_results()

func store_results() -> void:
	var input_result_bytes := rd.buffer_get_data(input_buffer)
	var input_result = input_result_bytes.to_int32_array()
	start_time = Time.get_ticks_msec()
	for num in range(WORLD_SIZE*2): #We do the world size * 2 in order to get double coordinates
		if num % 2 == 0:
			dict[Vector2(input_result[num], input_result[num + 1])] = result[num / 2]
	end_time = Time.get_ticks_msec()
	var time_value = end_time - start_time
	print("Took ", time_value, " milliseconds to store the result values")

func get_results() -> void:
	var result_bytes := rd.buffer_get_data(output_buffer)
	result = result_bytes.to_float32_array()
	var time_value = end_time - start_time
	print("Took ", time_value, " milliseconds to run the code for the whole world (100,000,000 tiles) with the shader")

func execute_shader() -> void:
	start_time = Time.get_ticks_msec()
	rd.submit()
	rd.sync()
	end_time = Time.get_ticks_msec()

func create_compute_pipeline() -> void:
	#Create a compute pipeline
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	# Dispatch the compute shader, dividing the number of computations between the number of dispatched groups
	rd.compute_list_dispatch(compute_list, (ceil(WORLD_SIZE/SHADER_GROUPS)), 1, 1)
	rd.compute_list_end()

func prepare_shader() -> void:
	#Create a local rendering device
	rd = RenderingServer.create_local_rendering_device()
	#Load the GLSL shader
	var shader_file := load(SHADER_LOCATION)
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	#Now we prepare our input, output, and uniform data
	prepare_uniforms()
	#Attach all the bindings
	set_bindings()

func set_bindings() -> void:
	#Add all the bindings to an array
	var bindings: Array[RDUniform] = [
		input_uniform, 
		output_uniform, 
		constants_uniform, 
		int_constants_uniform, 
		gradients_uniform, 
		perm_uniform
	]
	uniform_set = rd.uniform_set_create(bindings, shader, 0)

func prepare_uniforms() -> void:
	prepare_input_data()
	prepare_output_data()
	prepare_constants_data()
	prepare_int_constants_data()
	prepare_gradients_data()
	prepare_perm_data()

func prepare_input_data() -> void:
	#Input data
	var input_data := PackedVector2Array()
	for i in range(10000): #This is just the squared value of WOLRD_SIZE, since it will be in a square
		for j in range(10000):
			input_data.append(Vector2(i, j))
	var input_bytes := input_data.to_byte_array()
	input_buffer = rd.storage_buffer_create(input_bytes.size(), input_bytes)
	input_uniform = RDUniform.new()
	input_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	input_uniform.binding = 0
	input_uniform.add_id(input_buffer)

func prepare_output_data() -> void:
	#Output data
	var output_data := PackedFloat32Array()
	for i in range(WORLD_SIZE):
		output_data.append(1.0) #I made this 1.0 for debugging to see if a value comes back as 1.0 exactly
	var output_bytes := output_data.to_byte_array()
	output_buffer = rd.storage_buffer_create(output_bytes.size(), output_bytes)
	output_uniform = RDUniform.new()
	output_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	output_uniform.binding = 1
	output_uniform.add_id(output_buffer)

func prepare_constants_data() -> void:
	#Constants uniform data
	var constants_bytes = constants_data.to_byte_array()
	constants_buffer = rd.storage_buffer_create(constants_bytes.size(), constants_bytes)
	constants_uniform = RDUniform.new()
	constants_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	constants_uniform.binding = 2
	constants_uniform.add_id(constants_buffer)

func prepare_int_constants_data() -> void:
	#Int Constants uniform data
	var int_constants_bytes = int_constants_data.to_byte_array()
	int_constants_buffer = rd.storage_buffer_create(int_constants_bytes.size(), int_constants_bytes)
	int_constants_uniform = RDUniform.new()
	int_constants_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	int_constants_uniform.binding = 3
	int_constants_uniform.add_id(int_constants_buffer)

func prepare_gradients_data() -> void:
	#Gradients uniform data
	var gradients_bytes = gradients_data.to_byte_array()
	gradients_buffer = rd.storage_buffer_create(gradients_bytes.size(), gradients_bytes)
	gradients_uniform = RDUniform.new()
	gradients_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	gradients_uniform.binding = 4
	gradients_uniform.add_id(gradients_buffer)

func prepare_perm_data() -> void:
	#Perm uniform data
	var perm_seed = RandomNumberGenerator.new().randi()
	var perm_data: PackedInt32Array = generate_perm(perm_seed)
	var perm_bytes = perm_data.to_byte_array()
	perm_buffer = rd.storage_buffer_create(perm_bytes.size(), perm_bytes)
	perm_uniform = RDUniform.new()
	perm_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	perm_uniform.binding = 5
	perm_uniform.add_id(perm_buffer)

func generate_perm(seed: int) -> PackedInt32Array:
	var perm: Array[int] = []
	# We have to fill with zeros to make this work later
	for i in range(256):
		perm.append(0)
	var source: Array[int] = []
	for i in range(256):
		source.append(i)
	# Generates a proper permutation
	seed = overflow(seed * 6364136223846793005 + 1442695040888963407)
	seed = overflow(seed * 6364136223846793005 + 1442695040888963407)
	seed = overflow(seed * 6364136223846793005 + 1442695040888963407)
	for i in range(255, -1, -1):
		seed = overflow(seed * 6364136223846793005 + 1442695040888963407)
		var r: int = int((seed + 31) % (i + 1))
		if r < 0:
			r += i + 1
		perm[i] = source[r]
		source[r] = source[i]
	return PackedInt32Array(perm)

func overflow(x):
	var MAX_INT64: int = 9223372036854775807  # 2^63 - 1
	var MIN_INT64: int = -9223372036854775808  # -2^63
	if x > MAX_INT64:
		return x - (MAX_INT64 - MIN_INT64 + 1)
	elif x < MIN_INT64:
		return x + (MAX_INT64 - MIN_INT64 + 1)
	return x
