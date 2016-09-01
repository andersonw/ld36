package;

import flixel.FlxGame;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		// addChild(new FlxGame(640, 48, FinalizedMenuState));
        addChild(new FlxGame(640, 480, TestState));
	}
}