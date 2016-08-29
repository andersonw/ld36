package;

import flixel.addons.display.FlxNestedSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;

class TestState extends BasicGameState
{
	override public function create():Void
	{
        super.create();

        // + Math.floor(Math.random()*7)

		makeSprite(new NewPolygonSprite(70, 70, 3, 10, 50), [W, A, S, D]);
		makeSprite(new NewPolygonSprite(400, 400, 3, 74, 50), [UP, LEFT, DOWN, RIGHT]);
	}

	override public function update(elapsed:Float):Void
	{
        super.update(elapsed);
	}
 }
