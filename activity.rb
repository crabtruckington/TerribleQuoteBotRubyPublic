require_relative 'logging'

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
    @usedActivities = Array.new

    def self.getNewActivity()
        if (@usedActivities.length == ACTIVITYARRAY.length)
            Logger.log("Cycled through all activities, truncating used list...", 0)
            @usedActivities = Array.new
        end
        selectedActivity = ACTIVITYARRAY[(@prng.rand ACTIVITYARRAYLENGTH)]

        while (@usedActivities.include?(selectedActivity)) do
            Logger.log("We selected a duplicate activity, reselecting...", 0)
            selectedActivity = ACTIVITYARRAY[(@prng.rand ACTIVITYARRAYLENGTH)]
        end
        @usedActivities << selectedActivity

        return selectedActivity
    end
end