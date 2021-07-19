/**
 * ...
 * @author ...
 */
class lp.friendlistfix.utils.StringUtils {
	
	static function LeftPadding(text: String, pad: String, minLength: Number) {
		while (text.length < minLength) {
			text = pad + text;
		}
		return text;
	}
	
}