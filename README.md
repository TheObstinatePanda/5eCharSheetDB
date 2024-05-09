# 5e Character Sheet Database Tool

## Description

This project is a PostgreSQL database designed to manage character data for Dungeons and Dragons fifth edition. When completed, it will include functionality to manage characters, races, and classes, and automatically applies the various stats, skills, saves, proficiencies and more to the sheet.

The intention of this project is to have a framework to create a webapp similar to DnD beyond, it is not meant for widespread public use but for a portfolio project.

## Prerequisites

Before you begin, ensure you have met the following requirements:

* You have installed the latest version of [PostgreSQL](https://www.postgresql.org/download/) and [Postbird](https://www.electronjs.org/apps/postbird).
* You have a Windows machine. This project was developed and tested on Windows and not has been tested in any other operating system.

## Installing and setting up the project

To install and set up the project, follow these steps:

1. Download and install PostgreSQL and Postbird.
2. Set up a new PostgreSQL database.
3. Run the `upload_me.sql` file in your new database. This will set up the necessary tables and populate the `race` table.

## Using the project

To use the project:

1. Insert a new character into the `bio` table. You'll need to provide the `id`, `char_name`, `player_name`, and `char_lvl`.
   ```sql
   INSERT INTO bio (id, char_name, player_name, char_lvl)
    VALUES (
        <number>,
        <char_name>,
        <player_name>,
        <number 1-20>
    )
    ```
2. Once the character is initialized, you can update the `race` field in the `bio` table. **Note** - make sure to check the `race` table to view the races that have been populated and that you reference the correct id you created in the first step. If you want to add your own races to test, observe the format of the entries in [populate_race_table.sql](./populate_race_table.sql).
   ```sql
   UPDATE bio
    SET race = <race>
    WHERE id = <number>
    ```
3. Check the `stats` table to see the racial bonuses that have been applied to the character.

## Known Issues

* The database triggers are not complete. Functionality to remove racial bonuses when a character's race is changed is still under development.
* The `class` table has not been populated. Triggers have been added to this table, but they have not been tested.

## Roadmap

I plan to update this periodically to add the missing functionallity and test all of the triggers. Below are a few of the objective upcoming.

- Populate the `class` table and test the already established triggers for adding proficiency bonuses appropriately
- Add triggers that allow users to change a characters race and class and change the bonuses there in
- Add error checking to all triggers to optimize their performance
- Once satisfied with the operation of the database when classes are properly integrated, begin to develop the front end functionality needed to display dynamic character sheets.

## Contributing to the project

Feel free to contribute to this project. If you would like to, follow these steps:

1. Fork the repository.
2. Create a new branch: `git checkout -b <branch_name>`.
3. Make your changes and commit them: `git commit -m '<commit_message>'`
4. Push to the original branch: `git push origin <project_name>/<location>`
5. Create the pull request.

## Contact

If you want to contact me you can reach me at `<your_email@address.com>`.

## License

This project uses the following license: [Apache 2.0](./LICENSE.txt).