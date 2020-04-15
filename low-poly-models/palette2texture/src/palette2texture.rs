use clap::{Arg, App, SubCommand};
use std::process;

use palette2texture::Converter;

fn main() {
	let matches = App::new("palette2texture")
					.version("0.1")
					.author("Andreas N. <andreas@omni-mad.com>")
					.about("Converts a palette into an image")
					.subcommand(SubCommand::with_name("convert")
						.arg(Arg::with_name("input")
							.long("input")
							.value_name("INPUT")
							.help("Set the input palette filename")
							.takes_value(true)
						)
						.arg(Arg::with_name("output")
							.long("output")
							.value_name("OUTPUT")
							.help("Set the output texture filename")
							.takes_value(true)
						)
					)
					.get_matches();

	if let ("convert", Some( sub_matches ) ) = matches.subcommand() {
		let input = sub_matches.value_of("input").unwrap_or("in.gpl").to_string();
		let output = sub_matches.value_of("output").unwrap_or("out.png").to_string();

		println!("output  : {:?}", output );
		println!("input  : {:?}", input );

		match Converter::convert( &input, &output ) {
			Ok( number_of_files ) => {
					println!("{:?} files converted", number_of_files );
					process::exit( 0 );
				},
			Err( e ) => {
				println!("Error {:?}", e );
				process::exit( -1 );
			},
		}
	}

}
