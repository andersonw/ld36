package;

import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;

class MenuState extends FlxState
{
	override public function create():Void
	{
        add(new FlxButtonPlus(270, 100, switchTest, "Test", 100, 20));
        add(new FlxButtonPlus(270, 200, switchSumo, "Sumo", 100, 20));
        add(new FlxButtonPlus(270, 400, switchKoth, "Koth", 100, 20));
        add(new FlxButtonPlus(270, 300, switchFoodRace, "Food Race", 100, 20));
        add(new FlxButtonPlus(270, 450, startMinigames, "Start the game!", 100, 20));
        add(new FlxButtonPlus(100, 100, startRace, "Race Laps", 100, 20));

		super.create();
	}

    public function switchTest():Void
    {
        FlxG.switchState(new TestState());
    }

    public function switchSumo():Void
    {
        FlxG.switchState(new SumoGameState());
    }

    public function switchKoth():Void
    {
        FlxG.switchState(new KothGameState());
    }

    public function switchFoodRace():Void
    {
        FlxG.switchState(new FoodRaceState());
    }

    public function startMinigames():Void
    {
        FlxG.switchState(new WariowareState());
    }

    public function startRace():Void
    {
        FlxG.switchState(new LapRaceState());
    }

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
