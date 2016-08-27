package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

class PlayState extends FlxState
{
	var playerSprite:FlxSprite;
	var xVelocity:Float;
	var yVelocity:Float;

	public static inline var ACCELERATION:Float = 0.2;
	public static inline var ANGULAR_VELOCITY:Float = 5;
	public static inline var VELOCITY:Float = 4;
	public static inline var friction:Float = 0.99;

	override public function create():Void
	{

		playerSprite = new PolygonSprite(25, 25, 9, 10);
		xVelocity = yVelocity = 0;
		playerSprite.makeGraphic(10, 10, FlxColor.WHITE);
		add(playerSprite);
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
		xVelocity *= friction;
		yVelocity *= friction;

		if(FlxG.keys.anyPressed([LEFT, A]))
		{
			playerSprite.angle -= ANGULAR_VELOCITY;
		}
		if(FlxG.keys.anyPressed([RIGHT, D]))
		{
			playerSprite.angle += ANGULAR_VELOCITY;
		}
		if(FlxG.keys.anyPressed([UP, W]))
		{
			xVelocity += ACCELERATION * Math.cos(Math.PI*playerSprite.angle/180);
			yVelocity += ACCELERATION * Math.sin(Math.PI*playerSprite.angle/180);

		}
		if(FlxG.keys.anyPressed([DOWN, S]))
		{
			xVelocity -= ACCELERATION * Math.cos(Math.PI*playerSprite.angle/180);
			yVelocity -= ACCELERATION * Math.sin(Math.PI*playerSprite.angle/180);
		}

		playerSprite.x += xVelocity;
		playerSprite.y += yVelocity;

		if(playerSprite.x < 0 || playerSprite.x > 640)
		{
			xVelocity *= -1;
		}
		if(playerSprite.y < 0 || playerSprite.y > 480)
		{
			yVelocity *= -1;
		}

		super.update(elapsed);
	}
}
