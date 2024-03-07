Config = {} 
Config.locale = 'en_lang' -- Change the language in the locales folder
Config.debug = false -- Set to true to enable debug messages
Config.keys = {
    R = 0xE3BF959B,
    G = 0xA1ABB953,
    E = 0x41AC83D1
}
--Bucketing--
Config.mudBucket = "mud_bucket" --Item to use
Config.mudBucketAmount = 1 --Amount of mud needed
Config.emptyMudBucket = "empty_mud_bucket" --Item to give back after use
Config.waterBucket = "water_bucket" --Item to use
Config.emptyWaterBucket = "empty_water_bucket" --Item to give back after use
Config.bucketingTime = 10000 --10 seconds

--Gold Washing--
Config.goldwashProp = "p_goldcradlestand01x" --Prop to use
Config.goldSiftingProp = "p_goldpan01x" --Prop to use
Config.washBuildTime = 10 --Time in seconds to build the wash station
Config.mudBucketAmountt = 2 --Amount of mud needed
Config.goldWashTime = 10000 --10 seconds
Config.goldWashReward = "gold_flakes" --Item to give
Config.goldWashRewardAmount = 1 --Amount of reward to give
-----------------------------------

--Extra Reward, because why not--
Config.extraReward = "gold_nugget" --Item to give
Config.extraRewardAmount = 1 --Amount of reward to give
Config.extraRewardChance = 10 --Chance of getting the extra reward



Config.waterTypes = { --https://github.com/femga/rdr3_discoveries/tree/master/zones
    {hash = "WATER_AURORA_BASIN", type = "lake", label = "Aurora Basin"},
    {hash = "WATER_BARROW_LAGOON", type = "lake", label = "Barrow Lagoon"},
    {hash = "WATER_CALMUT_RAVINE", type = "lake", label = "Calmut Ravine"},
    {hash = "WATER_ELYSIAN_POOL", type = "lake", label = "Elysian Pool"},
    {hash = "WATER_FLAT_IRON_LAKE", type = "lake", label = "Flat Iron Lake"},
    {hash = "WATER_HEARTLANDS_OVERFLOW", type = "lake", label = "Heartlands Overflow"},
    {hash = "WATER_LAKE_DON_JULIO", type = "lake", label = "Lake Don Julio"},
    {hash = "WATER_LAKE_ISABELLA", type = "lake", label = "Lake Isabella"},
    {hash = "WATER_O_CREAGHS_RUN", type = "lake", label = "O Creaghs Run"},
    {hash = "WATER_OWANJILA", type = "lake", label = "Owanjila"},
    {hash = "WATER_SEA_OF_CORONADO", type = "lake", label = "Sea of Coronado"},
    {hash = "WATER_ARROYO_DE_LA_VIBORA", type = "river", label = "Arroyo de la Vibora"},
    {hash = "WATER_BEARTOOTH_BECK", type = "river", label = "Beartooth Beck"},
    {hash = "WATER_DAKOTA_RIVER", type = "river", label = "Dakota River"},
    {hash = "WATER_KAMASSA_RIVER", type = "river", label = "Kamassa River"},
    {hash = "WATER_LANNAHECHEE_RIVER", type = "river", label = "Lannahechee River"},
    {hash = "WATER_LITTLE_CREEK_RIVER", type = "river", label = "Little Creek River"},
    {hash = "WATER_LOWER_MONTANA_RIVER", type = "river", label = "Lower Montana River"},
    {hash = "WATER_SAN_LUIS_RIVER", type = "river", label = "San Luis River"},
    {hash = "WATER_UPPER_MONTANA_RIVER", type = "river", label = "Upper Montana River"},
    {hash = "WATER_BAYOU_NWA", type = "swamp", label = "Bayou Nwa"},
    {hash = "WATER_BAHIA_DE_LA_PAZ", type = "ocean", label = "Bahia de la Paz"},
    {hash = "WATER_DEADBOOT_CREEK", type = "creek", label = "Deadboot Creek"},
    {hash = "WATER_DEWBERRY_CREEK", type = "creek", label = "Dewberry Creek"},
    {hash = "WATER_HAWKS_EYE_CREEK", type = "creek", label = "Hawks Eye Creek"},
    {hash = "WATER_RINGNECK_CREEK", type = "creek", label = "Ringneck Creek"},
    {hash = "WATER_SPIDER_GORGE", type = "creek", label = "Spider Gorge"},
    {hash = "WATER_STILLWATER_CREEK", type = "creek", label = "Stillwater Creek"},
    {hash = "WATER_WHINYARD_STRAIT", type = "creek", label = "Whinyard Strait"},
    {hash = "WATER_CAIRN_LAKE", type = "pond", label = "Cairn Lake"},
    {hash = "WATER_CATTIAL_POND", type = "pond", label = "Cattial Pond"},
    {hash = "WATER_HOT_SPRINGS", type = "pond", label = "Hot Springs"},
    {hash = "WATER_MATTLOCK_POND", type = "pond", label = "Mattlock Pond"},
    {hash = "WATER_MOONSTONE_POND", type = "pond", label = "Moonstone Pond"},
    {hash = "WATER_SOUTHFIELD_FLATS", type = "pond", label = "Southfield Flats"},

}





