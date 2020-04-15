use gimp_palette::Palette;
use std::path::Path;
use image::{ GenericImage, ImageFormat };

pub struct Converter {

}

impl Converter {
	fn calculateSizeForEntries( entries:usize ) -> u32 {
		// needs to be square of power of two

		// find n
		// where
		// n is power of two
		// n^2 > entries


		// brute force
		let mut s = 1;
		while s < 8096 {
			let p = s*s;
			if p >= entries {
				return s as u32;
			}
			s <<= 1;
		};

		return 0;	// not found
	}
	pub fn convert(
		input:&String,
		output:&String
	) -> Result<u32,&'static str> {

		// load the palette
		// :TODO: allow multiple input formats
		// for now just gimp palette aka .gpl

		let input_path = Path::new( input );
		let pal = match Palette::read_from_file( input_path ) {
			Ok( p ) => p,
			Err( e ) => return Err( "Error reading palette" ),
		};

		let colors = pal.get_colors();

		// figure out image size
		let l = colors.len();
		let s = Converter::calculateSizeForEntries( l );
		println!("Palette has {} colors. Needs image size {}x{}", l, s, s );

		// create image
		let mut img = image::DynamicImage::new_rgba8( s, s );

		// copy in the colors

		let mut x = 0;
		let mut y = 0;

		for color in colors {
			if y >= s {
				println!("Error @ {}, {}", x, y );
				return Err( "Too many entries for size" );	// should never happen
			}
			
			println!("{} {} {}", color.r, color.g, color.b );

			let pixel = image::Rgba( [ color.r, color.g, color.b, 255 ] ); //float 0.0 -1.0?
			img.put_pixel( x, y, pixel );

			x+=1;
			if x >= s {
				y+=1;
				x =0;
			}
		}

		// save image
		match img.save_with_format(output, ImageFormat::PNG) {
			Ok( _ ) => Ok( 1 ),
			Err( e ) => {
				println!("Error saving image {}", e );
				Err( "Error saving image" )
			},
		}

	}
}
