class VariableHelpers

    def self.IsStringNumber(value)
        result = !value.match('\D')
        return result
    end

end