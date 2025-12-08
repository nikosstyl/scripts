import re, os, argparse
from copy_symbol import read_accepted_components, CONFIG_FILE

MODEL_LINES = ["SymbolType BLOCK", "SYMATTR Prefix X"]

def check_arguments(parser: argparse.ArgumentParser) -> tuple[str,str]:
	args = parser.parse_args()

	component = args.component
	lib_file = args.file

	if not component or not lib_file:
		parser.print_usage()
		exit(1)

	component = str(component).lower()
	lib_file = str(lib_file).lower()

	if component not in ACCEPTED_COMPONENTS:
		print(f"Component {component} was not found in the accepted components library.")
		print(f"Accepted components: {ACCEPTED_COMPONENTS}")
		exit(2)
	if not os.path.isfile(lib_file):
		print(f"Target file \"{lib_file}\" does not exist!")
		exit(5)
	return(component, lib_file)

ACCEPTED_COMPONENTS, FILE_POSITIONS = read_accepted_components(CONFIG_FILE)

Parser = argparse.ArgumentParser(description="Generate LTspice symbol from SPICE model")
Parser.add_argument('-c', '--component', help=f"Set the correct component to copy. Acceptable components are: {ACCEPTED_COMPONENTS}")
Parser.add_argument('-f', '--file', help="Select the library file to generate the symbol from.")

component, lib_filename = check_arguments(Parser)

pattern = r"^(.*[\\/])([^\\/]+)$"
match = re.match(pattern, lib_filename)
if match:
	lib_path = match.group(1)
	lib_file = match.group(2)
else:
	exit(1)

f = open(lib_filename, "r")

line = f.readline()
while line:
	if line.lower().startswith(".subckt"):
		break
	line = f.readline()
f.close()

sub = line.strip().split(" ")
modelName = sub[1]
MODEL_LINES.append(f"SYMATTR Value {modelName}")
sub.remove(sub[0])
sub.remove(sub[0])

for i, pin in enumerate(sub):
	if "params:" in pin.lower():
		break
	MODEL_LINES.append(f"PIN {96+i*48} 0 LEFT 8")
	MODEL_LINES.append(f"PINATTR PinName {pin}")
	MODEL_LINES.append(f"PINATTR SpiceOrder {i+1}")
i+=1
MODEL_LINES.append(f"WINDOW 0 {96+i*48} 0 Bottom 2")
i+=1
MODEL_LINES.append(f"WINDOW 3 {96+i*48} 0 Bottom 2")
MODEL_LINES.append(f"SYMATTR ModelFile Libs/{lib_file}")

if os.path.isfile(lib_path+modelName+".asy"):
	print(f"File {lib_path+modelName+'.asy'} already exists! Exiting...")
	exit(2)

with open(lib_path+modelName+".asy", "w") as f:
	for line in MODEL_LINES:
		f.write(line+"\n")
