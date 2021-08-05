require 'discordrb'
require_relative 'configs'
require_relative 'logging'
require_relative 'botCommands'

bot = Discordrb::Bot.new(token: Configs.getConfigValue("discordToken"), parse_self: false, ignore_bots: true)

bot.message(start_with: Configs.getConfigValue("discordPrefix")) do |event|
    Commands.ParseCommand(event, bot)
end

bot.run(:async)

while true do
    begin
        Logger.log("Setting new activity...", 1)
        Commands.SetNewActivity(bot)
        Logger.log("Activity set!", 1)
        sleep(Configs.getConfigValue("activityCycleSleepLengthInSeconds"))
    rescue => e
        Logger.log("Failed setting new activity!!!: " + e.to_s, 4)
        Logger.log("Trying again in 30 seconds...", 4)
        sleep(Configs.getConfigValue("activityCycleFailSleepInSeconds"))
    end
end

