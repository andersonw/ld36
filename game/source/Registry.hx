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

    public static var currentGameIndex:Int = -1;
    public static var gameList:Array<BasicGameState>;
    public static var gameRules:Array<String> = ["Push your opponent off the field 3 times!"
                                                ,"Stay on the blue dot for 4 seconds!"
                                                ,"Collect 5 red squares!"
                                                ,"Do two laps!"];
    //used for winner state
    public static var currentPlayerData:PlayerData;

    public static inline var FONT_PATH = "/assets/ponderosa.ttf";
    public static function resetGameList():Void
    {
        gameList = [new SumoGameState(), new KothGameState(), new FoodRaceState(), new LapRaceState()];
    }
}

class PlayerData
{
    public var p1x:Float;
    public var p1y:Float;
    public var p1a:Float;
    public var p2x:Float;
    public var p2y:Float;
    public var p2a:Float;
    public var w:Float;
    public var h:Float;
    public var r:Float;

    public function new(p1x:Float, p1y:Float, p1a:Float, p2x:Float, p2y:Float, p2a:Float, w:Float, h:Float, r:Float)
    {
        this.p1x = p1x;
        this.p1y = p1y;
        this.p1a = p1a;
        this.p2x = p2x;
        this.p2y = p2y;
        this.p2a = p2a;
        this.w = w;
        this.h = h;
        this.r = r;
    }
}