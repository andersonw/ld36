package;

class Registry
{
    //global variables go here
    public static var player1Sides:Int = 3;
    public static var player2Sides:Int = 3;

    public static var gameList:Array<BasicGameState> = [cast SumoGameState, cast KothGameState];
    public static var gameRules:Array<String> = ["Push the other player completely off the field!"
                                                ,"Stay on the blue dot for 5 seconds!"];
}