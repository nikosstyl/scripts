import argparse, json, os

LTSPICE_DEFAULT_SYMBOL_FOLDER = os.getenv('LOCALAPPDATA')+"/LTspice/lib/sym/"

CONFIG_FILE = "config.json"
ACCEPTED_COMPONENTS = []

def read_accepted_components(configuration_file:str) -> list : 
	ret_list = []
	with open(configuration_file) as f:
		d = dict(json.load(f))
	for category in d.keys():
		for element in d[category]:
			ret_list.append(str(element).lower())
	return(ret_list)

ACCEPTED_COMPONENTS = read_accepted_components(CONFIG_FILE)

parser = argparse.ArgumentParser(description="Simple script that copies a default LTspice symbol to a custom-made one.")
parser.add_argument('-c', '--component', help=f"Set the correct component to copy. Acceptable components are: {ACCEPTED_COMPONENTS}")
parser.add_argument('-t', '--target')
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

if component == "opamp":
    component_filename = LTSPICE_DEFAULT_SYMBOL_FOLDER+"OpAmps/UniversalOpAmp.asy"
else:
    component_filename = LTSPICE_DEFAULT_SYMBOL_FOLDER+component+".asy"

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