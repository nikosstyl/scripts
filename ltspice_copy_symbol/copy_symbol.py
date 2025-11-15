import argparse, json, os

LTSPICE_DEFAULT_SYMBOL_FOLDER = os.getenv('LOCALAPPDATA')+"/LTspice/lib/sym/"

CONFIG_FILE = "config.json"
ACCEPTED_COMPONENTS = []
FILE_POSITIONS = []

Parser = argparse.ArgumentParser(description="Simple script that copies a default LTspice symbol to a custom-made one.")
Parser.add_argument('-c', '--component', help=f"Set the correct component to copy. Acceptable components are: {ACCEPTED_COMPONENTS}")
Parser.add_argument('-t', '--target', help="Set the target file to copy the symbol to.")

def read_accepted_components(configuration_file:str) -> tuple[list,list]:
	ret_element_list = []
	ret_file_list = []
	with open(configuration_file) as f:
		d = dict(json.load(f))
	for category in d.keys():
		for element in d[category]:
			ret_element_list.append(element[0].lower())
			ret_file_list.append(element[1])
	return(ret_element_list, ret_file_list)

def check_arguments(parser: argparse.ArgumentParser) -> tuple[str,str]:
	args = parser.parse_args()

	component = args.component
	target_file = args.target

	if not component or not target_file:
		parser.print_usage()
		exit(1)

	component = str(component).lower()
	target_file = str(target_file).lower()

	if component not in ACCEPTED_COMPONENTS:
		print(f"Component {component} was not found in the accepted components library.")
		print(f"Accepted components: {ACCEPTED_COMPONENTS}")
		exit(2)
	if not os.path.isfile(target_file):
		print(f"Target file \"{target_file}\" does not exist!")
		exit(5)
	return(component, target_file)

ACCEPTED_COMPONENTS, FILE_POSITIONS = read_accepted_components(CONFIG_FILE)

def main():
	error_found = False
	for i, comp in enumerate(FILE_POSITIONS):
		if not os.path.isfile(LTSPICE_DEFAULT_SYMBOL_FOLDER+comp):
			print(f"Component \"{ACCEPTED_COMPONENTS[i]}\" with filename \"{comp}\" is missing from the default LTspice symbol folder \"{LTSPICE_DEFAULT_SYMBOL_FOLDER}\"!")
			error_found = True

	if error_found:
		exit(4)

	component, target_file = check_arguments(Parser)

	component_filename = LTSPICE_DEFAULT_SYMBOL_FOLDER + FILE_POSITIONS[ACCEPTED_COMPONENTS.index(component)]

	component_lines = []
	try:
		with open(component_filename) as file:
			for line in file:
				if "LINE" in line:
					component_lines.append(line)
	except FileNotFoundError: 
		print(f"Component {component} is not in the default LTspice symbol folder \"{LTSPICE_DEFAULT_SYMBOL_FOLDER}\"!")
		exit(3)

	try:
		with open(target_file, "a") as file:
			for line in component_lines:
				file.write(line)
	except FileNotFoundError:
		print(f"Target file {target_file} cannot be found!")
		exit(5)

if __name__ == "__main__":
	main()