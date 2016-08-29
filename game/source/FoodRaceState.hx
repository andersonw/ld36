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

	public var foodHeld:Array<Int>;

	public var playerTexts:Array<FlxText>;

	public var p1Text:FlxText;
	public var p2Text:FlxText;

	public static inline var FOOD_WIDTH:Float = 10;
	public static inline var SPAWNER_WIDTH:Float = 4;
	public static inline var FOOD_TO_WIN:Int = 5;

	override public function create():Void
	{
		super.create();
        foodI = 4;
        foodX = new Array<Float>();
        foodX = [width/4,	3*width/4,	width/4,	3*width/4,	width/2];
        foodY = new Array<Float>();
        foodY = [height/4,	height/4,	3*height/4,	3*height/4,	height/2];

        foodHeld = new Array<Int>();
        foodHeld = [0, 0];

        playerTexts = new Array<FlxText>();

        makePlayerText(55, 55, FlxColor.YELLOW);
        makePlayerText(width-55, 55, FlxColor.LIME);

        for(i in 0...foodX.length){
			var sprite = new FlxSprite(foodX[i] - SPAWNER_WIDTH/2, foodY[i] - SPAWNER_WIDTH/2);
			sprite.makeGraphic(SPAWNER_WIDTH, SPAWNER_WIDTH, FlxColor.BLUE);
			add(sprite);
		}

        foodSprite = new FlxSprite(foodX[foodI] - FOOD_WIDTH/2, foodY[foodI] - FOOD_WIDTH/2);
        foodSprite.makeGraphic(FOOD_WIDTH, FOOD_WIDTH, FlxColor.GREEN);
        add(foodSprite);

        addSprites();
	}

	private function addSprites(){
		makeSprite(new NewPolygonSprite(width/4, height/2, Registry.player1Sides, 0, 25, Registry.player1Color), [W, A, S, D]);
		makeSprite(new NewPolygonSprite(3*width/4, height/2, Registry.player2Sides, 180, 25, Registry.player2Color), [UP, LEFT, DOWN, RIGHT]);
	}

	private function makePlayerText(x:Float, y:Float, c:FlxColor):Int{
		var ret:Int = playerTexts.length;
		playerTexts.push(new FlxText(x, y));
		playerTexts[ret].size = 20;
		playerTexts[ret].color = c;
		playerTexts[ret].text = "0";
		add(playerTexts[ret]);
		return ret;
	}

	override public function update(elapsed:Float):Void
	{
		for(i in 0...playSprites.length){
			var sprite = playSprites[i];
			for(rect in sprite){
				if(BasicGameState.distanceFromPointToRect(new Point(foodX[foodI], foodY[foodI]), rect) < 10){
					trace("Player " + i + " got the food!");
					var newFoodI:Int = Math.floor(Math.random() * (foodX.length-1));
					foodI = newFoodI + (newFoodI >= foodI ? 1 : 0);
					trace(foodI);

					/*var oldSprite = playSprites[i];
					playSprites[i] = new NewPolygonSprite(oldSprite.x, oldSprite.y, oldSprite.numSides+1, oldSprite.angle, oldSprite.RADIUS, oldSprite.color);
					remove(oldSprite);
					oldSprite.destroy();
					add(playSprites[i]);*/

					foodHeld[i] += 1;
					playerTexts[i].text = "" + foodHeld[i];

					if(foodHeld[i] >= FOOD_TO_WIN){
						declareWinner(i + 1);
					}
				}
			}
		}

		foodSprite.x = foodX[foodI] - FOOD_WIDTH/2;
		foodSprite.y = foodY[foodI] - FOOD_WIDTH/2;

        super.update(elapsed);
	}

	public override function resetGame():Void{
		super.resetGame();
		addSprites();
		foodI = 4;
		foodHeld = [0, 0];
	}
 }
