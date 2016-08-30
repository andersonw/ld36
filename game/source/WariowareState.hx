package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;

class WariowareState extends FlxState
{
    override public function create():Void
    {
        Registry.player1Sides = 3;
        Registry.player2Sides = 3;

        persistentDraw = false;
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        Registry.resetGameList();
        if (Registry.player1Sides>=8)
        {
            trace("Player 1 wins!");
        }
        if (Registry.player2Sides>=8)
        {
            trace("Player 2 wins!");
        }
        var minigameIndex:Int = Std.random(Registry.gameList.length);
        Registry.currentGameIndex = minigameIndex;
        var minigameState:BasicGameState = Registry.gameList[minigameIndex];
        openSubState(minigameState);
    }
}