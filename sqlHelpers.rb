require 'pg'
require_relative 'configs'
require_relative 'logging'
require_relative 'variableHelpers'

class SQLMethods
    @prng = Random.new
    
    def self.GetRandomQuote()        
        quoteUpperRange = (GetTotalQuotesFromDatabase() + 1)
        selectedQuoteID = (@prng.rand 1..quoteUpperRange)
        
        result = GetQuoteByID(selectedQuoteID)

        return result
    end

    def self.GetQuoteByID(quoteID)
        result = ""
        totalQuotes = GetTotalQuotesFromDatabase()

        if (quoteID > totalQuotes)
            result = "There is no quote #{quoteID}! Valid selections are from 1 - #{totalQuotes}"
            return result
        end

        connection = PG::Connection.open(Configs.getConfigValue("postgresConnString"))        
        pgresult = connection.exec_params("SELECT quote FROM quotes WHERE id = $1", [quoteID])
        connection.close()

        begin
            result = "Quote #{quoteID}: " + pgresult.getvalue(0, 0)    
        rescue ArgumentEerror
            result = "Could not find quote #{quoteID}! Valid selections are from 1 - #{totalQuotes}"
        end        

        return result
    end

    def self.FindQuotesByText(searchText)
        returnedIDs = ""
        result = ""
        wildCardSQL = VariableHelpers.AddWildcardsToSQLString(searchText)

        connection = PG::Connection.open(Configs.getConfigValue("postgresConnString"))        
        pgresult = connection.exec_params("SELECT id FROM quotes WHERE quote ILIKE $1", ["%#{wildCardSQL}%"])
        connection.close()


        pgresult.each do |row|
            returnedIDs += row['id'].to_s + ", "
        end

        if (!returnedIDs.empty?)
            returnedIDs = returnedIDs.strip.chop
            result = "The following quotes were found: " + returnedIDs
        else
            result = "No quotes were found with the text \"#{searchText}\""
        end

        return result
    end

    def self.AddQuote(quoteText)
        totalQuotes = -1
        results = ""

        connection = PG::Connection.open(Configs.getConfigValue("postgresConnString"))
        connection.exec("INSERT INTO quotes (quote) VALUES ($1)", [quoteText])
        connection.close()

        totalQuotes = GetTotalQuotesFromDatabase()
        results = "Quote #{totalQuotes} added to the database!"        
    end

    def self.GetTotalQuotesFromDatabase()
        connection = PG::Connection.open(Configs.getConfigValue("postgresConnString"))
        pgresult = connection.exec("SELECT MAX(id) FROM quotes")
        connection.close()
        return pgresult.getvalue(0, 0).to_i
    end


    def self.DeleteQuoteFromDatabase(quoteID)
        totalQuotes = GetTotalQuotesFromDatabase()
        returnMessage = ""
        sqlCmd = ""

        if (quoteID < 1 || quoteID > totalQuotes)
            returnMessage = "Quote #{quoteID} does not exist! Quote range is 1 - #{totalQuotes}"
            return returnMessage
        end

        Logger.log("Starting quote deletion...", 1)

        connection = PG::Connection.open(Configs.getConfigValue("postgresConnString"))        
        connection.exec("DELETE FROM quotes WHERE id = $1",  [quoteID])
        Logger.log("Quote #{quoteID} deleted, swapping tables...", 1)

        tableSwapSQL = 
        "CREATE TABLE quotestmp ( id INT GENERATED ALWAYS AS IDENTITY, quote VARCHAR NOT NULL );
        INSERT INTO quotestmp (quote) SELECT quote FROM quotes ORDER BY id ASC;
        DROP TABLE quotes;
        CREATE TABLE quotes ( id INT GENERATED ALWAYS AS IDENTITY, quote VARCHAR NOT NULL );
        INSERT INTO quotes (quote) SELECT quote FROM quotestmp ORDER BY id ASC;
        DROP TABLE quotestmp;"

        connection.exec(tableSwapSQL)
        connection.close()

        Logger.log("Tables swapped!", 1)

        totalQuotes = GetTotalQuotesFromDatabase()
        returnMessage = "Quote #{quoteID} deleted! New quote range from 1 - #{totalQuotes}"

        return returnMessage
    end

end