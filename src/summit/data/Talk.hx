package summit.data;

typedef Talk = {
  id:TalkId,
  title:Html,
  track:String,
  starts: Date,
  duration:Int,
  description:Html,
  speakers:Array<SpeakerId>,
}  