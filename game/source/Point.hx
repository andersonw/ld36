package;

class Point
{
    public var x:Float;
    public var y:Float;

    public var polyInd:Int;

    public function new(x:Float, y:Float, ind:Int){
        this.x = x;
        this.y = y;
        this.polyInd = ind;
    }

    public function dot(q:Point){
        return this.x * q.x + this.y * q.y;
    }

}