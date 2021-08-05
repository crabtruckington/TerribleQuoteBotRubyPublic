require 'discordrb'
require_relative 'activity'
require_relative 'configs'
require_relative 'sqlHelpers'
require_relative 'logging'
require_relative 'variableHelpers'

# COMMAND TYPES:
# 1 = ping
# 2 = quote help
# 3 = set activity
# 4 = random quote
# 5 = specific quote
# 6 = quote search
# 7 = add quote
# 8 = delete quote

class Commands    

    def self.ParseCommand(event, bot)
        commandType = -1
        contentArray = event.content.chomp.split(" ", 2)
        selectedQuote = -1
        
        command = contentArray[0].downcase            
        if (contentArray.length > 1)
            args = contentArray[1].strip.lstrip
        else
            args = ""
        end

        Logger.log("The command is: " + command, 0)
        Logger.log("The args are: " + args, 0)
        
        case command
        when "!ping"
            commandType = 1
        when "!quotehelp", "!helpquote"
            commandType = 2
        when "!setactivity"
            commandType = 3
        when "!quote"
            if (!args.empty?)
                if (VariableHelpers.IsStringNumber(args))
                    Logger.log("User is trying to select a specific quote", 0)
                    selectedQuote = args.to_i
                    commandType = 5
                else
                    Logger.log("User is attempting to search for quotes", 0)
                    commandType = 6                    
                end
            else
                Logger.log("No argument passed, user wants a random quote", 0)
                commandType = 4
            end
            commandType = 4
        when "!findquote", "!quotesearch"
            commandType = 6
        when "!addquote"
            commandType = 7
        when "!delquote"
            commandType = 8
        else
            Logger.log("This command is not for us, ignoring", 0)
        end


        if (commandType > 0)
            Logger.log("Executing command", 0)
            ExecuteCommand(args, commandType, event, bot)
        end
    end


    def self.ExecuteCommand(args, commandType, event, bot)
        reply = ""
        argumentProvided = (!args.empty?)

        case commandType
        when 1            
            Logger.log("Command type is 1", 0)
            event.respond "Pong!"
        when 2
            event.respond "The following commands are supported:
            !quote: shows a random quote, optionally provide a number to show a specific quote
            !addquote <text>: adds a quote to the database
            !findquote <text> (alias: !quotesearch): search for a quote containing this text
            !ping: pong!"
        when 3
            Logger.log("Setting new activity...", 0)
            SetNewActivity(bot)
            Logger.log("Activity set!", 0)
        when 4
            #get a random quote
        when 5
            #get a quote by ID
        when 6
            #search for quote by arg
        when 7
            #add a new quote, return the quote ID
            if (argumentProvided)

            else
                event.respond "You must provide some text to add a quote!"
            end
        when 8
            #check for BOT GOD role and then delete quote by ID
            if (IsBotGod(event.author))
                if (!args.empty?)
                    if (VariableHelpers.IsStringNumber(args))
                        #delete the quote with specified ID
                    else
                        event.respond "You must provide a valid quote number!"
                    end
                else
                    event.respond "You must provide the quote number to delete!"
                end
            else
                event.respond "You do not have permission to delete quotes!"
            end
        else
            event.respond "This appears to be a bad command"
            Logger.log("No command type matched", 0)
        end
    end

# COMMAND TYPES:
# 1 = ping
# 2 = quote help
# 3 = set activity
# 4 = random quote
# 5 = specific quote
# 6 = quote search
# 7 = add quote
# 8 = delete quote
    def self.IsBotGod(member)
        isBotGod = false
        member.roles.each do |role|
            if (role.name.downcase == "botgod")
                isBotGod = true
                Logger.log("User is BotGod", 0)
                return isBotGod
            end
        end

        Logger.log("User does not have the BotGod role!", 1)
        return isBotGod
    end


    def self.SetNewActivity(bot)
        selectedActivity = Activities.getNewActivity()
        activityType = selectedActivity[0]
        activityValue = selectedActivity[1]

        Logger.log("Setting activity to: " + activityType + " " + activityValue, 0)
        
        case activityType
        when "playing"            
            bot.game = activityValue 
        when "watching"
            bot.watching = activityValue
        when "listening"
            bot.listening = activityValue
        else
            bot.watching = "the world degenerate"
        end
    end
end