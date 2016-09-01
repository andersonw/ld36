package;

import flixel.FlxSprite;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class KothGameState extends BasicGameState
{
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
        player1TimeText.setFormat(20, Registry.player1Color);
        player2TimeText = new FlxText();
        player2TimeText.setFormat(20, Registry.player2Color);
        add(player1TimeText);
        add(player2TimeText);

        addSprites();

        var hill:FlxSprite = new FlxSprite(hillX-4, hillY-4);
        hill.makeGraphic(8, 8, FlxColor.BLUE);
        add(hill);

        updateTimeText();
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        if (!pauseMenu)
        {
            if (polygonContainsPoint(playSprites[0], hillX, hillY))
            {
                player1Time += elapsed;
            }
            else if (polygonContainsPoint(playSprites[1], hillX, hillY))
            {
                player2Time += elapsed;
            }
        }
        updateTimeText();
        if (player1Time>4) declareWinner(1);
        else if (player2Time>4) declareWinner(2);
    }

    public function polygonContainsPoint(polygon:RegularPolygonSprite, pointX:Float, pointY:Float):Bool
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
        makeSprite(new RegularPolygonSprite(60, 240, Registry.player1Sides, 0, 50, Registry.player1Color), [W, A, S, D]);
        makeSprite(new RegularPolygonSprite(580, 240, Registry.player2Sides, 180, 50, Registry.player2Color), [UP, LEFT, DOWN, RIGHT]);
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

    public override function resetGame():Void
    {
        super.resetGame();
        addSprites();
        player1Time = 0;
        player2Time = 0;
        updateTimeText();
    }
}