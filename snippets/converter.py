import ast
import os

def convert_code_snippet(
    input_path="/home/thomastien/.config/nvim/snippets/converter_input",
    output_path="/home/thomastien/.config/nvim/snippets/converter_output",
    output_to_file=True,
):
    with open(input_path, "r") as file:
        code = file.read()
        

    converted_lines = []
    lines = code.splitlines()
    INDENT_LEVEL = 4
    for i, line in enumerate(lines):
        escaped_line = (
            line
            .replace("\\", r"\\")
            .replace('"', r'\"')
        )
        comma = "" if i == len(lines) - 1 else ","
        tab = "\t" * INDENT_LEVEL if i > 0 else ""
        converted_lines += f'{tab}"{escaped_line}"{comma}\n'

    if output_to_file:
        with open(output_path, "w") as file:
            file.write("".join(converted_lines))

    return "".join(converted_lines)

def update_json_snippet(
    input_path="/home/thomastien/.config/nvim/snippets/",
    filetype="python",
):
    input_path = os.path.join(input_path, filetype)
    template = """
        "<name>": {
            "prefix": ["<prefix>"],
            "body": [
                <body>
            ],
            "description": "<description>"
        }
    """
    updated_json = []
    for filename in os.listdir(input_path):
        file_path = os.path.join(input_path, filename)
        filename_no_ext = filename.rsplit(".", 1)[0]
            
        updated_content = template.replace("<name>", filename_no_ext)
        updated_content = updated_content.replace("<prefix>", filename_no_ext)
        updated_content = updated_content.replace("<body>", convert_code_snippet(
            input_path=file_path,
            output_to_file=False,
        ))
        updated_content = updated_content.replace("<description>", "Desciption")

        updated_json.append(updated_content)

    with open(f"/home/thomastien/.config/nvim/snippets/{filetype}.json", "w") as file:
        file.write("{\n")
        file.write(",".join(updated_json))
        file.write("\n}\n")

def update_all():
    filetypes = ["python", "cpp", "c", "java", "asm"]
    for filetype in filetypes:
        update_json_snippet(filetype=filetype)

if __name__ == "__main__":
    # update_json_snippet(filetype="python")
    update_all()
