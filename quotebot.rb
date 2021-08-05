require 'discordrb'
require_relative 'configs'
require_relative 'logging'
require_relative 'botCommands'

bot = Discordrb::Bot.new(token: Configs.getConfigValue("discordToken"), parse_self: false, ignore_bots: true)

bot.message(start_with: Configs.getConfigValue("discordPrefix")) do |event|
    Commands.ParseCommand(event, bot)
end

bot.run