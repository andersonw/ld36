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
import flixel.system.FlxSound;

class GameOverState extends FlxSubState
{
    var moveTimer:Float;
    var finishedStage1:Bool;
    var finishedStage2:Bool;
    var finishedStage3:Bool;

    var winner:RegularPolygonSprite;
    var loser:RegularPolygonSprite;
    var cover:FlxSprite;
    var winnerText:FlxText;
    var flashCover:FlxSprite;

    public static inline var WIN_TIMER_1:Float = 1;
    public static inline var WIN_TIMER_2:Float = 2;
    public static inline var WIN_TIMER_3:Float = 1;

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

    var angleV:Float;
    var explodeSound:FlxSound;

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
        explodeSound = FlxG.sound.load(AssetPaths.explosion__wav);

        angleV = 0;

        moveTimer = 0;
        finishedStage1 = false;
        finishedStage2 = false;
        finishedStage3 = false;

        cover = new FlxSprite(0,0);
        cover.makeGraphic(cast w, cast h, FlxColor.BLACK);
        add(cover);
        var p1 = new RegularPolygonSprite(p1x, p1y, Registry.player1Sides, p1a, r, Registry.player1Color);
        var p2 = new RegularPolygonSprite(p2x, p2y, Registry.player2Sides, p2a, r, Registry.player2Color);
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
        winnerText = new FlxText(50, h/4, 500, "Player " + Registry.currentMinigameWinner + " became a wheel and is the winner!\nSpace to return to menu", 20);
        winnerText.visible = false;
        winnerText.alignment = CENTER;
        winnerText.setFormat(Registry.FONT_PATH, 20);
        add(winnerText);

        if(Registry.currentMinigameWinner == 1) Registry.player1Sides += 1;
            else Registry.player2Sides += 1;

        angleV = 0;

        flashCover = new FlxSprite(0,0);
        flashCover.makeGraphic(cast w, cast h, FlxColor.WHITE);
        flashCover.alpha = 0;
        loser.explode();
        explodeSound.play();
	}

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        winner.angle += angleV * elapsed;
        if(!finishedStage1){
            if(angleV == 0) angleV = -(wina + 90) * elapsed/WIN_TIMER_1;
            winner.x -= (winx - w/2) * elapsed/WIN_TIMER_1;
            winner.y -= (winy - h/2) * elapsed/WIN_TIMER_1;
            for (rect in loser.members) rect.alpha -= elapsed/WIN_TIMER_1;
            if(moveTimer > WIN_TIMER_1){
                moveTimer = 0;

                remove(winner);
                var newWinner = new RegularPolygonSprite(w/2, h/2, winner.numSides+1, winner.angle, winner.RADIUS, winner.color);
                add(newWinner);
                winner.destroy();
                winner = newWinner;

                finishedStage1 = true;
            }
        }else if (!finishedStage2){
            angleV += 1000 * elapsed;
            if(moveTimer > WIN_TIMER_2){
                moveTimer = 0;

                angleV = 10;

                remove(winner);
                var newWinner = new RegularPolygonSprite(w/2, h/2, 40, winner.angle, winner.RADIUS, winner.color);
                add(newWinner);
                winner.destroy();
                winner = newWinner;

                add(flashCover);

                flashCover.alpha = 1;
                winnerText.visible = true;
                finishedStage2 = true;
            }
        }else if(!finishedStage3){
            flashCover.alpha -= elapsed/WIN_TIMER_3;
            if(moveTimer > WIN_TIMER_3){
                moveTimer = 0;
                finishedStage3 = true;
            }
        }else{
            if(FlxG.keys.anyPressed([SPACE])){
                FlxG.switchState(new FinalizedMenuState());
            }
        }
        moveTimer += elapsed;
    }
}
