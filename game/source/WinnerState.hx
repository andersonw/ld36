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

    public override function new(p1x:Float, p1y:Float, p1a:Float, p2x:Float, p2y:Float, p2a:Float, r:Float, w:Float, h:Float, thing:Int = 4){
        super(thing);
        moveTimer = 0;
        this.p1x = p1x;
        this.p1y = p1y;
        this.p1a = p1a;
        this.p2x = p2x;
        this.p2y = p2y;
        this.p2a = p2a;
        this.w = w;
        this.h = h;
        this.r = r;
        hasFinished = false;
    }

	override public function create():Void
	{
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
        add(winnerText);
        if(Registry.currentMinigameWinner == 1) Registry.player1Sides += 1;
            else Registry.player2Sides += 1;
	}

    override public function update(elapsed:Float):Void
    {
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
        winner.update(elapsed);
        moveTimer += elapsed;
    }
}
