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

class LapRaceState extends BasicGameState
{
	var centerBumper:FlxSprite;
	var outerLaneMarker:Array<Array<FlxSprite>>;
	var innerLaneMarker:Array<Array<FlxSprite>>;

    var currentLaneMarker:Array<Int>;
    var numberOfLaps:Array<Int>;

	public static inline var MARKER_WIDTH:Int = 10;
	public static inline var LANE_WIDTH:Int = 160;
	public static inline var LAPS_TO_WIN:Int = 2;
    public static inline var BUMPER_TOLERANCE:Float = 20;

	override public function create():Void
	{
        super.create();

        // + Math.floor(Math.random()*7)

        outerLaneMarker = new Array<Array<FlxSprite>>();
        innerLaneMarker = new Array<Array<FlxSprite>>();

        for(i in 0...2){
        	outerLaneMarker.push(new Array<FlxSprite>());
        	innerLaneMarker.push(new Array<FlxSprite>());

        	outerLaneMarker[i].push(new FlxSprite(0, height/2-MARKER_WIDTH/2));
        	outerLaneMarker[i].push(new FlxSprite(width/2-MARKER_WIDTH/2, height-LANE_WIDTH/2));
        	outerLaneMarker[i].push(new FlxSprite(width-LANE_WIDTH/2, height/2-MARKER_WIDTH/2));
        	outerLaneMarker[i].push(new FlxSprite(width/2-MARKER_WIDTH/2, 0));

        	innerLaneMarker[i].push(new FlxSprite(LANE_WIDTH/2, height/2-MARKER_WIDTH/2));
        	innerLaneMarker[i].push(new FlxSprite(width/2-MARKER_WIDTH/2, height-LANE_WIDTH));
        	innerLaneMarker[i].push(new FlxSprite(width-LANE_WIDTH, height/2-MARKER_WIDTH/2));
        	innerLaneMarker[i].push(new FlxSprite(width/2-MARKER_WIDTH/2, LANE_WIDTH/2));
        }
        for(i in 0...2) for(j in 0...4){
            if(j % 2 == 0){
                outerLaneMarker[i][j].makeGraphic(cast LANE_WIDTH/2, MARKER_WIDTH);
                innerLaneMarker[i][j].makeGraphic(cast LANE_WIDTH/2, MARKER_WIDTH);
            }else{
                outerLaneMarker[i][j].makeGraphic(MARKER_WIDTH, cast LANE_WIDTH/2);
                innerLaneMarker[i][j].makeGraphic(MARKER_WIDTH, cast LANE_WIDTH/2);
            }
        }
        for(i in 0...4){
        	outerLaneMarker[0][i].color = Registry.player1Color;
        	outerLaneMarker[1][i].color = Registry.player2Color;

        	innerLaneMarker[0][i].color = Registry.player1Color;
        	innerLaneMarker[1][i].color = Registry.player2Color;
        }
        for(i in 0...2) for(j in 1...4){
            outerLaneMarker[i][j].visible = false;
            innerLaneMarker[i][j].visible = false;
        }

        currentLaneMarker = new Array<Int>();
        currentLaneMarker = [0, 0];
        numberOfLaps = new Array<Int>();
        numberOfLaps = [0, 0];

        centerBumper = new FlxSprite(LANE_WIDTH, LANE_WIDTH);
        centerBumper.makeGraphic(Math.floor(width-2*LANE_WIDTH), Math.floor(height-2*LANE_WIDTH), FlxColor.BLUE);
        add(centerBumper);

        addSprites();
	}

    public function addSprites():Void{
        var innerLane:Int = Std.random(2);
        makeSprite(new NewPolygonSprite(width/2, innerLane==0 ? LANE_WIDTH*3/4 : LANE_WIDTH/4, Registry.player1Sides,
            180, 25, Registry.player1Color), [W, A, S, D]);
        makeSprite(new NewPolygonSprite(width/2, innerLane==1 ? LANE_WIDTH*3/4 : LANE_WIDTH/4, Registry.player2Sides,
            180, 25, Registry.player2Color), [UP, LEFT, DOWN, RIGHT]);
        for(i in 0...4){
            add(outerLaneMarker[innerLane][i]);
            add(outerLaneMarker[1-innerLane][i]);
            add(innerLaneMarker[1-innerLane][i]);
            add(innerLaneMarker[innerLane][i]);
        }
    }

    public function removeLaneMarkers():Void{
        for(i in 0...2) for(j in 0...4){
            remove(innerLaneMarker[i][j]);
            remove(outerLaneMarker[i][j]);
        }
    }

	override public function update(elapsed:Float):Void
	{
        for(i in 0...playSprites.length){
            var sprite = playSprites[i];
            if(sprite.x > centerBumper.x && sprite.x < centerBumper.x + centerBumper.width &&
                sprite.y > centerBumper.y && sprite.y < centerBumper.y + centerBumper.height){
                if(sprite.x < centerBumper.x + BUMPER_TOLERANCE && velocities[i].x > 0) velocities[i].x *= -1;
                if(sprite.x > centerBumper.x + centerBumper.width - BUMPER_TOLERANCE && velocities[i].x < 0) velocities[i].x *= -1;
                if(sprite.y < centerBumper.y + BUMPER_TOLERANCE && velocities[i].y > 0) velocities[i].y *= -1;
                if(sprite.y > centerBumper.y + centerBumper.height - BUMPER_TOLERANCE && velocities[i].y < 0) velocities[i].y *= -1;
            }

            var advanceLaneMarker:Bool = false;
            switch(currentLaneMarker[i]){
            case 0: advanceLaneMarker = (sprite.y > height/2 && sprite.x < width/2);
            case 1: advanceLaneMarker = (sprite.x > width/2 && sprite.y > height/2);
            case 2: advanceLaneMarker = (sprite.y < height/2 && sprite.x > width/2);
            case 3: advanceLaneMarker = (sprite.x < width/2 && sprite.y < height/2);
            }
            if(advanceLaneMarker){
                innerLaneMarker[i][currentLaneMarker[i]].visible = false;
                outerLaneMarker[i][currentLaneMarker[i]].visible = false;

                currentLaneMarker[i] += 1;
                if(currentLaneMarker[i] >= 4){
                    currentLaneMarker[i] = 0;
                    numberOfLaps[i] += 1;
                }

                innerLaneMarker[i][currentLaneMarker[i]].visible = true;
                outerLaneMarker[i][currentLaneMarker[i]].visible = true;

                if(numberOfLaps[i] >= LAPS_TO_WIN) declareWinner(i + 1);
            }
        }
        super.update(elapsed);
	}

    public override function resetGame(){
        super.resetGame();
        addSprites();
        for(i in 0...2){
            outerLaneMarker[i][0].visible = true;
            innerLaneMarker[i][0].visible = true;
            for(j in 1...4){
                outerLaneMarker[i][j].visible = false;
                innerLaneMarker[i][j].visible = false;
            }
        }
        currentLaneMarker = [0, 0];
        numberOfLaps = [0, 0];
    }
}
