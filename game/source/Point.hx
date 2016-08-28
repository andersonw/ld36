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

    public function dot(q:Point):Float{
        return this.x * q.x + this.y * q.y;
    }

    public function update(xvel:Float, yvel:Float):Point{
        var newx = this.x + xvel;
        var newy = this.y + yvel;
        return new Point(newx, newy, this.polyInd);
    }

    public function rotatedCW(origin:Point, degAngle:Float){
        
        var c = Math.cos(Math.PI*degAngle/180);
        var s = Math.cos(Math.PI*degAngle/180);

        var d = this; // this - origin
        var newd = new Point(d.x * c + d.y * s, d.x * s - d.y * c, polyInd);

        return d; // d + origin
    }

}