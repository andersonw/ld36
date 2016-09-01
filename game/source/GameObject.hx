package;

import flixel.util.FlxColor;
import flixel.FlxSprite;

class GameObject{

    public var sprite:FlxSprite;
    public var vel:Point;
    public var avel:Float;
    public var color:FlxColor;
    
    public function new (sprite:FlxSprite, vel:Point, avel:Float, color:FlxColor=FlxColor.WHITE){
        
        this.sprite = sprite;
        this.vel = vel;
        this.avel = avel;
        this.color = color;

    }

    public function update(elapsed:Float){
        sprite.x += vel.x * 60 * elapsed;
        sprite.y += vel.y * 60 * elapsed;
        sprite.angle += avel * 60 * elapsed;
        vel = vel.scale(1 - (1-BasicGameState.DRAG) * 60 * elapsed);
        avel *= (1 - (1-BasicGameState.ANGULAR_DRAG) * 60 * elapsed);
    }

    public function destroy(){
        sprite.destroy();
    }

}