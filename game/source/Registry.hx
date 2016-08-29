package;

import flixel.util.FlxColor;

class Registry
{
    //global variables go here
    public static var player1Sides:Int = 3;
    public static var player2Sides:Int = 3;

    public static var player1Color:FlxColor = FlxColor.YELLOW;
    public static var player2Color:FlxColor = FlxColor.LIME;

    //set this to the actual player number (1 or 2), not 0
    public static var currentMinigameWinner:Int = 0;

    public static var gameList:Array<BasicGameState>;
    public static var gameRules:Array<String> = ["Push the other player completely off the field!"
                                                ,"Stay on the blue dot for 5 seconds!"];

    public static function resetGameList():Void
    {
        gameList = [new SumoGameState(), new KothGameState(), new FoodRaceState(), new LapRaceState()];
    }
}