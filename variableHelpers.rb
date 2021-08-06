class VariableHelpers

    def self.IsStringNumber(value)
        result = !value.match('\D')
        return result
    end

    def self.AddWildcardsToSQLString(string)
        newString = string.gsub(" ", "%")
        return newString
    end

end