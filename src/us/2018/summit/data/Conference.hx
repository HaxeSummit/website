package summit.data;

typedef Conference = {
  days:Array<{
    name:String,
    talks:Array<Talk>,
  }>,
  speakers:Array<Speaker>,
}