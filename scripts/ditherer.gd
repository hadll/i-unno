class_name Ditherer extends CompositorEffect
const WIDTH := 1152
const HEIGHT := 648

@export var calmness: float = 1
@export var view_dist: float = 5
@export var view_fog: float = 8

var rd: RenderingDevice
var shader: RID
var pipeline: RID
var uniform_set: RID
var nearest_sampler: RID

var palette_buffer: RID
var dither_buffer: RID

func _init() -> void:
	initialise_shader.call_deferred()

func initialise_shader() -> void:
	rd = RenderingServer.get_rendering_device()
	var shader_file: RDShaderFile = load("res://shaders/ditherer.glsl")
	var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
	shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(shader)
	
	var palette_image := preload("res://assets/palette.png")
	palette_image.convert(Image.FORMAT_RGBA8)
	
	var palette_texture_format := RDTextureFormat.new()
	palette_texture_format.width = palette_image.get_width()
	palette_texture_format.height = palette_image.get_height()
	palette_texture_format.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UINT
	palette_texture_format.usage_bits = (
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT | 
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
	)
	var palette_data := palette_image.get_data()
	palette_buffer = rd.texture_create(palette_texture_format, RDTextureView.new(), [palette_data])
	
	var dither_image := preload("res://assets/dither.png")
	dither_image.convert(Image.FORMAT_R8)
	
	var dither_texture_format := RDTextureFormat.new()
	dither_texture_format.width = dither_image.get_width()
	dither_texture_format.height = dither_image.get_height()
	dither_texture_format.format = RenderingDevice.DATA_FORMAT_R8_UINT
	dither_texture_format.usage_bits = (
		RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT | 
		RenderingDevice.TEXTURE_USAGE_STORAGE_BIT
	)
	var dither_data := dither_image.get_data()
	dither_buffer = rd.texture_create(dither_texture_format, RDTextureView.new(), [dither_data])
	
	var sampler_state: RDSamplerState = RDSamplerState.new()
	sampler_state.min_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	sampler_state.mag_filter = RenderingDevice.SAMPLER_FILTER_NEAREST
	nearest_sampler = rd.sampler_create(sampler_state)

func _render_callback(called_effect_callback_type: int, render_data: RenderData) -> void:
	if called_effect_callback_type != EFFECT_CALLBACK_TYPE_POST_TRANSPARENT:
		push_error("wrong callback")
		return
	if not rd:
		return
	var render_scene_buffers: RenderSceneBuffersRD = render_data.get_render_scene_buffers()
	var render_scene_data := render_data.get_render_scene_data()
	
	var camera_transform := render_scene_data.get_cam_transform()
	var camera_projection := render_scene_data.get_cam_projection()
	var camera_inv_projection := camera_projection.inverse()
	
	var camera_half_extents := camera_projection.get_viewport_half_extents()
	var camera_quaternion := camera_transform.basis.get_rotation_quaternion()
	var data_bytes := PackedFloat32Array([
		camera_inv_projection.x.x, camera_inv_projection.x.y, camera_inv_projection.x.z, camera_inv_projection.x.w, 
		camera_inv_projection.y.x, camera_inv_projection.y.y, camera_inv_projection.y.z, camera_inv_projection.y.w, 
		camera_inv_projection.z.x, camera_inv_projection.z.y, camera_inv_projection.z.z, camera_inv_projection.z.w, 
		camera_inv_projection.w.x, camera_inv_projection.w.y, camera_inv_projection.w.z, camera_inv_projection.w.w, 
		camera_quaternion.x, camera_quaternion.y, camera_quaternion.z, camera_quaternion.w,
		camera_transform.origin.x, camera_transform.origin.y, camera_transform.origin.z, Time.get_ticks_msec() / 1000.0,
		camera_half_extents.x, camera_half_extents.y, camera_projection.get_z_near(), 0.0,
		calmness,
		view_dist,
		view_fog
	]).to_byte_array()
	
	if not uniform_set.is_valid():
		var texture_buffer := render_scene_buffers.get_color_layer(0)
		var depth_buffer := render_scene_buffers.get_depth_layer(0)

		var texture_uniform := RDUniform.new()
		texture_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		texture_uniform.binding = 0
		texture_uniform.add_id(texture_buffer)
		
		var depth_uniform := RDUniform.new()
		depth_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_SAMPLER_WITH_TEXTURE
		depth_uniform.binding = 1
		depth_uniform.add_id(nearest_sampler)
		depth_uniform.add_id(depth_buffer)
		
		var palette_uniform := RDUniform.new()
		palette_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		palette_uniform.binding = 2
		palette_uniform.add_id(palette_buffer)
		
		var dither_uniform := RDUniform.new()
		dither_uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
		dither_uniform.binding = 3
		dither_uniform.add_id(dither_buffer)
		
		uniform_set = rd.uniform_set_create([
			texture_uniform,
			depth_uniform,
			palette_uniform,
			dither_uniform
		], shader, 0)
	
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_set_push_constant(compute_list, data_bytes, data_bytes.size())
	@warning_ignore("integer_division")
	rd.compute_list_dispatch(compute_list, WIDTH / 8, HEIGHT / 8, 1)
	rd.compute_list_end()

func free_rids() -> void:
	rd.free_rid(uniform_set)
	rd.free_rid(palette_buffer)
