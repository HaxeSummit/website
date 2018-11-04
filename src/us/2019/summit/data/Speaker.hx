package summit.data;

import tink.template.Html;

typedef Speaker = {
  id:SpeakerId,
  order: Int,
  shortName: String,
  fullName: Html,
  image: String,
  jobTitle: Html,
  link: String,
  talks:Array<Talk>,
  bio: Html,
  interview:Interview
}