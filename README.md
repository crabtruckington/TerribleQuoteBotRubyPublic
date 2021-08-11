# TerribleQuoteBotRuby
A discord quote bot in ruby

# About
Terrible Quote Bot is a discord bot, written in ruby, that will allow you to store quotes for your server.

# How to use
The bot will respond to `!quotehelp` or `!helpquote` commands, and print out a list of available options:

```
The following commands are supported:
!quote: shows a random quote, optionally provide a number to show a specific quote
!addquote <text>: adds a quote to the database
!findquote <text> (alias: !quotesearch): search for a quote containing this text
!formatquote <text> (alias: !quoteformat): format a quote before adding it
!addformattedquote: adds the last quote that was formatted
!ping: pong!
```

There are also 2 additional commands that can only be used by administrators, `!delquote` for deleting quotes, and `!setactivity` for cycling through the bots activity status's.

# Installation
You will need a Discord developer account with a bot already created, and a Postgresql database on the machine you wish to run the bot from. If you are not sure how to set these up, there are plenty of guides available.

1) Clone repository to a folder on the machine you wish to run the bot from. Any operating system that supports ruby and gem building will work
2) Connect to your Postgres instance, create a database to store quotes, and user that can connect to it. This user should probably be the owner of the database as it will need permissions to create and drop tables (the `quotes` table has an ID column and the `!delquote` command can remove an arbitrary ID. The tables will be swapped to avoid having gaps in the ID. See the `sqlHelpers.rb` file for more information).
3) In Postgres, create the `quotes` table, as defined in `quoteTable.sql`. Try to use the user you just created to make sure it can do this.
    - Optionally, if you want to use the bot immediately, you should add at least 1 record to the `quotes` table at this point, to prevent the bot from potentially being unable to retrieve data. Just insert any record into the `quote` column.
4) Rename or copy `configs.rb.example` to `configs.rb`
5) Enter your Postgres connection string, and your Discord API token into the configuration file
6) If you already have `bundler` installed, simply run `bundle install`. If you dont have and dont want to install `bundler`, take a look in the `Gemfile` to see which gems you will need and install them.
7) Run the `quotebot.rb` file, the bot will join your server
8) In Discord, create a role called `BotGod` and assign it to any users who should be able to administer the bot. The role does not need any specific permissions.
9) Enjoy your bot
