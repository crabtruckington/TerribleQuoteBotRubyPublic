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
# 9 = format quote
#10 = add stored formatted quote

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
                    commandType = 5
                else
                    Logger.log("User is attempting to search for quotes", 0)
                    commandType = 6
                end
            else
                Logger.log("No argument passed, user wants a random quote", 0)
                commandType = 4
            end
        when "!findquote", "!quotesearch"
            commandType = 6
        when "!addquote"
            commandType = 7
        when "!delquote"
            commandType = 8
        when "!quoteformat", "!formatquote"
            commandType = 9
        when "!addformattedquote"
            commandType = 10
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
        when 1 #PING!
            Logger.log("Command type is 1", 0)
            event.respond "Pong!" + args.to_s
        when 2 #quote help            
            event.respond "The following commands are supported:\n" +
            "!quote: shows a random quote, optionally provide a number to show a specific quote\n" +
            "!addquote <text>: adds a quote to the database\n" +
            "!findquote <text> (alias: !quotesearch): search for a quote containing this text\n" +
            "!formatquote <text> (alias: !quoteformat): format a quote before adding it\n" +
            "!addformattedquote: adds the last quote that was formatted\n" +            
            "!ping: pong!"
        when 3 #set activity
            Logger.log("Setting new activity...", 0)
            SetNewActivity(bot)
            Logger.log("Activity set!", 0)
        when 4 #get a random quote
            result = SQLMethods.GetRandomQuote()
            event.respond result
        when 5 #get a quote by ID
            result = SQLMethods.GetQuoteByID(args.to_i)
            event.respond result
        when 6 #search for quote by arg string
            result = SQLMethods.FindQuotesByText(args)
            event.respond result
        when 7 #add a new quote, return the quote ID
            if (argumentProvided)
                result = SQLMethods.AddQuote(args)
                event.respond result
            else
                event.respond "You must provide some text to add a quote!"
            end
        when 8 #check for BOT GOD role and then delete quote by ID
            if (ValidateDeletionRequest(event, args))
                quoteToDelete = args.to_i
                result = SQLMethods.DeleteQuoteFromDatabase(quoteToDelete)
                event.respond result
            end
        when 9 #format a quote
            result = ""
            if (argumentProvided)
                result = VariableHelpers.FormatQuote(args, event)
            else
                result = "You must provide some text to format!"
            end
            event.respond result
        when 10 #add stored quote
            result = ""
            quoteAddable = VariableHelpers.IsLastFormattedQuoteAddable()
            case quoteAddable
            when 1
                quote = VariableHelpers.ReturnLastFormattedQuote()
                result = SQLMethods.AddQuote(quote)
            when 2
                result = "There is no stored formatted quote! You must format a quote to use this command!"
            when 3 
                result = "The stored quote has already been added! It was:\n" + VariableHelpers.ReturnLastFormattedQuote()
            else
                result = "Something went wrong determining the status of the last formatted quote, please check the logs!"
            end
            event.respond result
        else
            event.respond "This appears to be a bad command"
            Logger.log("No command type matched", 0)
        end
    end


    def self.ValidateDeletionRequest(event, args)
        response = ""
        member = event.author
        
        if (!IsBotGod(member))
            name = member.username
            Logger.log("User #{name} tried to delete a quote with command #{args} !", 3)
            response = "You do not have permission to delete quotes!"
            event.respond response
            return false
        end

        if (args.empty?)
            response = "You must provide a quote number to delete!"
            event.respond response
            return false
        end

        if (!VariableHelpers.IsStringNumber(args))
            totalQuotes = SQLMethods.GetTotalQuotesFromDatabase()
            response = "You must provide a valid quote number! Valid quote range is 1 - #{totalQuotes}"
            event.respond response
            return false
        end

        return true
    end


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

        Logger.log("Setting activity to: " + activityType + " " + activityValue, 1)
        
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