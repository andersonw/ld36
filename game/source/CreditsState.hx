package;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;

class CreditsState extends FlxState
{
    var creditsText:FlxText;
    var backButton:BetterButton;

    override public function create():Void
    {
        creditsText = new FlxText();
        creditsText.text = "Force of Wheel was made for Ludum Dare 36\n Programmed by Phillip Ai, Max Murin, and Anderson Wang\n Created with HaxeFlixel, sound effects made with bfxr";
        creditsText.setFormat(Registry.FONT_PATH, 13, CENTER);
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