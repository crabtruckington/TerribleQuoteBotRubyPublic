require 'discordrb'
require_relative 'logging'

class VariableHelpers

    @lastFormattedQuote = ""
    @hasLastFormattedQuoteBeenAdded = false

    def self.IsStringNumber(value)
        result = !value.match('\D')
        return result
    end


    def self.AddWildcardsToSQLString(string)
        newString = string.gsub(" ", "%")
        return newString
    end


    def self.WrapUsernameIRCStyle(name)
        openBracket = " <".freeze
        closeBracket = "> ".freeze
        returnedName = openBracket + name + closeBracket
        return returnedName
    end

    #1 = last quote exists and is addable
    #2 = last quote does not exist
    #3 = last quote has already been added
    def self.IsLastFormattedQuoteAddable()
        result = 0

        if (@lastFormattedQuote.empty?)
            return 2
        elsif (@hasLastFormattedQuoteBeenAdded)
            return 3
        else
            return 1
        end

        return result
    end


    def self.ReturnLastFormattedQuote()
        returnQuote = @lastFormattedQuote
        @hasLastFormattedQuoteBeenAdded = true
        return returnQuote
    end


    def self.FormatQuote(args, event)
        formattedQuote = args
        channelMembers = event.channel.server.members
        channelUsers = Array.new
        idiotStyleQuote = false

        channelMembers.each do |member|
            channelUsers << member.display_name
        end
        
        Logger.log("Formatted quote after username replace:", 0)
        Logger.log(formattedQuote, 0)

        #remove the timestamps if they exist
        formattedQuote = formattedQuote.gsub(/^\[[0-9]{1,2}\:[0-9]{2}[\ ][A|P][M]\][\ ]/, "")
        #remove the broken timestamp at the beginning of the quote, missing the [ if it exists
        formattedQuote = formattedQuote.gsub(/^[0-9]{1,2}\:[0-9]{2}[\ ][A|P][M]\][\ ]/, "")
        #remove BOT label if someone quotes a bot
        formattedQuote = formattedQuote.gsub("\nBOT\n", "\n")
                
        channelUsers.each do |username|
            Logger.log("Membername: " + username, 0)
            nameSearch = username + ": "
            idiotQuoteStyleSearch = username + " \u2014"
            if (formattedQuote.include?(nameSearch))
                formattedQuote = formattedQuote.gsub(nameSearch, WrapUsernameIRCStyle(username))
            end
            if (formattedQuote.include?(idiotQuoteStyleSearch))
                idiotStyleQuote = true
                formattedQuote = formattedQuote.gsub(idiotQuoteStyleSearch, WrapUsernameIRCStyle(username))
            end
        end
                
        #remove linebreaks
        if (!idiotStyleQuote)
            formattedQuote = formattedQuote.gsub("\r\n", "")
            formattedQuote = formattedQuote.gsub("\r", "")
            formattedQuote = formattedQuote.gsub("\n", " ")
        
            channelUsers.each do |username|
                nameSearch = "<" + username + ">"
                if (formattedQuote.include?(nameSearch))
                    formattedQuote = formattedQuote.gsub(nameSearch, "\n" + nameSearch)
                end
            end
        else
            channelUsers.each do |username|
                nameSearch = "<" + username + ">"
                if (formattedQuote.include?(nameSearch))
                    Logger.log("Formatted quote we are replacing:\n" + formattedQuote, 0)
                    formattedQuote = formattedQuote.gsub(nameSearch + " \n", nameSearch + " ")
                    formattedQuote = formattedQuote.gsub(nameSearch + "  \n", nameSearch + " ")
                end
            end
        end
        
        formattedQuote.strip!

        #save without the bots added text, then add the text and return
        @lastFormattedQuote = formattedQuote
        formattedQuote = ("Here is your formatted quote:\n" + formattedQuote)
        @hasLastFormattedQuoteBeenAdded = false
        
        return formattedQuote
    end

end