import argparse, json, os

LTSPICE_DEFAULT_SYMBOL_FOLDER = os.getenv('LOCALAPPDATA')+"/LTspice/lib/sym/"

CONFIG_FILE = "config.json" # Default config file
ACCEPTED_COMPONENTS = []
FILE_POSITIONS = []

Parser = argparse.ArgumentParser(description="Simple script that copies a default LTspice symbol to a custom-made one.")
Parser.add_argument('-c', '--component', help=f"Set the correct component to copy. Acceptable components are: {ACCEPTED_COMPONENTS}")
Parser.add_argument('-t', '--target', help="Set the target file to copy the symbol to.")

def printConfigFileUsage():
    print("Fatal error: Config file not found!")
    print("Typical usage:")
    print("\t{\n\t\t\"category1\": [[\"element\", \"Location in LTSpice folder\"]],\n\t}")

def read_accepted_components(configuration_file:str) -> tuple[list,list]:
	ret_element_list = []
	ret_file_list = []
	try:
		f = open(configuration_file)
	except FileNotFoundError:
		printConfigFileUsage()
		return(None, None)
	else:
		with f:
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

def copy_symbol_main(component:str, target_file:str):
	global ACCEPTED_COMPONENTS, FILE_POSITIONS
	ACCEPTED_COMPONENTS, FILE_POSITIONS = read_accepted_components(CONFIG_FILE)
	if (ACCEPTED_COMPONENTS is None) or (FILE_POSITIONS is None):
		exit(6)

	error_found = False
	for i, comp in enumerate(FILE_POSITIONS):
		if not os.path.isfile(LTSPICE_DEFAULT_SYMBOL_FOLDER+comp):
			print(f"Component \"{ACCEPTED_COMPONENTS[i]}\" with filename \"{comp}\" is missing from the default LTspice symbol folder \"{LTSPICE_DEFAULT_SYMBOL_FOLDER}\"!")
			error_found = True

	if error_found:
		exit(4)

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
	component, target_file = check_arguments(Parser)
	copy_symbol_main(component, target_file)