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
        var buttonTest = new FlxButtonPlus(270, 100, switchTest, "Test", 100, 20);
        add(buttonTest);
        var buttonSumo = new FlxButtonPlus(270, 200, switchSumo, "Sumo", 100, 20);
        add(buttonSumo);
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

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
	}
}
