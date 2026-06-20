package tool_template
import cd "github.com/jakub-borusewicz/jacues/tools:tool_commands_definitions"


#include_commands: [...string]

command: {
	for v in cd.command_name_list
	 if list.Contains(#include_commands, v)
	 {"\(v)": cd.command_definitions[v]}
}