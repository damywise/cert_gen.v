module main

import sdl
import sdl.image
import sdl.ttf
import gx
import os

fn main() {
	os.signal_opt(.int, fn (_ os.Signal) {
		exit(-1)
	})!
	sdl.init(sdl.init_video)
	ttf.init()

	font_data := FontData{
		fontsource: 'assets/fonts/ALS-Script.ttf'
		fontsize: 148
	}

	source := 'names.txt'
	mut texts := os.read_lines(source) or { ['_ERROR_'] }
	output_name := texts[0]
	texts.delete(0)
	// remove double spaces
	for i := 0; i < texts.len; i++ {
		for texts[0].contains('  ') {
			texts[0] = texts[0].replace('  ', ' ')
		}
	}

	// create dir if not found, and recreate dir (and contents) if found
	output_dir := 'outputs'
	if os.is_dir(output_dir) {
		os.rmdir_all(output_dir)!
	}
	os.mkdir(output_dir)!

	background_path := 'assets/Sertifikat_2339x1654.jpg'
	// load background image
	img := image.load(background_path.str)

	window := sdl.create_window('Render Certs'.str, sdl.windowpos_undefined, sdl.windowpos_undefined,
		img.w, img.h, u32(sdl.WindowFlags.hidden))

	println('Rendering and exporting ${texts.len} certificates... (might take a few minutes)')
	for name in texts {
		render_image(window, img, font_data, name, '${output_dir}/${name}.jpg')
	}

	println('Compressing... (might take a few more minutes)')
	compress_result := os.execute('7zz a -t7z -mx=9 -mfb=273 -ms -md=31 -myx=9 -mtm=- -mmt -mmtf -md=1536m -mmf=bt3 -mmc=10000 -mpb=0 -mlc=0 ${output_dir}.7z ${output_dir}')
	if compress_result.exit_code == 0 {
		println('Compression successful: Saved to ${output_name}.7z')
	} else {
		eprintln('Compression failed: Undocumented error')
	}

	sdl.free_surface(img)
	sdl.destroy_window(window)
	ttf.quit()
	sdl.quit()

	println('Export done')
}

struct FontData {
pub:
	fontsource string
	fontsize   int
}

fn render_image(window &sdl.Window, img &sdl.Surface, font_data FontData, text string, output string) {
	renderer := sdl.create_renderer(window, -1, u32(sdl.RendererFlags.accelerated) | u32(sdl.RendererFlags.targettexture))
	timg := sdl.create_texture_from_surface(renderer, img)

	// zero weidth, height
	zw := 0
	zh := 0

	// not invoked because we loaded an image
	// sdl.set_render_target(renderer, texture)
	// sdl.set_render_draw_color(renderer, 0, 0, 0, 0)
	// sdl.render_clear(renderer)

	// println('$text ${sdl.query_texture(timg, sdl.null, sdl.null, &zw, &zh)}')
	sdl.query_texture(timg, sdl.null, sdl.null, &zw, &zh)

	// destination rect
	dstrect := sdl.Rect{0, 0, zw, zh}
	sdl.render_copy(renderer, timg, sdl.null, &dstrect)

	mut surface := sdl.create_rgb_surface_with_format(0, img.w, img.h, 32, u32(sdl.Format.rgba8888))

	sdl.render_read_pixels(renderer, sdl.null, u32(surface.format.format), surface.pixels,
		surface.pitch)

	render_text(renderer, font_data, text)

	surface = sdl.create_rgb_surface_with_format(0, img.w, img.h, 32, u32(sdl.Format.rgba8888))
	sdl.render_read_pixels(renderer, sdl.null, u32(surface.format.format), surface.pixels,
		surface.pitch)
	image.save_jpg(surface, output.str, 99)
	sdl.destroy_texture(timg)
	sdl.free_surface(surface)
	sdl.destroy_renderer(renderer)
}

fn render_text(renderer &sdl.Renderer, font_data FontData, text string) {
	mut font := ttf.open_font(font_data.fontsource.str, font_data.fontsize)
	ttf.set_font_hinting(font, int(ttf.hinting_normal))
	color := gx.hex(0x38_24_1B_FF)

	zw := 0
	zh := 0

	text_width := 0
	text_height := 0
	ttf.size_text(font, text.str, &text_width, &text_height)
	// println([text_width, text_height])

	rectl := 187
	rectr := 187
	// rectt := 800
	// rectb := 691
	rectw := 2339 - rectl - rectr
	recth := 1654 - 800 - 691

	mut newrectw := text_width * recth / text_height
	mut newrecth := recth
	if newrectw > rectw {
		newrectw = rectw
		newrecth = text_height * rectw / text_width
		// println([newrectw, newrecth])

		t_wid2 := 0
		t_hei2 := 0
		font = ttf.open_font(font_data.fontsource.str, newrecth - (text_height - font_data.fontsize))
		ttf.size_text(font, text.str, &t_wid2, &t_hei2)

		font = ttf.open_font(font_data.fontsource.str, newrecth - ((text_height - font_data.fontsize) * t_hei2 / font_data.fontsize) - 1)
		ttf.size_text(font, text.str, &text_width, &text_height)
		// println([text_width, text_height])
	}

	tsurf := ttf.render_text_blended(font, text.str, sdl.Color{
		r: color.r
		g: color.g
		b: color.b
		a: color.a
	})
	ttext := sdl.create_texture_from_surface(renderer, tsurf)

	sdl.query_texture(ttext, sdl.null, sdl.null, &zw, &zh)
	dstrect := sdl.Rect{2339 / 2 - newrectw / 2, 1654 - 690 - newrecth, newrectw, newrecth}
	sdl.render_copy(renderer, ttext, sdl.null, &dstrect)
	sdl.destroy_texture(ttext)
	sdl.free_surface(tsurf)
}
