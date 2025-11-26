# FLAMP Relay File Queue ID Switcher

swqid is just a simple command line script that uses text search and replace to change the queue ID in FLAMP relay file.

This can be useful if you have a flamp relay file from one queue ID, but you are trying to fill some blocks for another operator who has the same file but under a different queue id.

For usage instructions, simply run the program without any arguments.

The script is written as a shell script in Linux, but then AI was used to port it to Powershell so that it runs on Windows. The port worked perfectly. If you are using the powershell version in Windows, you can just run the program from a powershell Windows Terminal, or on a Command Prompt window by putting "pwsh" in front of the program name, like "pwsh swqid.ps1 1234 my_file.txt > new_file.txt".

Please let me know if you have any issues.

--- lobanz@protonmail.com

