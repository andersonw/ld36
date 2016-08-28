package;

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

class FoodRaceState extends BasicGameState
{
	public var foodSprite:FlxSprite;
	public static inline var FOOD_WIDTH:Float = 10;
	public var foodX:Float;
	public var foodY:Float;
	public var possibleX:Array<Float>;
	public var possibleY:Array<Float>;
	public var possibleLocs:Array<Point>;
	override public function create():Void
	{
		super.create();
        foodX = width/2;
        foodY = height/2;
        possibleX = new Array<Float>();
        possibleX = [width/4,	3*width/4,	width/4,	3*width/4,	width/2];
        possibleY = new Array<Float>();
        possibleY = [height/4,	height/4,	3*height/4,	3*height/4,	height/2];
        foodSprite = new FlxSprite(foodX - FOOD_WIDTH/2, foodY - FOOD_WIDTH/2);
        foodSprite.makeGraphic(FOOD_WIDTH, FOOD_WIDTH, FlxColor.GREEN);
        add(foodSprite);
		makeSprite(new NewPolygonSprite(25, 25, 3 + Math.floor(Math.random()*7), 10, 25), [W, A, S, D]);
		makeSprite(new NewPolygonSprite(400, 400, 3, 74, 25), [UP, LEFT, DOWN, RIGHT]);
	}

	override public function update(elapsed:Float):Void
	{
		var i:Int =  0;
		for(sprite in playSprites){
			for(rect in sprite){
				if(BasicGameState.distanceFromPointToRect(new Point(foodX, foodY), rect) < 10){
					trace("Player " + i + " got the food!");
					var i:Int = Math.floor(Math.random() * 5);
					foodX = possibleX[i];
					foodY = possibleY[i];
				}
			}
			i += 1;
		}
		foodSprite.x = foodX - FOOD_WIDTH/2;
		foodSprite.y = foodY - FOOD_WIDTH/2;
        super.update(elapsed);
	}
 }
