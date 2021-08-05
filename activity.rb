class Activities
    ACTIVITYARRAY = 
    [
        ["watching".freeze, "you sleep".freeze],
        ["watching".freeze, "from the bushes".freeze],
        ["watching".freeze, "you poop".freeze],
        ["watching".freeze, "every move you make".freeze],
        ["watching".freeze, "Perfect Strangers".freeze],
        ["watching".freeze, "machine elves".freeze],
        ["watching".freeze, "the pretty lights".freeze],
        ["playing".freeze, "with your emotions".freeze],
        ["playing".freeze, "with your wife".freeze],
        ["playing".freeze, "doctor".freeze],
        ["playing".freeze, "HoboGarbageSimulator".freeze],
        ["listening".freeze, "In Your Eyes".freeze],
        ["listening".freeze, "the voices".freeze],
        ["listening".freeze, "silence".freeze],
        ["listening".freeze, "your phone calls".freeze],
        ["listening".freeze, "talk radio".freeze],
        ["listening".freeze, "the transmissions".freeze],
        ["listening".freeze, "the code".freeze]
    ]

    ACTIVITYARRAYLENGTH = ACTIVITYARRAY.length

    @prng = Random.new

    def self.getNewActivity()
        activityValue = @prng.rand ACTIVITYARRAYLENGTH
        return ACTIVITYARRAY[activityValue]
    end
end