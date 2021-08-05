require "pg"
require_relative "configs"

# shared connection is for the chart point generation methods, open/close are called in statsgen.rb
class SQLMethods
    @sharedConnection = ""
    @prng = Random.new
    
    def self.openSharedConnection()
        @sharedConnection = PG::Connection.open(Configs.getConfigValue("postgresConnString"))
    end

    def self.closeSharedConnection()
        @sharedConnection.close()
    end
    
    def self.insertStats(columns, values)
        connection = PG::Connection.open(Configs.getConfigValue("postgresConnString"))
        connection.exec_params("INSERT INTO monitorstats (#{columns}) VALUES (#{values});")
        connection.close()
    end

    def self.getComputedStatAggregate(ntileValue, returnedColumn, computeColumn1, computeColumn2)
        results = Array.new
        statsCutoff = (Time.new - Configs.getConfigValue("statsRetentionPeriod")).strftime("%Y-%m-%d %H:%M:%S")
        sqlcmd = "with aggregatestats (#{computeColumn1}, #{computeColumn2}, ntile) as ( " +
                 "select #{computeColumn1}, #{computeColumn2}, NTILE(#{ntileValue}) OVER(ORDER BY statsdate ASC) from monitorstats " +
                 "WHERE statsdate > '#{statsCutoff}' " +
                 ")" +
                 "SELECT AVG(#{computeColumn1} - #{computeColumn2}) as #{returnedColumn} from aggregatestats GROUP BY ntile ORDER BY ntile ASC"

        #connection = PG::Connection.open(Configs.getConfigValue("postgresConnString"))
        pgresults = @sharedConnection.exec(sqlcmd)
        #connection.close()

        pgresults.each_row do |row|
            results << row[0].to_f
        end

        return results
    end

    def self.getStatAggregate(ntileValue, column)
        results = Array.new
        statsCutoff = (Time.new - Configs.getConfigValue("statsRetentionPeriod")).strftime("%Y-%m-%d %H:%M:%S")
        sqlcmd = "with aggregatestats (#{column}, ntile) as ( " +
                 "select #{column}, NTILE(#{ntileValue}) OVER(ORDER BY statsdate ASC) from monitorstats " +
                 "WHERE statsdate > '#{statsCutoff}' " +
                 ")" +
                 "SELECT AVG(#{column}) from aggregatestats GROUP BY ntile ORDER BY ntile ASC"

        #connection = PG::Connection.open(Configs.getConfigValue("postgresConnString"))
        pgresults = @sharedConnection.exec(sqlcmd)
        #connection.close()

        pgresults.each_row do |row|
            results << row[0].to_f
        end

        return results
    end

    def self.getMostRecentStatValue(column)
        #connection = PG::Connection.open(Configs.getConfigValue("postgresConnString"))
        pgresults = @sharedConnection.exec("SELECT #{column} FROM monitorstats ORDER BY statsdate DESC LIMIT 1")
        #connection.close()
        
        return pgresults.getvalue(0,0)
    end

    def self.getOldestStat()
        statsCutoff = (Time.new - Configs.getConfigValue("statsRetentionPeriod")).strftime("%Y-%m-%d %H:%M:%S")
        pgresults = @sharedConnection.exec("SELECT statsdate FROM monitorstats WHERE statsdate > '#{statsCutoff}' " +
                                           "ORDER BY statsdate ASC LIMIT 1")
        return pgresults.getvalue(0,0)
    end

    def self.cleanUpOldStats(statsCutoff)
        retentionDate = (Time.new - statsCutoff).strftime("%Y-%m-%d %H:%M:%S")
        connection =  PG::Connection.open(Configs.getConfigValue("postgresConnString"))
        connection.exec("DELETE FROM monitorstats where statsdate < '#{retentionDate}'")
        connection.close()
    end


    def self.GetRandomQuote()        
        quoteUpperRange = (GetTotalQuotesFromDatabase() + 1)
        selectedQuoteID = (@prng.rand 1..quoteUpperRange).to_s
        
        result = GetQuoteByID(selectedQuoteID)

        return result
    end

    def self.GetQuoteByID(quoteID)
        connection = PG::Connection.open(Configs.getConfigValue("postgresConnString"))        
        pgresult = connection.exec("SELECT quote FROM quotes WHERE id = #{selectedQuoteID.to_s}")
        connection.close()

        return pgresult.getvalue(0, 0)
    end

    def self.FindQuotesByText(searchText)
        returnedIDs = ""

        connection = PG::Connection.open(Configs.getConfigValue("postgresConnString"))        
        pgresult = connection.exec("SELECT id FROM quotes WHERE quote ILIKE %#{searchText}%")
        connection.close()

        pgresult.each do |row|
            returnedIDs += row[0].to_s + ", "
        end

        if (!returnedIDs.empty?)
            returnedIDs = returnedIDs.strip.chop
        end

        return returnedIDs
    end

    def self.GetTotalQuotesFromDatabase()
        connection = PG::Connection.open(Configs.getConfigValue("postgresConnString"))
        pgresult = connection.exec("SELECT MAX(id) FROM quotes")
        connection.close()
        return pgresult.getvalue(0, 0).to_i
    end

end