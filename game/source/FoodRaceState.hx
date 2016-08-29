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
	public var foodI:Int;
	public var foodX:Array<Float>;
	public var foodY:Array<Float>;

	public var playerTexts:Array<FlxText>;

	public var p1Text:FlxText;
	public var p2Text:FlxText;
	public var winText:FlxText;

	public var winPlayer:Int;

	public static inline var FOOD_WIDTH:Float = 10;
	public static inline var SPAWNER_WIDTH:Float = 4;
	public static inline var WINNING_SIDES:Int = 12;

	override public function create():Void
	{
		super.create();
        foodI = 4;
        foodX = new Array<Float>();
        foodX = [width/4,	3*width/4,	width/4,	3*width/4,	width/2];
        foodY = new Array<Float>();
        foodY = [height/4,	height/4,	3*height/4,	3*height/4,	height/2];

        winPlayer = -1;

        playerTexts = new Array<FlxText>();

        makePlayerText(55, 55, FlxColor.YELLOW);
        makePlayerText(width-55, 55, FlxColor.LIME);

        winText = new FlxText(width/2, 55, 20);
        winText.size = 20;
        winText.color = FlxColor.WHITE;
        add(winText);


        for(i in 0...foodX.length){
			var sprite = new FlxSprite(foodX[i] - SPAWNER_WIDTH/2, foodY[i] - SPAWNER_WIDTH/2);
			sprite.makeGraphic(SPAWNER_WIDTH, SPAWNER_WIDTH, FlxColor.BLUE);
			add(sprite);
		}

        foodSprite = new FlxSprite(foodX[foodI] - FOOD_WIDTH/2, foodY[foodI] - FOOD_WIDTH/2);
        foodSprite.makeGraphic(FOOD_WIDTH, FOOD_WIDTH, FlxColor.RED);
        add(foodSprite);

		makeSprite(new NewPolygonSprite(width/4, height/2, 3, 0, 25, FlxColor.YELLOW), [W, A, S, D]);
		makeSprite(new NewPolygonSprite(3*width/4, height/2, 3, 180, 25, FlxColor.LIME), [UP, LEFT, DOWN, RIGHT]);
	}

	private function makePlayerText(x:Float, y:Float, c:FlxColor):Int{
		var ret:Int = playerTexts.length;
		playerTexts.push(new FlxText(x, y));
		playerTexts[ret].size = 20;
		playerTexts[ret].color = c;
		playerTexts[ret].text = "3";
		add(playerTexts[ret]);
		return ret;
	}

	override public function update(elapsed:Float):Void
	{
		if(winPlayer >= 0) pause();
		for(i in 0...playSprites.length){
			var sprite = playSprites[i];
			for(rect in sprite){
				if(BasicGameState.distanceFromPointToRect(new Point(foodX[foodI], foodY[foodI]), rect) < 10){
					trace("Player " + i + " got the food!");
					var newFoodI:Int = Math.floor(Math.random() * (foodX.length-1));
					foodI = newFoodI + (newFoodI >= foodI ? 1 : 0);
					trace(foodI);

					var oldSprite = playSprites[i];
					playSprites[i] = new NewPolygonSprite(oldSprite.x, oldSprite.y, oldSprite.numSides+1, oldSprite.angle, oldSprite.RADIUS, oldSprite.color);
					remove(oldSprite);
					oldSprite.destroy();
					add(playSprites[i]);

					playerTexts[i].text = "" + playSprites[i].numSides;

					if(playSprites[i].numSides >= WINNING_SIDES && winPlayer < 0){
						winPlayer = i;
						winText.text = "Player " + (winPlayer+1) + " won!";
						winText.color = playerTexts[i].color;
					}
				}
			}
		}

		foodSprite.x = foodX[foodI] - FOOD_WIDTH/2;
		foodSprite.y = foodY[foodI] - FOOD_WIDTH/2;

        super.update(elapsed);
	}
 }
