package;

import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class KothGameState extends BasicGameState
{
    var countdownText:FlxText;
    var timeToGameStart:Float;
    var gameStarted:Bool;

    var hillX:Float;
    var hillY:Float;
    var player1Time:Float;
    var player2Time:Float;
    var player1TimeText:FlxText;
    var player2TimeText:FlxText;

    override public function create():Void
    {
        super.create();

        hillX = width/2;
        hillY = height/2;
        player1Time = 0;
        player2Time = 0;
        player1TimeText = new FlxText();
        player1TimeText.setFormat(20, FlxColor.YELLOW);
        player2TimeText = new FlxText();
        player2TimeText.setFormat(20, FlxColor.LIME);
        add(player1TimeText);
        add(player2TimeText);

        addSprites();

        var hill:FlxSprite = new FlxSprite(hillX-3, hillY-3);
        hill.makeGraphic(6, 6, FlxColor.BLUE);
        add(hill);

        countdownText = new FlxText();
        countdownText.setFormat(20);
        add(countdownText);

        resetCountdown();
        updateTimeText();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!gameStarted)
        {
            pause();
            timeToGameStart -= elapsed;
            if (timeToGameStart>0)
            {
                updateCountdownText();
            }
            else
            {
                gameStarted = true;
                countdownText.visible = false;
                unpause();
            }
            return;
        }

        if (polygonContainsPoint(playSprites[0], hillX, hillY))
        {
            player1Time += elapsed;
        }
        else if (polygonContainsPoint(playSprites[1], hillX, hillY))
        {
            player2Time += elapsed;
        }
        updateTimeText();
        if (player1Time>5)
        {
            trace("Player 1 wins!");
            Registry.player1Sides += 1;
            resetGame();
        }
        else if (player2Time>5)
        {
            trace("Player 2 wins!");
            Registry.player2Sides += 1;
            resetGame();
        }
    }

    public function polygonContainsPoint(polygon:NewPolygonSprite, pointX:Float, pointY:Float):Bool
    {
        //starting from 1 to ignore indicator
        for (i in 1...polygon.members.length)
        {
            var rect:FlxSprite = polygon.members[i];
            var radAngle:Float = rect.angle * Math.PI / 180;
            var centerX:Float = rect.x + rect.width/2;
            var centerY:Float = rect.y + rect.height/2;

            var p1 = new Point(centerX - rect.width*Math.cos(radAngle)/2, centerY - rect.width*Math.sin(radAngle)/2);
            var p2 = new Point(centerX + rect.width*Math.cos(radAngle)/2, centerY + rect.width*Math.sin(radAngle)/2);
            if (BasicGameState.getDiscriminant(new Point(pointX, pointY), p1, p2)>0)
            {
                return false;
            }
        }
        return true;
    }

    public function updateTimeText():Void
    {
        player1TimeText.text = roundNum(player1Time, 2);
        player1TimeText.x = width/4-player1TimeText.width/2;
        player1TimeText.y = 50;
        player2TimeText.text = roundNum(player2Time, 2);
        player2TimeText.x = 3*width/4-player2TimeText.width/2;
        player2TimeText.y = 50;
    }

    public function addSprites():Void
    {
        makeSprite(new NewPolygonSprite(60, 240, Registry.player1Sides, 0, 50, FlxColor.YELLOW), [W, A, S, D]);
        makeSprite(new NewPolygonSprite(580, 240, Registry.player2Sides, 180, 50, FlxColor.LIME), [UP, LEFT, DOWN, RIGHT]);
    }

    public function updateCountdownText():Void
    {
        countdownText.text = Std.string(Math.ceil(timeToGameStart));
        countdownText.x = (width-countdownText.width)/2;
        countdownText.y = (height-countdownText.height)/2-50;
    }

    public function resetCountdown():Void
    {
        countdownText.visible = true;
        timeToGameStart = 3;
        gameStarted = false;
    }

    public function roundNum(num:Float, decimalPlaces:Int):String
    {
        num *= Math.pow(10, decimalPlaces);
        var rounded = Std.string(Math.floor(num));
        var numString = rounded.substring(0, rounded.length-decimalPlaces)+"."+rounded.substring(rounded.length-decimalPlaces, rounded.length);
        if (numString.charAt(0)==".")
            numString = "0"+numString;
        return numString;
    }


    public function resetGame():Void
    {
        for (sprite in playSprites)
        {
            sprite.destroy();
        }
        playSprites = new Array<NewPolygonSprite>();
        velocities = new Array<Point>();
        aVelocities = new Array<Float>();
        keyLists = new Array<Array<FlxKey>>();
        addSprites();
        resetCountdown();
        player1Time = 0;
        player2Time = 0;
        updateTimeText();
    }
}