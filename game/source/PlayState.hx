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

class PlayState extends FlxState
{
	var playSprites:Array<NewPolygonSprite>;
	var xVelocities:Array<Float>;
	var yVelocities:Array<Float>;
	var aVelocities:Array<Float>;
	var keyLists:Array<Array<FlxKey>>;

	var width:Float;
	var height:Float;

    var currentlyColliding:Bool;

	public static inline var ACCELERATION:Float = 0.2;
	public static inline var ANGULAR_ACCELERATION:Float = 1;
	public static inline var ANGLULAR_DRAG:Float = 0.85;
	public static inline var ANGULAR_VELOCITY:Float = 5;
	public static inline var VELOCITY:Float = 4;
	public static inline var DRAG:Float = 0.99;
    public static inline var ELASTICITY:Float = .90;

    public static inline var COLLISION_THRESHOLD:Float = 10;

	public function makeSprite(sprite:NewPolygonSprite, keymap:Array<FlxKey>, xv:Float = 0, yv:Float = 0, av:Float = 0):Int
	{
		playSprites.push(sprite);
		keyLists.push(keymap);
		xVelocities.push(xv);
		yVelocities.push(yv);
		aVelocities.push(av);
		add(sprite);
		return playSprites.length - 1;
	}
	
	override public function create():Void
	{
		width = FlxG.width;
		height = FlxG.height;

		playSprites = new Array<NewPolygonSprite>();
		xVelocities = new Array<Float>();
		yVelocities = new Array<Float>();
		aVelocities = new Array<Float>();
		keyLists = new Array<Array<FlxKey>>();

		makeSprite(new NewPolygonSprite(25, 25, 3 + Math.floor(Math.random()*7), 10), [W, A, S, D]);
		makeSprite(new NewPolygonSprite(400, 400, 3, 74), [UP, LEFT, DOWN, RIGHT]);

		var temporaryCenter:FlxSprite = new FlxSprite(640/2-3, 480/2-3);
		temporaryCenter.makeGraphic(6, 6, FlxColor.BLUE);
		add(temporaryCenter);
		
        currentlyColliding = false;

        super.create();
	}

	override public function update(elapsed:Float):Void
	{
		// TODO: adjust how drag works with frame rate

        super.update(elapsed);

		for(i in 0...playSprites.length){
			
			var sprite:NewPolygonSprite = playSprites[i];

			// apply velocities
			sprite.x += xVelocities[i] * 60 * elapsed;
			sprite.y += yVelocities[i] * 60 * elapsed;
			sprite.angle += aVelocities[i] * 60 * elapsed;
			
			// apply drags
			xVelocities[i] *= DRAG;
			yVelocities[i] *= DRAG;
			aVelocities[i] *= ANGLULAR_DRAG;

			// check key for accelerations
			if(keyLists[i].length >= 4){
				if(FlxG.keys.anyPressed([keyLists[i][1]]))
				{
					aVelocities[i] -= ANGULAR_ACCELERATION * 60 * elapsed;
				}
				if(FlxG.keys.anyPressed([keyLists[i][3]]))
				{
					aVelocities[i] += ANGULAR_ACCELERATION * 60 * elapsed;
				}
				if(FlxG.keys.anyPressed([keyLists[i][0]]))
				{
					xVelocities[i] += ACCELERATION * Math.cos(Math.PI*sprite.angle/180) * 60 * elapsed;
					yVelocities[i] += ACCELERATION * Math.sin(Math.PI*sprite.angle/180) * 60 * elapsed;

				}
				if(FlxG.keys.anyPressed([keyLists[i][2]]))
				{
					xVelocities[i] -= ACCELERATION * Math.cos(Math.PI*sprite.angle/180) * 60 * elapsed;
					yVelocities[i] -= ACCELERATION * Math.sin(Math.PI*sprite.angle/180) * 60 * elapsed;
				}
			}

			// keep sprites within bounds
			if(sprite.x < 0 && xVelocities[i] < 0) xVelocities[i] *= -1;
			if(sprite.x > width && xVelocities[i] > 0) xVelocities[i] *= -1;
			if(sprite.y < 0 && yVelocities[i] < 0) yVelocities[i] *= -1;
			if(sprite.y > height && yVelocities[i] > 0) yVelocities[i] *= -1;

		}
        checkCollisions();
        //checkCollisionsWithPoints();
	}

    private function checkCollisions():Void
    {
    	var setCurrentlyCollidingFalse = true;

        var collided:Bool = collideSpriteAPointsWithSpriteBEdges(0,1);
        if(collided)
        	setCurrentlyCollidingFalse = false;

        var collided2:Bool = collideSpriteAPointsWithSpriteBEdges(1,0);
        if(collided2)
        	setCurrentlyCollidingFalse = false;

        if(setCurrentlyCollidingFalse)
        	currentlyColliding = false;


        // var collided:Bool = collideSpriteAPointsWithSpriteBEdges(0,1);
        // if (!collided)
        // {
        //     var collided2:Bool = collideSpriteAPointsWithSpriteBEdges(1,0);
        //     if (!collided2)
        //     {
        //         currentlyColliding = false;
        //     }
        // }
    }

    //this function performs collisions (i.e. it will change velocities and stuff if things collide)
    //returns: whether a collision was found
    private function collideSpriteAPointsWithSpriteBEdges(a:Int, b:Int):Bool
    {
        var playerASides:Array<FlxSprite> = playSprites[a].members;
        var playerBSides:Array<FlxSprite> = playSprites[b].members;
        var playerAEndpointsX:Array<Float> = new Array<Float>();
        var playerAEndpointsY:Array<Float> = new Array<Float>();
        for (i in 0...playerASides.length)
        {
            var rect:FlxSprite = playerASides[i];
            var radAngle:Float = rect.angle * Math.PI / 180;
            var centerX:Float = rect.x + rect.width/2;
            var centerY:Float = rect.y + rect.height/2;
            //gets the "left" endpoint of the rectangle
            playerAEndpointsX.push(centerX - rect.width*Math.cos(radAngle)/2);
            playerAEndpointsY.push(centerY - rect.width*Math.sin(radAngle)/2);
        }
        var superCollides:Bool = false;
        for (i in 0...playerBSides.length)
        {
            var rect:FlxSprite = playerBSides[i];
            var collides:Bool = false;

            for (j in 0...playerASides.length)
            {
                if (checkCollidePointAndRect(playerAEndpointsX[j], playerAEndpointsY[j], rect))
                {
                    collides = true;
                    superCollides = true;
                    if (!currentlyColliding)
                    {
                        currentlyColliding = true;
                        var tmp:Float = xVelocities[0];
                        xVelocities[0] = xVelocities[1];
                        xVelocities[1] = tmp;

                        tmp = yVelocities[0];
                        yVelocities[0] = yVelocities[1];
                        yVelocities[1] = tmp;
                    }
                    break;
                }
            }
            rect.color = collides ? FlxColor.RED : FlxColor.WHITE;
        }
        return superCollides;
    }

    private static function distanceFromPointToSegment(x:Float, y:Float, a1:Float, b1:Float, a2:Float, b2:Float):Float{
    	return((x - a1) * (b2 - b1) + (b1 - y) * (a2-a1))/Math.sqrt((b2-b1)*(b2-b1) + (a2-a1)*(a2-a1)); //wikipedia to the rescue
    }

    private static function projectiveCoordinate(x:Float, y:Float, a1:Float, b1:Float, a2:Float, b2:Float):Float{
    	return ((x-a1)*(a2-a1) + (y-b1)*(b2-b1))/((b2-b1)*(b2-b1) + (a2-a1)*(a2-a1));
    }

    private static function projectiveCoordinateWithRect(x:Float, y:Float, rect:FlxSprite){
    	var radAngle:Float = rect.angle * Math.PI / 180;
		var centerX:Float = rect.x + rect.width/2;
		var centerY:Float = rect.y + rect.height/2;
		return projectiveCoordinate(x, y, centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2,
			centerX + rect.width*Math.cos(radAngle)/2, centerY + rect.width*Math.sin(radAngle)/2);
    }

	private static function checkCollidePointAndSegment(x:Float, y:Float, a1:Float, b1:Float, a2:Float, b2:Float):Bool{
		var dist:Float = Math.abs(distanceFromPointToSegment(x,y,a1,b1,a2,b2)); //wikipedia to the rescue
		var projectionCoord:Float = projectiveCoordinate(x,y,a1,b1,a2,b2);
		return (dist < COLLISION_THRESHOLD) && (projectionCoord >= 0) && (projectionCoord <= 1);
	}

	private static function checkCollidePointAndRect(x:Float, y:Float, rect:FlxSprite){
		var radAngle:Float = rect.angle * Math.PI / 180;
		var centerX:Float = rect.x + rect.width/2;
		var centerY:Float = rect.y + rect.height/2;
		return checkCollidePointAndSegment(x, y, centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2,
			centerX + rect.width*Math.cos(radAngle)/2, centerY + rect.width*Math.sin(radAngle)/2);
	}

	private function checkCollisionsWithPoints():Void
	{
		var player1Segments:Array<FlxSprite> = playSprites[0].members;
		for(rect in player1Segments)
		{
			rect.color = checkCollidePointAndRect(640/2, 480/2, rect) ? FlxColor.BLUE : FlxColor.WHITE;
		}
	}
    
/* This was old checkCollisions code that used pixelPerfectOverlap
    private function checkCollisions():Void
    {
        var player1Segments:Array<FlxSprite> = playSprites[0].members;
        var player2Segments:Array<FlxSprite> = playSprites[1].members;
        
        var superCollides = false;
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
                    superCollides = true;
                    if (!currentlyColliding)
                    {
                        currentlyColliding = true;
                        var tmp:Float = xVelocities[0];
                        xVelocities[0] = xVelocities[1];
                        xVelocities[1] = tmp;

                        tmp = yVelocities[0];
                        yVelocities[0] = yVelocities[1];
                        yVelocities[1] = tmp;
                    }
                    break;
                }   
            }
            segment1.color = collides ? FlxColor.RED : FlxColor.WHITE;
        }
        if (!superCollides)
        {
            currentlyColliding = false;
        }
    }
*/
}
