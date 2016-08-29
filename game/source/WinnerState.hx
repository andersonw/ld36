package;

import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.FlxSubState;
import flixel.util.FlxColor;

class WinnerState extends FlxSubState
{
    var moveTimer:Float;
    var hasFinished:Bool;
    var winner:NewPolygonSprite;
    var loser:NewPolygonSprite;
    var cover:FlxSprite;
    var winnerText:FlxText;
    public static inline var WIN_TIMER:Float = 1;
    var p1x:Float;
    var p1y:Float;
    var p1a:Float;
    var p2x:Float;
    var p2y:Float;
    var p2a:Float;
    var w:Float;
    var h:Float;
    var r:Float;
    var winx:Float;
    var winy:Float;
    var wina:Float;

	override public function create():Void
	{
        var data = Registry.currentPlayerData;
        p1x = data.p1x;
        p1y = data.p1y;
        p1a = data.p1a;
        p2x = data.p2x;
        p2y = data.p2y;
        p2a = data.p2a;
        w = data.w;
        h = data.h;
        r = data.r;

        moveTimer = 0;
        hasFinished = false;

        cover = new FlxSprite(0,0);
        cover.makeGraphic(cast w, cast h, FlxColor.BLACK);
        add(cover);
        var p1 = new NewPolygonSprite(p1x, p1y, Registry.player1Sides, p1a, r, Registry.player1Color);
        var p2 = new NewPolygonSprite(p2x, p2y, Registry.player2Sides, p2a, r, Registry.player2Color);
        if(Registry.currentMinigameWinner == 1){
            winner = p1;
            loser = p2;
            winx = p1x;
            winy = p1y;
            wina = p1a;
        }else{
            winner = p2;
            loser = p1;
            winx = p2x;
            winy = p2y;
            wina = p2a;
        }
        add(winner);
        add(loser);
        winnerText = new FlxText(0, h/4, 500, "Player " + Registry.currentMinigameWinner + " is the winner!\nSpace to continue", 20);
        winnerText.visible = false;
        winnerText.alignment = CENTER;
        winnerText.setFormat(Registry.FONT_PATH, 30);
        add(winnerText);
        if(Registry.currentMinigameWinner == 1) Registry.player1Sides += 1;
        else Registry.player2Sides += 1;

        loser.explode();
	}

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        winner.angle -= (wina + 90) * elapsed/WIN_TIMER;
        if(moveTimer < WIN_TIMER){
            winner.x -= (winx - w/2) * elapsed/WIN_TIMER;
            winner.y -= (winy - h/2) * elapsed/WIN_TIMER;
            for (rect in loser.members) rect.alpha -= elapsed/WIN_TIMER;
        }else{
            if(!hasFinished){
                remove(winner);
                var newWinner = new NewPolygonSprite(w/2, h/2, winner.numSides+1, winner.angle, winner.RADIUS, winner.color);
                add(newWinner);
                winner.destroy();
                winner = newWinner;
                winnerText.visible = true;
                hasFinished = true;
            }
            if(FlxG.keys.anyPressed([SPACE])){
                close();
            }
        }
        moveTimer += elapsed;
    }
}
