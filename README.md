# HelpX - Global Tool Management Helper

HelpX is a user-friendly, professional tool management script designed to streamline the way you manage, view, and execute commands for your favorite tools. 

### This Tool installes your important kali linux tools!

## Features

- **Tool Management**: Add, remove, edit, and view tools and their commands effortlessly.
- **Command Execution**: Run predefined commands for tools with a single command.
- **User-Friendly**: Intuitive interface with colored output for better readability.
- **Customizable**: Easily configure and extend tools via a configuration file (`main.sh`).
- **Batch Updates**: Automatically update all managed tools with their latest configurations.
- **Enhanced Usability**: Supports detailed usage instructions and interactive menus.

## Installation

Clone this repository and run the main setup script:

```bash
git clone https://github.com/zebbern/Helpx.git
cd Helpx
chmod +x *.sh
sudo ./main.sh

You may need to run this again in case it skipped a command
sudo ./main.sh
```

## Usage

To access the help menu, simply type:

```bash
helpx
```

### Common Commands

- **List Topics**: `helpx list`
- **View Topic Information**: `helpx <name>`
- **Add a Topic**: `helpx create <name>`
- **Remove a Topic**: `helpx delete <name>`
- **Edit Topic**: `helpx edit <name>`

### Example

```bash
helpx add nmap
```
Follow the prompts to add a new tool with its description and commands.

## Contributions

We welcome contributions to enhance the functionality of HelpX. Feel free to fork this repository, submit issues, or open pull requests.

## License

This project is licensed under the [MIT License](LICENSE).

## Support

For any issues or feedback, please create a issue.

---
![image](https://github.com/user-attachments/assets/f3933d1d-0f90-485f-913b-c8da808fda03)

