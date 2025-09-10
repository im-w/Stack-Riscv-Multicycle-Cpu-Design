# Input and Output File Names
INPUT_FILE = 'memory.txt'
OUTPUT_FILE = 'memory.mem'

INSTRUCTION_SET = {
    'ADD':  '000',
    'SUB':  '001',
    'AND':  '010',
    'NOT':  '011',
    'PUSH': '100',
    'POP':  '101',
    'JMP':  '110',
    'JZ':   '111'
}

memory = {}          # memory[address] = value
instruction_lines = []


def handle_store(parts):
    if len(parts) != 3:
        raise ValueError("Invalid store syntax. Use: store address value")
    address = int(parts[1])
    value = int(parts[2])
    if not (0 <= address < 32):
        raise ValueError("Address must be between 0 and 31")
    if not (0 <= value < 256):
        raise ValueError("Value must be 0–255 (8 bits)")
    memory[address] = value
    print(f"[MEM] Stored {value} (bin={format(value, '08b')}) at memory address {address}")


def encode_instruction(line):
    parts = line.strip().split()
    if not parts:
        return None

    if parts[0].lower() == 'store':
        handle_store(parts)
        return None

    mnemonic = parts[0].upper()
    opcode = INSTRUCTION_SET.get(mnemonic)
    if opcode is None:
        raise ValueError(f"Unknown instruction: {mnemonic}")

    if mnemonic in ['ADD', 'SUB', 'AND', 'NOT']:
        return opcode + '00000'

    if len(parts) != 2:
        raise ValueError(f"Instruction '{mnemonic}' needs an address.")

    address = int(parts[1])
    if not (0 <= address < 32):
        raise ValueError("Address must be between 0 and 31")

    if mnemonic == 'PUSH' and address in memory:
        print(f"[PUSH] Address {address} contains value: {memory[address]}")

    return opcode + format(address, '05b')


def encode_file(input_path, output_path):
    instruction_lines.clear()
    with open(input_path, 'r') as f:
        for line in f:
            if line.strip() == '':
                continue
            encoded = encode_instruction(line)
            if encoded:
                instruction_lines.append(encoded)

    # Pad instruction lines to exactly 32 entries
    while len(instruction_lines) < 32:
        instruction_lines.append('00000000')

    # Start with those 32 lines (instructions + padding)
    output = instruction_lines.copy()

    # Overwrite unconditionally with any stored data
    for addr, val in memory.items():
        output[addr] = format(val, '08b')

    # Write exactly 32 lines (no extra newline at the end)
    with open(output_path, 'w') as f:
        f.write('\n'.join(output[:32]))


# Run the encoding
encode_file(INPUT_FILE, OUTPUT_FILE)