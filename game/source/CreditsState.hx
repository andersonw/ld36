package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class CreditsState extends FlxState
{
    var creditsText:FlxText;
    var backButton:BetterButton;

    override public function create():Void
    {
        creditsText = new FlxText(FlxG.width/2, 100, 1000, 13);
        creditsText.text = "Force of Wheel was made for Ludum Dare 36\n Programmed by Phillip Ai, Max Murin, and Anderson Wang\n Created with HaxeFlixel, sound effects made with bfxr";
        creditsText.setFormat(Registry.FONT_PATH, 13, FlxColor.WHITE, CENTER);
        creditsText.x = (FlxG.width-creditsText.width)/2;
        creditsText.y = 100;
        backButton = new BetterButton(270, 300, 100, 40, "Back", 18, switchMenu);
        add(creditsText);
        add(backButton);
    }
    public function switchMenu():Void
    {
        FlxG.switchState(new FinalizedMenuState());
    }
}