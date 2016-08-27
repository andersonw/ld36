package;

import flixel.addons.display.FlxNestedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;

class PlayState extends FlxState
{
	var playSprites:Array<FlxSprite>;
	var xVelocities:Array<Float>;
	var yVelocities:Array<Float>;
	var keyLists:Array<Array<FlxKey>>;

	var width:Float;
	var height:Float;

	public static inline var ACCELERATION:Float = 0.2;
	public static inline var ANGULAR_VELOCITY:Float = 5;
	public static inline var VELOCITY:Float = 4;
	public static inline var DRAG:Float = 0.99;

	override public function create():Void
	{
		width = FlxG.width;
		height = FlxG.height;
		playSprites = new Array<FlxSprite>();
		xVelocities = new Array<Float>();
		yVelocities = new Array<Float>();
		keyLists = new Array<Array<FlxKey>>();

		playSprites.push(new PolygonSprite(25, 25, 3 + Math.floor(Math.random()*7), 10));
		keyLists.push([W,A,S,D]);

		playSprites.push(new PolygonSprite(400, 400, 2, 74));
		keyLists.push([UP, LEFT, DOWN, RIGHT]);

		for(sprite in playSprites)
		{
			add(sprite);
			xVelocities.push(0);
			yVelocities.push(0);
		}
		super.create();
	}

	override public function update(elapsed:Float):Void
	{
        super.update(elapsed);

		for(i in 0...playSprites.length){
			var sprite:FlxSprite = playSprites[i];
			xVelocities[i] *= DRAG;
			yVelocities[i] *= DRAG;
			if(keyLists[i].length >= 4){
				if(FlxG.keys.anyPressed([keyLists[i][1]]))
				{
					sprite.angle -= ANGULAR_VELOCITY;
				}
				if(FlxG.keys.anyPressed([keyLists[i][3]]))
				{
					sprite.angle += ANGULAR_VELOCITY;
				}
				if(FlxG.keys.anyPressed([keyLists[i][0]]))
				{
					xVelocities[i] += ACCELERATION * Math.cos(Math.PI*sprite.angle/180);
					yVelocities[i] += ACCELERATION * Math.sin(Math.PI*sprite.angle/180);

				}
				if(FlxG.keys.anyPressed([keyLists[i][2]]))
				{
					xVelocities[i] -= ACCELERATION * Math.cos(Math.PI*sprite.angle/180);
					yVelocities[i] -= ACCELERATION * Math.sin(Math.PI*sprite.angle/180);
				}
			}

			if(sprite.x < 0 || sprite.x > width)
			{
				xVelocities[i] *= -1;
			}
			if(sprite.y < 0 || sprite.y > height)
			{
				yVelocities[i] *= -1;
			}

			sprite.x += xVelocities[i];
			sprite.y += yVelocities[i];
            checkCollisions();
		}
	}

    private function checkCollisions():Void
    {
        var player1Segments:Array<FlxNestedSprite> = cast(playSprites[0], FlxNestedSprite).children;
        var player2Segments:Array<FlxNestedSprite> = cast(playSprites[1], FlxNestedSprite).children;
        for (i in 0...player1Segments.length)
        {
            var segment1 = player1Segments[i];
            var collides = false;

            for (j in 0...player2Segments.length)
            {
                var segment2 = player2Segments[j];
                if (FlxG.pixelPerfectOverlap(segment1, segment2))
                {
                    collides = true;
                    //trace("COLLISION DETECTED!");
                    break;
                }
            }

            segment1.color = collides ? FlxColor.RED : FlxColor.WHITE;
        }
    }

}
