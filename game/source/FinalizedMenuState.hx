package;

import flixel.addons.ui.FlxButtonPlus;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import flixel.math.FlxMath;

class FinalizedMenuState extends FlxState
{
    var titleText:FlxText;

    var menuPolygon:NewPolygonSprite;
    var menuPolygon2:NewPolygonSprite;

    var playButton:BetterButton;
    var aboutButton:BetterButton;

    override public function create():Void
    {
        titleText = new FlxText();
        titleText.text = "F RCE  F WHEEL";
        titleText.setFormat(Registry.FONT_PATH, 55);
        titleText.x = (FlxG.width-titleText.width)/2;
        titleText.y = 20;
        add(titleText);

        menuPolygon = new NewPolygonSprite(67,45,5,20,22,Registry.player1Color);
        menuPolygon2 = new NewPolygonSprite(290,45,6,190,22,Registry.player2Color);
        add(menuPolygon);
        add(menuPolygon2);

        playButton = new BetterButton(270, 200, 100, 40, "Play", 18, startMinigames);
        add(playButton);
        aboutButton = new BetterButton(270, 300, 100, 40, "About", 18, switchCredits);
        add(aboutButton);
        //add(new FlxButtonPlus(270, 100, startMinigames, "Play", 100, 40));
        super.create();
    }

    public function startMinigames():Void
    {
        FlxG.switchState(new WariowareState());
    }

    public function switchCredits():Void
    {
        FlxG.switchState(new CreditsState());
    }

    override public function update(elapsed:Float):Void
    {
        menuPolygon.angle += 90*elapsed;
        menuPolygon2.angle -= 80*elapsed;

        super.update(elapsed);
    }
}
