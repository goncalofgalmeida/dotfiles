#!/bin/bash

# Color variables
RED="\e[31m"
GREEN="\e[32m"
YELLOW="\e[33m"
BLUE="\e[34m"
MAGENTA="\e[35m"
ENDCOLOR="\e[0m"

# Define project paths
FORTYTWO_PROJECTS_DIR="$HOME/42/common-core/projects"
ODIN_PROJECTS_DIR="$HOME/workshop"
MINITALK_DIR="$FORTYTWO_PROJECTS_DIR/minitalk"
SO_LONG_DIR="$FORTYTWO_PROJECTS_DIR/so_long"
LIBRARY_DIR="$ODIN_PROJECTS_DIR/library"

# Prompt user
printf "${MAGENTA}Welcome back.${ENDCOLOR}\n"
printf "${MAGENTA}What project will you be working on today?${ENDCOLOR}\n"
printf "\n"
printf "${GREEN}(1)${ENDCOLOR} Minitalk\n"
printf "${GREEN}(2)${ENDCOLOR} So_long\n"
printf "${GREEN}(3)${ENDCOLOR} Library\n"
printf "${GREEN}(4)${ENDCOLOR} A new project\n"
printf "${GREEN}(q)${ENDCOLOR} None for now, thanks\n"
printf "\n"
printf "Enter your choice: "
read choice

case $choice in
    1)
        cd "$MINITALK_DIR" && code .
        ;;
    2)
        cd "$SO_LONG_DIR" && code .
        ;;
    3)
        cd "$LIBRARY_DIR" && code .
        ;;
    4)
		printf "${MAGENTA}\nWill this project be part of?${ENDCOLOR}\n"
		printf "${GREEN}(1)${ENDCOLOR} 42\n"
		printf "${GREEN}(2)${ENDCOLOR} The Odin Project\n"
		printf "\n"
		printf "Enter your choice: "
		read new_project_dir
		case $new_project_dir in
			1)
				TARGET_DIR="$FORTYTWO_PROJECTS_DIR"
				;;
			2)
				TARGET_DIR="$ODIN_PROJECTS_DIR"
				;;
			*)
				printf "\nInvalid choice. Exiting.\n"
				exit 1
				;;
		esac

		printf "\n"
		printf "Enter the new project name: " 
		read new_project_name
		printf "\n"
        mkdir -p "$TARGET_DIR/$new_project_name"
        cd "$TARGET_DIR/$new_project_name" && code .
        ;;
    q)
        printf "\n${MAGENTA}Alright, have a great day!${ENDCOLOR}\n"
		printf "\n"
        ;;
    *)
        printf "\n${MAGENTA}Invalid choice. Exiting.${ENDCOLOR}\n"
		printf "\n"
        ;;
esac
