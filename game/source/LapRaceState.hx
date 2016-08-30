package;

import flixel.addons.display.FlxNestedSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.input.keyboard.FlxKey;

class LapRaceState extends BasicGameState
{
	var centerBumper:FlxSprite;

    var laneMarker:Array<Array<Array<FlxSprite>>>;

    var currentLaneMarker:Array<Int>;
    var numberOfLaps:Array<Int>;

    private var lapSound:FlxSound;

	public static inline var MARKER_WIDTH:Int = 10;
	public static inline var LANE_WIDTH:Int = 160;
	public static inline var LAPS_TO_WIN:Int = 2;
    public static inline var BUMPER_TOLERANCE:Float = 20;

	override public function create():Void
	{

        centerBumper = new FlxSprite(LANE_WIDTH, LANE_WIDTH);
        add(centerBumper);

        super.create();

        centerBumper.makeGraphic(Math.floor(width-2*LANE_WIDTH), Math.floor(height-2*LANE_WIDTH), FlxColor.BLUE);

        // + Math.floor(Math.random()*7)

        laneMarker = new Array<Array<Array<FlxSprite>>>();

        for(i in 0...2){
            laneMarker.push(new Array<Array<FlxSprite>>());
            for(j in 0...4) laneMarker[i].push(new Array<FlxSprite>());
            for(j in 0...4){
                laneMarker[i][0].push(new FlxSprite(j * LANE_WIDTH/4, height/2 - MARKER_WIDTH/2));
                laneMarker[i][1].push(new FlxSprite(width/2 - MARKER_WIDTH/2, height - LANE_WIDTH + j * LANE_WIDTH/4));
                laneMarker[i][2].push(new FlxSprite(width - LANE_WIDTH + j*LANE_WIDTH/4, height/2 - MARKER_WIDTH/2));
                laneMarker[i][3].push(new FlxSprite(width/2 - MARKER_WIDTH/2, j * LANE_WIDTH/4));
            }

            for(j in 0...4){
                if(j % 2 == 0){
                    for(k in 0...4) laneMarker[i][j][k].makeGraphic(cast LANE_WIDTH/4, MARKER_WIDTH);
                }else{
                    for(k in 0...4) laneMarker[i][j][k].makeGraphic(MARKER_WIDTH, cast LANE_WIDTH/4);
                }
            }
        }

        for(j in 0...4) for(k in 0...4){
        	laneMarker[0][j][k].color = Registry.player1Color;
        	laneMarker[1][j][k].color = Registry.player2Color;
        }

        for(i in 0...2) for(j in 1...4) for(k in 0...4){
            laneMarker[i][j][k].visible = false;
        }

        currentLaneMarker = new Array<Int>();
        currentLaneMarker = [0, 0];
        numberOfLaps = new Array<Int>();
        numberOfLaps = [0, 0];

        addSprites();

        lapSound = FlxG.sound.load(AssetPaths.foodPickup__wav);
	}

    public function addSprites():Void{
        var innerLane:Int = Std.random(2);
        makeSprite(new NewPolygonSprite(width/2, innerLane==0 ? LANE_WIDTH*3/4 : LANE_WIDTH/4, Registry.player1Sides,
            180, 25, Registry.player1Color), [W, A, S, D]);
        makeSprite(new NewPolygonSprite(width/2, innerLane==1 ? LANE_WIDTH*3/4 : LANE_WIDTH/4, Registry.player2Sides,
            180, 25, Registry.player2Color), [UP, LEFT, DOWN, RIGHT]);

        for(j in 0...4) for(k in 0...4){
            if(k % 2 == 0){
                add(laneMarker[0][j][k]);
                add(laneMarker[1][j][k]);
            }else{
                add(laneMarker[1][j][k]);
                add(laneMarker[0][j][k]);
            }
        }
    }

    public function removeLaneMarkers():Void{
        for(i in 0...2) for(j in 0...4) for(k in 0...4) remove(laneMarker[i][j][k]);
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
                lapSound.play();
                for(k in 0...4) laneMarker[i][currentLaneMarker[i]][k].visible = false;

                currentLaneMarker[i] += 1;
                if(currentLaneMarker[i] >= 4){
                    currentLaneMarker[i] = 0;
                    numberOfLaps[i] += 1;
                }

                for(k in 0...4) laneMarker[i][currentLaneMarker[i]][k].visible = true;

                if(numberOfLaps[i] >= LAPS_TO_WIN) declareWinner(i + 1);
            }
        }
        super.update(elapsed);
	}

    public override function resetGame(){
        super.resetGame();
        addSprites();
        for(i in 0...2) for(k in 0...4){
            laneMarker[i][0][k].visible = true;
            for(j in 1...4) laneMarker[i][j][k].visible = false;
        }
        currentLaneMarker = [0, 0];
        numberOfLaps = [0, 0];
    }
}
