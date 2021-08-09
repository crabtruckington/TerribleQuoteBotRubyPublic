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
2) Connect to your Postgres instance, create a database to store quotes, and user that can connect to it.
3) Rename or copy `configs.rb.example` to `configs.rb`
4) Enter your Postgres connection string, and your Discord API token into the configuration file
5) Connect to the Postgres database and create the table, as defined in `quoteTable.sql`
    - Optionally, you should at least 1 record to the `quotes` table at this point, to prevent the bot from potentially being unable to retrieve data
6) Run the `quotebot.rb` file, the bot will join your server
7) In Discord, create a role called `BotGod` and assign it to any users who should be able to administer the bot
8) Enjoy your bot
